//
//  ScannedItemDetailView.swift
//  CodeScanner
//

import SwiftUI

struct ScannedItemDetailView: View {
    let item: ScannedItem
    @State private var showShare = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.name ?? item.code ?? "Без названия")
                .font(.title)
            Text("Код: \(item.code ?? "-")")
            Text("Бренд: \(item.brand ?? "-")")
            Text("Nutri-Score: \(item.nutriscore ?? "-")")
            Text("Ингредиенты: \(item.ingredients ?? "-")")
            Spacer()
        }
        .padding()
        .navigationTitle("Детали")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showShare = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
                NavigationLink(destination: RenameView(item: item)) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [shareText])
        }
    }

    private var shareText: String {
        let lines = [
            "Название: \(item.name ?? "-")",
            "Код: \(item.code ?? "-")",
            "Бренд: \(item.brand ?? "-")",
            "Nutri-Score: \(item.nutriscore ?? "-")",
            "Ингредиенты: \(item.ingredients ?? "-")"
        ]
        return lines.joined(separator: "\n")
    }
}
