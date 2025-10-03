//
//  HistoryListView.swift
//  CodeScanner
//

import SwiftUI
import CoreData

struct HistoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScannedItem.date, ascending: false)],
        animation: .default)
    private var history: FetchedResults<ScannedItem>

    var body: some View {
        NavigationView {
            List {
                if history.isEmpty {
                    Text("История пуста").foregroundColor(.secondary)
                } else {
                    ForEach(history) { item in
                        NavigationLink(destination: ScannedItemDetailView(item: item)) {
                            HistoryRow(item: item)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("История")
            .toolbar { EditButton() }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { history[$0] }.forEach(viewContext.delete)
            do { try viewContext.save() } catch {
                print("Ошибка удаления: \(error.localizedDescription)")
            }
        }
    }
}

private struct HistoryRow: View {
    @ObservedObject var item: ScannedItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? (item.code ?? "Без названия"))
                    .font(.headline)
                Text(item.brand ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let score = item.nutriscore?.uppercased(), !score.isEmpty {
                    Text("Nutri-Score: \(score)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(item.date != nil ? shortDate(item.date!) : "")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}


