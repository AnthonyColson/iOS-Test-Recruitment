//
//  ListingsRepositoryImplTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("ListingsRepositoryImplTests")
struct ListingsRepositoryImplTests {

    private var sut: ListingsRepositoryImpl
    private var networkerSpy: NetworkerServiceSpy

    init() {
        self.networkerSpy = NetworkerServiceSpy()
        self.sut = ListingsRepositoryImpl(networkService: networkerSpy)
    }

    // MARK: - getListings

    @Test func getListingsReturnsTheDTOFromNetworker() async throws {
        // Given
        let expected = ListingsDTO.mocked(
            hasMore: true,
            items: [.mocked(id: 1), .mocked(id: 2)]
        )
        networkerSpy.requestResponse = expected

        // When
        let result = try await sut.getListings(
            pagination: (page: 1, limit: 10),
            query: nil
        )

        // Then
        #expect(networkerSpy.isRequestCalled)
        #expect(result.items.count == 2)
        #expect(result.hasMore == true)
    }

    @Test func getListingsThrowsWhenNetworkerThrows() async {
        // Given
        networkerSpy.requestError = NetworkError.APIResponse.unexpected

        // When / Then
        await #expect(throws: NetworkError.APIResponse.self) {
            _ = try await sut.getListings(pagination: nil, query: nil)
        }
        #expect(networkerSpy.isRequestCalled)
    }

    // MARK: - getCategories

    @Test func getCategoriesReturnsTheDTOFromNetworker() async throws {
        // Given
        let expected: CategoriesDTO = [
            CategoriesElementDTO(id: 1, name: "Meuble"),
            CategoriesElementDTO(id: 2, name: "Sport")
        ]
        networkerSpy.requestResponse = expected

        // When
        let result = try await sut.getCategories()

        // Then
        #expect(networkerSpy.isRequestCalled)
        #expect(result.count == 2)
        #expect(result.first?.name == "Meuble")
    }

    @Test func getCategoriesThrowsWhenNetworkerThrows() async {
        // Given
        networkerSpy.requestError = NetworkError.APIResponse.unexpected

        // When / Then
        await #expect(throws: NetworkError.APIResponse.self) {
            _ = try await sut.getCategories()
        }
        #expect(networkerSpy.isRequestCalled)
    }
}
