//
//  ListingInteractorImpl.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

final class ListingInteractorImpl: ListingsInteractor {

    // MARK: - Dependencies

    private let repository: any ListingsRepository

    // MARK: - Configuration

    private let itemsPerPage: Int
    var safetyCap: Int

    // MARK: - Pagination state

    private(set) var hasMore: Bool = true

    private var items: [ListingsItem] = []
    private var currentPage = 0
    private var categoryID: Int?
    private var query: String?

    // MARK: - Init

    nonisolated init(
        repository: any ListingsRepository,
        itemsPerPage: Int = 10,
        safetyCap: Int = 100
    ) {
        self.repository = repository
        self.itemsPerPage = itemsPerPage
        self.safetyCap = safetyCap
    }

    // MARK: - Categories (stateless)

    nonisolated func getCategories() async throws -> Categories {
        let dto = try await repository.getCategories()
        var categories: [Int: String] = [:]
        dto.forEach { categories[$0.id] = $0.name }
        return categories
    }

    // MARK: - Listings (stateful pagination)

    func resetListings(categoryID: Int?, query: String?) {
        items = []
        hasMore = true
        currentPage = 0
        safetyCap = 100
        self.categoryID = categoryID
        self.query = query
    }

    @MainActor
    @discardableResult
    func loadEnoughListings(minItems: Int) async throws -> [ListingsItem] {
        var iterationsLeft = safetyCap

        while items.count < minItems && hasMore && iterationsLeft > 0 {
            iterationsLeft -= 1
            try await fetchNextPage()
        }

        return items
    }
    
    @MainActor
    @discardableResult
    func loadNextListings() async throws -> [ListingsItem] {
        guard hasMore else { return items }
        try await fetchNextPage()
        return items
    }

    // MARK: - Internal

    @MainActor
    private func fetchNextPage() async throws {
        currentPage += 1
        do {
            let dto = try await repository.getListings(pagination: (page: currentPage, limit: itemsPerPage),
                                                       query: query)
            let page = ListingsPage(from: dto)
            hasMore = page.hasMore
            safetyCap = dto.total / dto.limit

            let filtered: [ListingsItem]
            if let categoryID {
                filtered = page.items.filter { $0.categoryID == categoryID }
            } else {
                filtered = page.items
            }

            items.appendUnique(contentsOf: filtered)
        } catch {
            currentPage -= 1
            throw error
        }
    }
}
