//
//  Categories+DTO.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 24/05/2026.
//

import Foundation

extension Dictionary where Key == Int, Value == String {
    /// Builds a Categories dictionnary [Int: String] from its DTO array.
    init(from dto: CategoriesDTO) {
        self = Dictionary(uniqueKeysWithValues: dto.map { ($0.id, $0.name) })
    }
}
