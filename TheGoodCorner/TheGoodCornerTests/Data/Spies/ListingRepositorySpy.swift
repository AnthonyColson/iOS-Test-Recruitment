//
//  ListingRepositorySpy.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 24/05/2026.
//

import Foundation
@testable import TheGoodCorner

final class ListingRepositorySpy: @unchecked Sendable, ListingsRepository {
    var getListingsReponse: ListingsDTO?
    var getListingsReponseError: Error?
    var isGetListingCalled: Bool = false
    func getListings(pagination: (page: Int, limit: Int)?, query: String?) async throws -> ListingsDTO {
        isGetListingCalled = true
        guard let result = getListingsReponse else {
            if let networkError = getListingsReponseError {
                throw networkError
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }

    var getCategoriesReponse: CategoriesDTO?
    var getCategoriesError: Error?
    var isGetCategoriesCalled: Bool = false
    func getCategories() async throws -> CategoriesDTO {
        isGetCategoriesCalled = true
        guard let result = getCategoriesReponse else {
            if let networkError = getCategoriesError {
                throw networkError
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }
}
