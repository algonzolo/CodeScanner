//
//  RenameView.swift
//  CodeScanner
//

import SwiftUI

struct RenameView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    let item: ScannedItem
    @State private var name: String = ""

    var body: some View {
        Form {
            TextField("Название", text: $name)
            Button("Сохранить") {
                item.name = name
                do { try context.save() } catch { }
                dismiss()
            }
        }
        .onAppear { name = item.name ?? "" }
        .navigationTitle("Переименование")
    }
}
