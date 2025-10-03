//
//  ContentViewModel.swift
//  CodeScanner
//

import Foundation
import Combine
import CoreData

final class ContentViewModel: ObservableObject {
    @Published var product: ProductDetails?
    @Published var errorMessage: String?
    @Published var showScanner: Bool = false
    @Published var showSafari: Bool = false
    @Published var safariURL: URL?

    private let foodService: OpenFoodFactsServicing
    private let history: HistoryViewModel

    init(foodService: OpenFoodFactsServicing = OpenFoodFactsService(), context: NSManagedObjectContext) {
        self.foodService = foodService
        self.history = HistoryViewModel(context: context)
    }

    func handleScannedCode(_ code: String) {
        if let url = URL(string: code), let scheme = url.scheme, scheme.hasPrefix("http") {
            safariURL = url
            showSafari = true
            return
        }

        if code.allSatisfy({ $0.isNumber }) {
            Task { await loadProduct(barcode: code) }
            return
        }

        product = nil
        errorMessage = "QR содержит текст: \(code)"
    }

    @MainActor
    func loadProduct(barcode: String) async {
        do {
            let fetched = try await foodService.fetchProduct(by: barcode)
            product = fetched
            errorMessage = fetched == nil ? "Продукт не найден" : nil
            history.upsertScannedBarcode(code: barcode, details: fetched)
        } catch {
            product = nil
            errorMessage = error.localizedDescription
        }
    }
}


