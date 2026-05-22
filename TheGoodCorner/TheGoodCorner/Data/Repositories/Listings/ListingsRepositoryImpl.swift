//
//  ListingsRepositoryImpl.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

final class ListingsRepositoryImpl: ListingsRepository {
    
    // MARK: Dependencies

    private let networkService: any NetworkerService
    
    // MARK: Init

    init(networkService: any NetworkerService = NetworkerServiceImpl()) {
        self.networkService = networkService
    }
    
    func getListings(pagination: (page: Int, limit: Int)?, query: String?) async throws -> ListingsDTO {
        let baseURL = try APIEndpoints.getBaseUrl()
        let endpoint = APIEndpoints.getListings(pagination: pagination, query: query)
        let listingsResponse: ListingsDTO = try await networkService.request(baseURL: baseURL, endpoint: endpoint)
        return listingsResponse
    }
    
    func getCategories() async throws -> CategoriesDTO {
        let baseURL = try APIEndpoints.getBaseUrl()
        let endpoint = APIEndpoints.getCatgories()
        let categories: CategoriesDTO = try await networkService.request(baseURL: baseURL, endpoint: endpoint)
        return categories
    }
}
