//
//  CodeScannerApp.swift
//  CodeScanner
//
    
import SwiftUI
import Foundation

@main
struct CodeScannerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
