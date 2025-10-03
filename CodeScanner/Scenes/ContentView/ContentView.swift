//
//  ContentView.swift
//  CodeScanner
//

import SwiftUI
import CoreData
import SafariServices

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ContentViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScannedItem.date, ascending: false)],
        animation: .default)
    private var history: FetchedResults<ScannedItem>

    init(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: ContentViewModel(context: ctx))
    }

    var body: some View {
        TabView {
            // MARK: — Scanner Tab
            NavigationView {
                VStack(spacing: 20) {
                    if let product = viewModel.product {
                        ProductSummaryView(product: product)
                    } else if let error = viewModel.errorMessage {
                        Text("Ошибка: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Text("Отсканируйте штрих-код или QR")
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 16) {
                        Button(action: { viewModel.showScanner = true }) {
                            Label("Сканировать", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Button(action: {
                            viewModel.product = nil
                            viewModel.errorMessage = nil
                        }) {
                            Label("Очистить", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .padding()
                .navigationTitle("Сканер")
                .sheet(isPresented: $viewModel.showScanner) {
                    let scannerVM = ScannerViewModel()
                    ScannerView(viewModel: scannerVM) { code in
                        viewModel.showScanner = false
                        viewModel.handleScannedCode(code)
                    }
                }
                .sheet(isPresented: $viewModel.showSafari) {
                    if let url = viewModel.safariURL {
                        SafariView(url: url)
                    }
                }
            }
            .tabItem {
                Label("Сканер", systemImage: "camera")
            }

            HistoryListView()
            .tabItem {
                Label("История", systemImage: "clock")
            }
        }
    }
}
