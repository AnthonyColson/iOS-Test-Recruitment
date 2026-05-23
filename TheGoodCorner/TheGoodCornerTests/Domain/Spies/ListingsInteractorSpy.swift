//
//  ListingsInteractorSpy.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation
@testable import TheGoodCorner

final class ListingsInteractorSpy: @unchecked Sendable, ListingsInteractor {
    var getListingsResponse: ListingsPage?
    var getListingsError: Error?
    var isGetListingsCalled: Bool = false
    func getListings(pagination: (page: Int, limit: Int)?, query: String?) async throws -> ListingsPage {
        isGetListingsCalled = true
        guard let result = getListingsResponse else {
            if let networkError = getListingsError {
                throw networkError
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }
    
    var getCategoriesResponse: Categories?
    var getCategoriesError: Error?
    var isGetCategoriesCalled: Bool = false
    func getCategories() async throws -> Categories {
        isGetCategoriesCalled = true
        guard let result = getCategoriesResponse else {
            if let networkError = getCategoriesError {
                throw networkError
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }
}
