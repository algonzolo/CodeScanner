//
//  ScannerViewModel.swift
//  CodeScanner
//

import Foundation
@preconcurrency import AVFoundation
import Combine

final class ScannerViewModel: NSObject, ObservableObject {
    @Published var isTorchOn: Bool = false
    @Published var cameraAuthorized: Bool = false
    @Published var showSettingsAlert: Bool = false
    @Published var lastScannedCode: String?

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue", qos: .userInitiated)
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataDelegate = MetadataProxy()

    private var device: AVCaptureDevice? {
        AVCaptureDevice.default(for: .video)
    }

    override init() {
        super.init()
        metadataDelegate.owner = self
        Task { await checkPermissionAndConfigure() }
    }

    @MainActor
    func checkPermissionAndConfigure() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
            configureSession()
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
            cameraAuthorized = granted
            if granted {
                configureSession()
            } else {
                showSettingsAlert = true
            }
        case .denied, .restricted:
            cameraAuthorized = false
            showSettingsAlert = true
        @unknown default:
            cameraAuthorized = false
        }
    }

    @MainActor
    private func configureSession() {
        guard let device = device,
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        if session.inputs.isEmpty { session.addInput(input) }
        if session.outputs.isEmpty { session.addOutput(metadataOutput) }
        metadataOutput.setMetadataObjectsDelegate(metadataDelegate, queue: .main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .qr, .upce, .code128]
        session.commitConfiguration()

        let sessionRef = session
        sessionQueue.async {
            if !sessionRef.isRunning { sessionRef.startRunning() }
        }
    }

    func attach(to layer: AVCaptureVideoPreviewLayer) {
        layer.session = session
        layer.videoGravity = .resizeAspectFill
    }

    func toggleTorch() {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = isTorchOn ? .off : .on
            isTorchOn.toggle()
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error)")
        }
    }
    fileprivate func didScan(code: String) {
        lastScannedCode = code
    }
}

private final class MetadataProxy: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    weak var owner: ScannerViewModel?

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        owner?.didScan(code: code)
    }
}
