//
//  Product.swift
//  CodeScanner
//

import Foundation

struct Product: Decodable {
    let product: ProductDetails?
}

struct ProductDetails: Decodable {
    let product_name: String?
    let brands: String?
    let ingredients_text: String?
    let nutriscore_grade: String?
}
