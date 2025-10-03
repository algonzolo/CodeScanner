//
//  CoreDataHelpers.swift
//  CodeScanner
//

import CoreData

extension ScannedItem {
    static func fetchByCode(_ code: String, in context: NSManagedObjectContext) -> ScannedItem? {
        let request: NSFetchRequest<ScannedItem> = ScannedItem.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "code == %@", code)
        return try? context.fetch(request).first
    }
}


