//
//  ScannerView.swift
//  CodeScanner
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    var onScanned: (String) -> Void

    var body: some View {
        ZStack {
            CameraContainerView(viewModel: viewModel)
                .overlay(ScanAreaOverlay().stroke(Color.green, lineWidth: 2))
                .clipped()
                .background(Color.black)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { viewModel.toggleTorch() }) {
                        Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.title2)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .onReceive(viewModel.$lastScannedCode.compactMap { $0 }.removeDuplicates()) { code in
            onScanned(code)
        }
        .alert("Требуется доступ к камере", isPresented: $viewModel.showSettingsAlert) {
            Button("Настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы можете выдать разрешение в настройках.")
        }
    }
}

private struct CameraContainerView: UIViewRepresentable {
    let viewModel: ScannerViewModel

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        viewModel.attach(to: view.previewLayer)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.frame = uiView.bounds
    }
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

private struct ScanAreaOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let insetRect = rect.insetBy(dx: rect.width * 0.15, dy: rect.height * 0.3)
        p.addRoundedRect(in: insetRect, cornerSize: CGSize(width: 12, height: 12))
        return p
    }
}
