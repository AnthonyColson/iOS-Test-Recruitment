//
//  ListingInteractorImpl.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

final class ListingInteractorImpl: ListingsInteractor {

    // MARK: Dependencies
    
    private let repository: any ListingsRepository
    
    // MARK: Init
    
    init(repository: any ListingsRepository) {
        self.repository = repository
    }
    
    func getListings(pagination: (page: Int, limit: Int)?, query: String?) async throws -> ListingsPage {
        let dto = try await repository.getListings(pagination: pagination, query: query)
        return ListingsPage(from: dto)
    }
    
    func getCategories() async throws -> Categories {
        let dto = try await repository.getCategories()
        var categories: [Int: String] = [:]
        dto.forEach { categories[$0.id] = $0.name }
        return categories
    }
}
