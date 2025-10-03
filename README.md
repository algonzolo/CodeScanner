# CodeScanner

Приложение для сканирования штрих-кодов и QR-кодов, получения данных из Open Food Facts и сохранения истории в Core Data. UI на SwiftUI, архитектура MVVM, асинхронность с Swift Concurrency и Combine.

## Технологии
- Swift, SwiftUI
- AVFoundation (камера, сканирование)
- URLSession + Swift Concurrency (async/await)
- Combine (наблюдение за состоянием)
- Core Data (локальное хранилище)
- Архитектура MVVM

## Структура
- `OpenFoodFactsService.swift` — сервис для работы с API OFF
- `Product.swift` — модели `Product`/`ProductDetails`
- `ScannerViewModel.swift` — VM камеры: разрешения, торч, события сканирования
- `ScannerView.swift` — UI сканера с оверлеем области сканирования и кнопкой фонарика
- `ContentViewModel.swift` — VM главного экрана: обработка кода, загрузка продукта, открытие Safari, сохранение
- `HistoryViewModel.swift` — VM истории: upsert/rename/delete/сохранение QR-текста
- `CoreDataHelpers.swift` — вспомогательные методы для Core Data
- `ContentView.swift` — два таба: Сканер и История, детали элемента и Share
- `PersistenceController.swift` — инициализация Core Data

## Возможности
- Сканирование EAN/UPC/QR, переключение фонарика
- Запрос разрешения камеры, алерт с переходом в настройки при отказе
- Для штрих-кодов — запрос к OFF `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
- Для QR-ссылок — открытие в Safari
- Для QR-текста — сохранение текста в историю
- История: список, детали, удаление, переименование, Share
