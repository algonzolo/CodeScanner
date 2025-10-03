//
//  ProductSummaryView.swift
//  CodeScanner
//

import SwiftUI

struct ProductSummaryView: View {
    let product: ProductDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.product_name ?? "Без названия")
                .font(.title2)
            Text("Бренд: \(product.brands ?? "-")")
            Text("Nutri-Score: \(product.nutriscore_grade?.uppercased() ?? "-")")
            Text("Ингредиенты: \(product.ingredients_text ?? "-")")
                .padding(.top, 6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}
