//
//  Models.swift
//  skywebpro-test
//
//  Created by Андрей Лихачев on 11.07.2021.
//

import Foundation

struct Product: Codable {
    let id: Int
    let name: String
    let ccal: Int
    let date: String
    let category_id: Int
    let created_at: String
    let updated_at: String
}

struct Category: Codable {
    let id: Int
    let name: String
    let unit: String
    let count: Int
}

struct ProductDataResult: Codable {
    let data: Product
}

struct ProductsDataResult: Codable {
    let data: [Product]
}

struct CategoriesDataResult: Codable {
    let data: [Category]
}
