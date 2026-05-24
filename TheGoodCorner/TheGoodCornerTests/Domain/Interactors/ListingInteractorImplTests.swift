//
//  ListingInteractorImplTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("ListingInteractorImplTests")
struct ListingInteractorImplTests {
    private var sut: ListingInteractorImpl
    private var repositorySpy: ListingRepositorySpy
    
    init() {
        self.repositorySpy = ListingRepositorySpy()
        self.sut = ListingInteractorImpl(repository: repositorySpy)
    }

    // MARK: - Initial state

    @Test func initialPaginationStateIsHasMoreTrue() {
        // Then
        #expect(sut.hasMore == true)
    }

    // MARK: - loadEnoughListings

    @MainActor
    @Test func loadEnoughReturnsItemsFromASinglePageWhenServerHasNoMore() async throws {
        // Given
        repositorySpy.getListingsReponse = .mocked(
            hasMore: false,
            items: [
                .mocked(id: 1),
                .mocked(id: 2),
                .mocked(id: 3)
            ]
        )
        sut.resetListings(categoryID: nil, query: nil)

        // When
        let items = try await sut.loadEnoughListings(minItems: 10)

        // Then
        #expect(repositorySpy.isGetListingCalled)
        #expect(items.count == 3)
        #expect(sut.hasMore == false)
    }

    @MainActor
    @Test func loadEnoughFiltersByCategoryID() async throws {
        // Given
        repositorySpy.getListingsReponse = .mocked(
            hasMore: false,
            items: [
                .mocked(id: 1, categoryID: 10),
                .mocked(id: 2, categoryID: 10),
                .mocked(id: 3, categoryID: 99),
                .mocked(id: 4, categoryID: 99)
            ]
        )
        sut.resetListings(categoryID: 10, query: nil)

        // When
        let items = try await sut.loadEnoughListings(minItems: 10)

        // Then
        #expect(items.count == 2)
        #expect(items.allSatisfy { [1, 2].contains($0.id) })
    }

    @MainActor
    @Test func loadEnoughStopsAtSafetyCapEvenWhenServerSaysHasMore() async throws {
        // Given
        sut.safetyCap = 3
        repositorySpy.getListingsReponse = .mocked(
            hasMore: true,
            items: [.mocked(id: 1, categoryID: 10)]
        )
        sut.resetListings(categoryID: 10, query: nil)

        // When
        let items = try await sut.loadEnoughListings(minItems: 100)

        // Then
        #expect(items.count == 1)
    }

    @MainActor
    @Test func loadEnoughDedupsItemsAcrossPages() async throws {
        // Given
        sut.safetyCap = 5
        repositorySpy.getListingsReponse = .mocked(
            hasMore: true,
            items: [.mocked(id: 1), .mocked(id: 2), .mocked(id: 3)]
        )
        sut.resetListings(categoryID: nil, query: nil)

        // When
        let items = try await sut.loadEnoughListings(minItems: 50)

        // Then
        #expect(items.count == 3)
        #expect(Set(items.map(\.id)) == [1, 2, 3])
    }

    // MARK: - reset

    @MainActor
    @Test func resetClearsAccumulatedItemsAndState() async throws {
        // Given — loaded
        repositorySpy.getListingsReponse = .mocked(
            hasMore: false,
            items: [.mocked(id: 1), .mocked(id: 2)]
        )
        sut.resetListings(categoryID: nil, query: nil)
        _ = try await sut.loadEnoughListings(minItems: 10)
        #expect(sut.hasMore == false)

        // When
        sut.resetListings(categoryID: 99, query: "foo")

        // Then
        #expect(sut.hasMore == true)
    }

    // MARK: - loadNextListings

    @MainActor
    @Test func loadNextReturnsImmediatelyWhenHasMoreIsFalse() async throws {
        // Given
        repositorySpy.getListingsReponse = .mocked(hasMore: false, items: [.mocked(id: 1)])
        sut.resetListings(categoryID: nil, query: nil)
        _ = try await sut.loadEnoughListings(minItems: 1)
        #expect(sut.hasMore == false)

        // When
        repositorySpy.getListingsReponse = .mocked(hasMore: false, items: [.mocked(id: 999)])
        let items = try await sut.loadNextListings()

        // Then
        #expect(items.count == 1)
        #expect(items.first?.id == 1)
    }

    @MainActor
    @Test func errorOnFetchRollsBackCurrentPageSoARetryWorks() async throws {
        // Given
        repositorySpy.getListingsReponse = .mocked(hasMore: true, items: [.mocked(id: 1)])
        sut.resetListings(categoryID: nil, query: nil)
        _ = try await sut.loadEnoughListings(minItems: 1)

        // When
        repositorySpy.getListingsReponse = nil
        repositorySpy.getListingsReponseError = NetworkError.APIResponse.unexpected
        do {
            _ = try await sut.loadNextListings()
            Issue.record("Expected loadNextListings to throw")
        } catch {
            // expected
        }

        // Then
        repositorySpy.getListingsReponseError = nil
        repositorySpy.getListingsReponse = .mocked(hasMore: false, items: [.mocked(id: 2)])
        let items = try await sut.loadNextListings()
        #expect(items.contains(where: { $0.id == 1 }))
        #expect(items.contains(where: { $0.id == 2 }))
    }
}
