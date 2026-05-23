//
//  DashboardViewModelTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("DashboardViewModelTests")
@MainActor
final class DashboardViewModelTests {

    private var sut: DashboardViewModel!
    private var interactorSpy: ListingsInteractorSpy!

    init() {
        interactorSpy = ListingsInteractorSpy()
        sut = DashboardViewModel(interactor: interactorSpy)
    }

    // MARK: - Initial state

    @Test func initialStateIsLoadingAndEmpty() {
        // Then
        #expect(sut.categoriesState == .loading)
        #expect(sut.listingState == .loading)
        #expect(sut.selectedCategory == nil)
        #expect(sut.allCategories.isEmpty)
        #expect(sut.listingCardItems.isEmpty)
        #expect(sut.isLoadingMore == false)
    }

    // MARK: - onAppear

    @Test(arguments: [
        (false, false, DashboardViewModel.CategoriesState.success, DashboardViewModel.ListingState.success),
        (true,  false, .error,   .success),
        (false, true,  .success, .error),
        (true,  true,  .error,   .error),
    ])
    func onAppearTransitionsStatesAccordingToInteractorOutcomes(
        categoriesFail: Bool,
        listingsFail: Bool,
        expectedCategoriesState: DashboardViewModel.CategoriesState,
        expectedListingState: DashboardViewModel.ListingState
    ) async {
        // Given
        if categoriesFail {
            interactorSpy.getCategoriesError = NetworkError.APIResponse.unexpected
        } else {
            interactorSpy.getCategoriesResponse = [10: "Meuble"]
        }
        if listingsFail {
            interactorSpy.getListingsError = NetworkError.APIResponse.unexpected
        } else {
            interactorSpy.getListingsResponse = .mocked(hasMore: false)
        }

        // When
        await sut.onAppear()

        // Then
        #expect(sut.categoriesState == expectedCategoriesState)
        #expect(sut.listingState == expectedListingState)
    }

    @Test func onAppearMapsListingsToCardItemsAndResolvesCategoryName() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble", 20: "Sport"]
        interactorSpy.getListingsResponse = .mocked(
            hasMore: false,
            items: [
                .mocked(id: 1, categoryID: 10, title: "Chair"),
                .mocked(id: 2, categoryID: 20, title: "Bike")
            ]
        )

        // When
        await sut.onAppear()

        // Then
        #expect(sut.listingCardItems.count == 2)
        #expect(sut.listingCardItems.first { $0.id == 1 }?.category == "Meuble")
        #expect(sut.listingCardItems.first { $0.id == 2 }?.category == "Sport")
    }

    @Test func onAppearIsIdempotentWhenItemsAlreadyLoaded() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(hasMore: false, items: [.mocked()])
        await sut.onAppear()
        let initialCount = sut.listingCardItems.count

        // When
        await sut.onAppear()

        // Then
        #expect(sut.listingCardItems.count == initialCount)
    }

    @Test func onAppearWithNoItemsTransitionsListingToEmpty() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(hasMore: false, items: [])

        // When
        await sut.onAppear()

        // Then
        #expect(sut.listingState == .empty)
        #expect(sut.listingCardItems.isEmpty)
    }

    // MARK: - selectCategory

    @Test func selectCategoryStoresTheCategory() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(hasMore: false, items: [])
        let category = CategoriesElement(id: 10, name: "Meuble")

        // When
        await sut.selectCategory(category)

        // Then
        #expect(sut.selectedCategory == category)
    }

    @Test func selectCategoryTwiceTogglesItOff() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(hasMore: false, items: [])
        let category = CategoriesElement(id: 10, name: "Meuble")

        // When
        await sut.selectCategory(category)
        await sut.selectCategory(category)

        // Then
        #expect(sut.selectedCategory == nil)
    }

    @Test func selectCategoryKeepsOnlyItemsMatchingTheCategory() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(
            hasMore: false,
            items: [
                .mocked(id: 1, categoryID: 10),
                .mocked(id: 2, categoryID: 10),
                .mocked(id: 3, categoryID: 99),
                .mocked(id: 4, categoryID: 99)
            ]
        )

        // When
        await sut.selectCategory(CategoriesElement(id: 10, name: "Meuble"))

        // Then
        #expect(sut.listingCardItems.count == 2)
        #expect(sut.listingCardItems.allSatisfy { [1, 2].contains($0.id) })
    }

    @Test func selectCategoryResetsThePreviousResults() async {
        // Given — initial load with 3 items in category 10
        interactorSpy.getCategoriesResponse = [10: "Meuble", 20: "Sport"]
        interactorSpy.getListingsResponse = .mocked(
            hasMore: false,
            items: (1...3).map { .mocked(id: $0, categoryID: 10) }
        )
        await sut.onAppear()
        #expect(sut.listingCardItems.count == 3)

        // When
        await sut.selectCategory(CategoriesElement(id: 20, name: "Sport"))

        // Then
        #expect(sut.listingCardItems.isEmpty)
        #expect(sut.listingState == .empty)
    }

    // MARK: - loadNextPage

    @Test func loadNextPageAppendsNewItems() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(
            hasMore: true,
            items: (1...5).map { .mocked(id: $0, categoryID: 10) }
        )
        await sut.onAppear()
        let initialCount = sut.listingCardItems.count

        // When
        interactorSpy.getListingsResponse = .mocked(
            hasMore: false,
            items: (100...105).map { .mocked(id: $0, categoryID: 10) }
        )
        await sut.loadNextPage()

        // Then
        #expect(sut.listingCardItems.count > initialCount)
    }

    @Test func loadNextPageIsNoOpWhenNoMorePages() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(hasMore: false, items: [.mocked()])
        await sut.onAppear()
        let countAfterFirstLoad = sut.listingCardItems.count

        // When
        await sut.loadNextPage()

        // Then
        #expect(sut.listingCardItems.count == countAfterFirstLoad)
    }

    @Test func loadNextPageSetsErrorStateOnFailure() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.getListingsResponse = .mocked(
            hasMore: true,
            items: (1...3).map { .mocked(id: $0, categoryID: 10) }
        )
        await sut.onAppear()
        let countAfterFirstLoad = sut.listingCardItems.count

        // When
        interactorSpy.getListingsResponse = nil
        interactorSpy.getListingsError = NetworkError.APIResponse.unexpected
        await sut.loadNextPage()

        // Then
        #expect(sut.listingState == .error)
        #expect(sut.listingCardItems.count == countAfterFirstLoad)
    }
}
