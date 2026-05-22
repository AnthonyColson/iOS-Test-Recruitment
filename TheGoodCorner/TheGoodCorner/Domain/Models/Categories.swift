//
//  Categories.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

// MARK: - CategoriesElement
struct CategoriesElement: Equatable, Hashable {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(from dto: CategoriesElementDTO) {
        self.id = dto.id
        self.name = dto.name
    }
}

typealias Categories = [Int: String]
