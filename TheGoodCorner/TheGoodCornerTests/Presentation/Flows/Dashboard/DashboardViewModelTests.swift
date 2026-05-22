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
        #expect(sut.categoriesState == .loading)
        #expect(sut.listingState == .loading)
        #expect(sut.selectedCategory == nil)
        #expect(sut.allCategories.isEmpty)
        #expect(sut.listingCardItems.isEmpty)
    }

    // MARK: - loadData

    @Test(arguments: [
        (false, false, DashboardViewModel.CategoriesState.success, DashboardViewModel.ListingState.success),
        (true,  false, .error,   .success),
        (false, true,  .success, .error),
        (true,  true,  .error,   .error),
    ])
    func loadDataTransitionsStatesAccordingToInteractorOutcomes(
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
            interactorSpy.getListingsResponse = .mocked()
        }

        // When
        await sut.loadData()

        // Then
        #expect(sut.categoriesState == expectedCategoriesState)
        #expect(sut.listingState == expectedListingState)
    }

    // MARK: - loadItems mapping

    @Test func loadItemsMapsListingsToCardItemsAndResolvesCategoryName() async {
        // Given
        interactorSpy.getCategoriesResponse = [10: "Meuble", 20: "Sport"]
        interactorSpy.getListingsResponse = .mocked(
            items: [
                .mocked(id: 1, categoryID: 10, title: "Chair"),
                .mocked(id: 2, categoryID: 20, title: "Bike")
            ]
        )

        // When
        await sut.loadData()

        // Then
        #expect(sut.listingCardItems.count == 2)
        #expect(sut.listingCardItems.first { $0.id == 1 }?.category == "Meuble")
        #expect(sut.listingCardItems.first { $0.id == 2 }?.category == "Sport")
    }

    // MARK: - shouldTriggerReload

    @Test(arguments: [
        // (preselectedSameAsTapped, expectedResult, expectedSelectionIsNil)
        (false, true,  false),
        (true,  false, true),
    ])
    func shouldTriggerReloadTogglesAccordingToCurrentSelection(
        preselectSame: Bool,
        expectedResult: Bool,
        expectedSelectionIsNil: Bool
    ) {
        let category = CategoriesElement(id: 10, name: "Meuble")
        if preselectSame {
            _ = sut.shouldTriggerReload(with: category)
        }

        let result = sut.shouldTriggerReload(with: category)

        #expect(result == expectedResult)
        #expect((sut.selectedCategory == nil) == expectedSelectionIsNil)
    }

    // MARK: - reloadItems

    @Test(arguments: [
        (5,  true,  true,  DashboardViewModel.ListingState.loading),
        (5,  false, false, DashboardViewModel.ListingState.success),
        (20, true,  false, DashboardViewModel.ListingState.success),
    ])
    func reloadItemsContinuationLogic(
        itemsCount: Int,
        hasMore: Bool,
        expectedShouldContinue: Bool,
        expectedListingState: DashboardViewModel.ListingState
    ) async {
        // Given
        let items = (1...itemsCount).map { ListingsItem.mocked(id: $0, categoryID: 10) }
        interactorSpy.getListingsResponse = .mocked(hasMore: hasMore, items: items)
        let category = CategoriesElement(id: 10, name: "Meuble")
        sut.itemsTotal = 20
        sut.resetDeadLine()

        // When
        let shouldContinue = await sut.reloadItems(with: category)

        // Then
        #expect(shouldContinue == expectedShouldContinue)
        #expect(sut.listingState == expectedListingState)
    }

    @Test func reloadItemsInteractorErrorReturnsFalseAndSetsErrorState() async {
        // Given
        interactorSpy.getListingsError = NetworkError.APIResponse.unexpected
        sut.itemsTotal = 20
        sut.resetDeadLine()

        // When
        let shouldContinue = await sut.reloadItems(with: CategoriesElement(id: 10, name: "Meuble"))

        // Then
        #expect(shouldContinue == false)
        #expect(sut.listingState == .error)
    }
}
