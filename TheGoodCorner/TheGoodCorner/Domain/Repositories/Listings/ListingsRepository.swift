//
//  ListingsRepository.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

protocol ListingsRepository: Sendable {
    func getListings(pagination:  (page: Int, limit: Int)?, query: String?) async throws -> ListingsDTO
    func getCategories() async throws -> CategoriesDTO
}
