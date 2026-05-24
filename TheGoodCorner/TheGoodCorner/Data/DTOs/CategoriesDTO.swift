//
//  CategoriesDTO.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

// MARK: - CategoriesElementDTO
struct CategoriesElementDTO: Codable {
    let id: Int
    let name: String
}

typealias CategoriesDTO = [CategoriesElementDTO]
