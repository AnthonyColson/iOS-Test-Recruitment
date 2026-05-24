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
final class DashboardViewModelTests {

    private var sut: DashboardViewModel!
    private var interactorSpy: ListingsInteractorSpy!

    init() {
        interactorSpy = ListingsInteractorSpy()
        sut = DashboardViewModel(interactor: interactorSpy)
    }

    // MARK: - Initial state

    @MainActor
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

    @MainActor
    @Test(arguments: [
        (false, false, DashboardViewModel.CategoriesState.success, DashboardViewModel.ListingState.success),
        (true,  false, .error,   .success),
        (false, true,  .success, .error),
        (true,  true,  .error,   .error),
    ])
    func onAppearTransitionsStatesAccordingToOutcomes(
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
            interactorSpy.thrownError = NetworkError.APIResponse.unexpected
        } else {
            interactorSpy.stubbedItems = [.mocked(id: 1, categoryID: 10)]
        }

        // When
        await sut.onAppear()

        // Then
        #expect(sut.categoriesState == expectedCategoriesState)
        #expect(sut.listingState == expectedListingState)
    }

    @MainActor
    @Test func onAppearMapsItemsToCardItemsAndResolvesCategoryName() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble", 20: "Sport"]
        interactorSpy.stubbedItems = [
            .mocked(id: 1, categoryID: 10, title: "Chair"),
            .mocked(id: 2, categoryID: 20, title: "Bike")
        ]

        // When
        await sut.onAppear()

        // Then
        #expect(sut.listingCardItems.count == 2)
        #expect(sut.listingCardItems.first { $0.id == 1 }?.category == "Meuble")
        #expect(sut.listingCardItems.first { $0.id == 2 }?.category == "Sport")
    }

    @MainActor
    @Test func onAppearIsIdempotentWhenItemsAlreadyLoaded() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = [.mocked()]
        await sut.onAppear()
        let initialLoadEnoughCount = interactorSpy.loadEnoughCallCount

        await sut.onAppear()

        // Then
        #expect(interactorSpy.loadEnoughCallCount == initialLoadEnoughCount)
    }

    @MainActor
    @Test func onAppearWithNoItemsTransitionsListingToEmpty() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = []

        // When
        await sut.onAppear()

        // Then
        #expect(sut.listingState == .empty)
        #expect(sut.listingCardItems.isEmpty)
    }

    // MARK: - selectCategory

    @MainActor
    @Test func selectCategoryStoresTheCategoryAndResetsInteractor() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = []
        let category = CategoriesElement(id: 10, name: "Meuble")

        // When
        await sut.selectCategory(category)

        // Then
        #expect(sut.selectedCategory == category)
        #expect(interactorSpy.lastResetCategoryID == 10)
        #expect(interactorSpy.loadEnoughCallCount == 1)
    }

    @MainActor
    @Test func selectCategoryTwiceTogglesItOff() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = []
        let category = CategoriesElement(id: 10, name: "Meuble")

        // When
        await sut.selectCategory(category)
        await sut.selectCategory(category)

        // Then
        #expect(sut.selectedCategory == nil)
        // The last reset was called with no categoryID (filter cleared).
        #expect(interactorSpy.lastResetCategoryID == .some(nil))
    }

    // MARK: - loadNextPage

    @MainActor
    @Test func loadNextPageAppendsNewItemsViaInteractor() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = (1...5).map { ListingsItem.mocked(id: $0, categoryID: 10) }
        await sut.onAppear()
        let initialCount = sut.listingCardItems.count

        // When
        interactorSpy.stubbedItems = (1...10).map { ListingsItem.mocked(id: $0, categoryID: 10) }
        await sut.loadNextPage()

        // Then
        #expect(sut.listingCardItems.count > initialCount)
        #expect(interactorSpy.loadNextCallCount == 1)
    }

    @MainActor
    @Test func loadNextPageIsNoOpWhenInteractorHasNoMore() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = [.mocked()]
        await sut.onAppear()
        interactorSpy.hasMore = false
        let initialLoadNextCount = interactorSpy.loadNextCallCount

        // When
        await sut.loadNextPage()

        // Then
        #expect(interactorSpy.loadNextCallCount == initialLoadNextCount)
    }

    @MainActor
    @Test func loadNextPageSetsErrorStateOnFailure() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble"]
        interactorSpy.stubbedItems = (1...3).map { ListingsItem.mocked(id: $0, categoryID: 10) }
        await sut.onAppear()
        let countAfterFirstLoad = sut.listingCardItems.count

        // When
        interactorSpy.thrownError = NetworkError.APIResponse.unexpected
        await sut.loadNextPage()

        // Then
        #expect(sut.listingState == .error)
        #expect(sut.listingCardItems.count == countAfterFirstLoad)
    }
}
