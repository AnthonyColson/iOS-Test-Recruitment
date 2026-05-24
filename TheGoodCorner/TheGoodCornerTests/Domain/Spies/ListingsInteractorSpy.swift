//
//  ListingsInteractorSpy.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation
@testable import TheGoodCorner

final class ListingsInteractorSpy: ListingsInteractor {

    // MARK: - Categories (stateless)

    var getCategoriesResponse: Categories?
    var getCategoriesError: Error?
    var isGetCategoriesCalled: Bool = false

    nonisolated func getCategories() async throws -> Categories {
        await MainActor.run { self.isGetCategoriesCalled = true }
        let response = await MainActor.run { self.getCategoriesResponse }
        guard let result = response else {
            if let error = await MainActor.run(body: { self.getCategoriesError }) {
                throw error
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }

    // MARK: - Listings (stateful pagination)

    /// Items returned by `loadEnoughListings` / `loadNextListings`.
    var stubbedItems: [ListingsItem] = []

    /// If set, `loadEnoughListings` / `loadNextListings` throw this error.
    var thrownError: Error?

    var hasMore: Bool = true

    private(set) var lastResetCategoryID: Int??
    private(set) var lastResetQuery: String??
    private(set) var resetCallCount: Int = 0
    private(set) var loadEnoughCallCount: Int = 0
    private(set) var loadNextCallCount: Int = 0
    private(set) var lastMinItems: Int?

    private(set) var items: [ListingsItem] = []

    func resetListings(categoryID: Int?, query: String?) {
        resetCallCount += 1
        lastResetCategoryID = categoryID
        lastResetQuery = query
        items = []
    }

    @discardableResult
    func loadEnoughListings(minItems: Int) async throws -> [ListingsItem] {
        loadEnoughCallCount += 1
        lastMinItems = minItems
        if let thrownError { throw thrownError }
        items = stubbedItems
        return items
    }

    @discardableResult
    func loadNextListings() async throws -> [ListingsItem] {
        loadNextCallCount += 1
        if let thrownError { throw thrownError }
        items = stubbedItems
        return items
    }
}
