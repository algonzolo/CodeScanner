//
//  HistoryViewModel.swift
//  CodeScanner
//

import Foundation
import CoreData

final class HistoryViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func upsertScannedBarcode(code: String, details: ProductDetails?) {
        guard let details else { return }
        if let existing = findByCode(code: code) {
            update(existing: existing, with: details)
        } else {
            let item = ScannedItem(context: context)
            item.id = UUID()
            item.code = code
            item.date = Date()
            item.name = details.product_name
            item.brand = details.brands
            item.nutriscore = details.nutriscore_grade
            item.ingredients = details.ingredients_text
        }
        save()
    }

    func rename(item: ScannedItem, to newName: String) {
        item.name = newName
        save()
    }

    func delete(items: [ScannedItem]) {
        items.forEach(context.delete)
        save()
    }

    private func findByCode(code: String) -> ScannedItem? {
        let request: NSFetchRequest<ScannedItem> = ScannedItem.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "code == %@", code)
        return try? context.fetch(request).first
    }

    private func update(existing: ScannedItem, with details: ProductDetails?) {
        existing.date = Date()
        if let d = details {
            existing.name = d.product_name
            existing.brand = d.brands
            existing.nutriscore = d.nutriscore_grade
            existing.ingredients = d.ingredients_text
        }
    }

    private func save() {
        do { try context.save() } catch { print("CoreData save error: \(error)") }
    }
}


