//
//  OpenFoodFactsService.swift
//  CodeScanner
//

import Foundation

protocol OpenFoodFactsServicing {
    func fetchProduct(by barcode: String) async throws -> ProductDetails?
}

final class OpenFoodFactsService: OpenFoodFactsServicing {
    func fetchProduct(by barcode: String) async throws -> ProductDetails? {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(Product.self, from: data)
        return decoded.product
    }
}


