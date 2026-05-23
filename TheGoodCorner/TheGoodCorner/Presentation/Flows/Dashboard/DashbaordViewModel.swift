//
//  DashboardViewModel.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Combine
import Foundation

final class DashboardViewModel: ObservableObject {

    enum CategoriesState {
        case loading
        case success
        case error
    }

    enum ListingState {
        case empty
        case loading
        case success
        case error
    }

    // MARK: - Dependencies

    private let interactor: any ListingsInteractor

    // MARK: - Published state

    @Published private(set) var allCategories: Categories = [:]
    @Published private(set) var selectedCategory: CategoriesElement?
    @Published private(set) var listingCardItems: [ListingCardIViewModel] = []
    @Published private(set) var isLoadingMore: Bool = false
    
    @Published private(set) var categoriesState: CategoriesState = .loading
    @Published private(set) var listingState: ListingState = .loading
    
    @Published var searchText: String = String()
    @Published var debouncedText = String()

    // MARK: - Configuration

    /// Number of items fetched per server call.
    private let itemsPerPage = 10
    /// When a category is selected, target this many matching items before stopping.
    private let minItemsWhenFiltered = 10
    /// Safety cap to prevent unbounded pagination on a single user action.
    private var maxPageFetchPerLoad = 100

    // MARK: - Private state

    private var currentPage = 0
    private var hasMore = true
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(interactor: any ListingsInteractor) {
        self.interactor = interactor
    }

    // MARK: - Public intents

    /// Initial load when the dashboard appear
    @MainActor
    func onAppear() async {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newValue in
                self?.debouncedText = newValue
            } )
            .store(in: &subscriptions)
        
        guard listingCardItems.isEmpty else { return }
        await loadCategories()
        await fillUntilEnoughItems(target: itemsPerPage)
    }
    
    func searchItemsFromText() async {
        resetPagination()
        maxPageFetchPerLoad = 100
        
        await fillUntilEnoughItems(target: itemsPerPage)
    }

    /// Reset pagination properties and set or unset selectedCategory than load enough items
    @MainActor
    func selectCategory(_ category: CategoriesElement) async {
        resetPagination()
        
        if selectedCategory?.id == category.id {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }

        await self.fillUntilEnoughItems(target: self.minItemsWhenFiltered)
    }

    /// Triggered by scroll position approaching the end of the list.
    @MainActor
    func loadNextPage() async {
        guard !isLoadingMore, hasMore else { return }
        await fillUntilEnoughItems(target: displayedItemCount + itemsPerPage)
    }

    /// Manually retry after an error.
    @MainActor
    func retry() async {
        if categoriesState == .error {
            await loadCategories()
        }
        await fillUntilEnoughItems(target: itemsPerPage)
    }

    // MARK: - Derived state

    /// Number of items currently shown for a given category to the user.
    var displayedItemCount: Int {
        guard let selectedCategory else { return listingCardItems.count }
        return listingCardItems.filter { $0.category == selectedCategory.name }.count
    }

    // MARK: - Internal pagination loop

    /// Keeps fetching pages until any of the stop conditions is met:
    /// - we have at least `target` items matching the current filter
    /// - the server has no more pages (`hasMore == false`)
    /// - the safety cap is reached
    /// - the task is cancelled (e.g. another `selectCategory` was triggered)
    /// - a fetch errors out
    @MainActor
    private func fillUntilEnoughItems(target: Int) async {
        var iterationsLeft = maxPageFetchPerLoad

        while displayedItemCount < target && hasMore && iterationsLeft > 0 {
            guard !Task.isCancelled else { return }
            iterationsLeft -= 1
            await fetchNextPage()
            if listingState == .error { return }
        }
    }

    @MainActor
    private func fetchNextPage() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            currentPage += 1
            let page = try await interactor.getListings(pagination: (page: currentPage, limit: itemsPerPage), query: debouncedText.isEmpty ? nil : debouncedText)
            maxPageFetchPerLoad = page.total / page.limit
            hasMore = page.hasMore
            if let selectedCategory {
                let filteredList = page.items.filter { $0.categoryID == selectedCategory.id }
                appendItems(from: filteredList)
            } else {
                appendItems(from: page.items)
            }
            listingState = listingCardItems.isEmpty ? .empty : .success
        } catch is CancellationError {
            //currentPage -= 1
        } catch {
            currentPage -= 1
            listingState = .error
        }
    }
    
    private func resetPagination() {
        hasMore = true
        currentPage = 0
        listingCardItems = []
    }
    
    /// load of categories return as dict
    @MainActor
    private func loadCategories() async {
        categoriesState = .loading
        do {
            allCategories = try await interactor.getCategories()
            categoriesState = .success
        } catch {
            categoriesState = .error
        }
    }

    @MainActor
    private func appendItems(from listingItems: [ListingsItem]) {
        let newCards = listingItems.map { elem in
            ListingCardIViewModel(
                id: elem.id,
                imagesURL: elem.imagesURL,
                title: elem.title,
                description: elem.description,
                price: elem.price,
                category: allCategories[elem.categoryID],
                isUrgent: elem.isUrgent
            )
        }
        listingCardItems.appendUnique(contentsOf: newCards)
    }
}
