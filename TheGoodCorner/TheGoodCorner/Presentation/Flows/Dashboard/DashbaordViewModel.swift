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

    @Published var searchText: String = ""
    @Published var debouncedText: String = ""

    // MARK: - Configuration

    /// Default number of items targeted on the initial load and on filter changes.
    private let minItemCount = 10

    // MARK: - Private state

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(interactor: any ListingsInteractor) {
        self.interactor = interactor
    }

    // MARK: - Public intents

    /// Initial load when the dashboard appears. Idempotent — already-loaded
    /// items are kept (e.g. on returning from the details screen).
    @MainActor
    func onAppear() async {
        bindSearchDebounce()
        guard listingCardItems.isEmpty else { return }
        await loadCategories()
        await reloadListings()
    }

    /// Tap on a category chip. Toggles the filter and reloads.
    @MainActor
    func selectCategory(_ category: CategoriesElement) async {
        if selectedCategory?.id == category.id {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
        await reloadListings()
    }

    /// Called after the debounced search text changes.
    @MainActor
    func searchItemsFromText() async {
        await reloadListings()
    }

    /// Triggered by scroll-position approaching the bottom.
    @MainActor
    func loadNextPage() async {
        guard !isLoadingMore, interactor.hasMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let items = try await interactor.loadNextListings()
            updateListCardItems(items)
        } catch let urlError as URLError where urlError.code == .cancelled {
            // Task cancelled
        }  catch {
            listingState = .error
        }
    }

    /// Manual retry after an error.
    @MainActor
    func retry() async {
        if categoriesState == .error {
            await loadCategories()
        }
        await reloadListings()
    }

    // MARK: - Private

    @MainActor
    private func reloadListings() async {
        listingState = .loading

        interactor.resetListings(
            categoryID: selectedCategory?.id,
            query: debouncedText.isEmpty ? nil : debouncedText
        )

        do {
            let items = try await interactor.loadEnoughListings(minItems: minItemCount)
            updateListCardItems(items)
        } catch {
            listingState = .error
        }
    }

    private func updateListCardItems(_ items: [ListingsItem]) {
        listingCardItems = items.map { elem in
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
        listingState = listingCardItems.isEmpty ? .empty : .success
    }

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

    private func bindSearchDebounce() {
        guard subscriptions.isEmpty else { return }
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.debouncedText = newValue
            }
            .store(in: &subscriptions)
    }
}
