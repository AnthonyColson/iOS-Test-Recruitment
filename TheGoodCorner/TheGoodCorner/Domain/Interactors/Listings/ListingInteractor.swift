//
//  ListingInteractor.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

/// Interactor for listings.
///
/// Exposes a stateless API for categories and a stateful API for paginated
/// listings. The pagination context (current page, filter, query) is owned
/// by the interactor.
/// Use `resetListings(categoryID:query:)` to set the filter, then iterate with
/// `loadEnoughListings(minItems:)` or `loadNextListings()`.
protocol ListingsInteractor: AnyObject {

    func getCategories() async throws -> Categories

    var hasMore: Bool { get }

    @MainActor func resetListings(categoryID: Int?, query: String?)

    @MainActor
    @discardableResult
    func loadEnoughListings(minItems: Int) async throws -> [ListingsItem]

    @MainActor
    @discardableResult
    func loadNextListings() async throws -> [ListingsItem]
}
