//
//  DashbaordViewModel.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Combine
import Foundation

final class DashbaordViewModel: ObservableObject {
    
    enum CategoriesState {
        case loading
        case success
        case error
    }
    
    enum ListingState {
        case loading
        case success
        case error
    }
    
    // MARK: Dependencies
    
    private let interactor: any ListingsInteractor
    
    // MARK: Properties
    
    @Published var selectedCategory: CategoriesElement? = nil
    @Published var categoriesState: CategoriesState = .loading
    @Published var listingState: ListingState = .loading
    
    private let itemsShownOnPage = 20
    private var currentPage = 1
    private var itemsAlreadyFetched = 0
    private var deadline = Date().addingTimeInterval(30)
    
    var itemsTotal = 0

    var allCategories: Categories = [:]
    var listingCardItems: [ListingCardItem] = []
    
    // MARK: Init
    
    init(interactor: any ListingsInteractor) {
        self.interactor = interactor
    }
    
    // MARK: Public functions
    
    @MainActor
    func loadData() async {
        do {
            categoriesState = .loading
            allCategories = try await interactor.getCategories()
            categoriesState = .success
        } catch {
            categoriesState = .error
        }
        
        await loadItems()
    }
    
    @MainActor
    func loadItems() async {
        do {
            let listing = try await interactor.getListings(pagination: (page: currentPage, limit: itemsShownOnPage), query: nil)
            itemsTotal = listing.total
            updateListCardItems(with: listing.items, forReload: false)
            listingState = .success
        } catch {
            listingState = .error
        }
    }
    
    func shouldTriggerReload(with selectedCategory: CategoriesElement) -> Bool {
        self.currentPage = 1
        self.itemsAlreadyFetched = 0
        if self.selectedCategory?.id != selectedCategory.id {
            self.selectedCategory = selectedCategory
            return true
        } else {
            self.selectedCategory = nil
            return false
        }
    }
    
    @MainActor
    func reloadItems(with selectedCategory: CategoriesElement) async -> Bool {
        if Date() > deadline || itemsAlreadyFetched >= itemsTotal {
            listingState = .success
            return false
        }
        
        do {
            listingState = .loading
            let listing = try await interactor.getListings(pagination: (page: currentPage, limit: itemsShownOnPage), query: nil)
            itemsAlreadyFetched += listing.items.count
            listingCardItems = listingCardItems.filter { $0.category == selectedCategory.name }
            updateListCardItems(with: listing.items.filter { $0.categoryID == selectedCategory.id }, forReload: true)
            if listingCardItems.count < itemsShownOnPage  {
                if listing.hasMore {
                    currentPage += 1
                    return true
                } else {
                    listingState = .success
                    return false
                }
            } else {
                listingState = .success
                return false
            }
        } catch {
            listingState = .error
            return false
        }
    }
    
    @MainActor func updateListCardItems(with listingItems: [ListingsItem], forReload: Bool) {
        var tmp: [ListingCardItem] = []
        listingItems.forEach { [weak self] elem in
            guard let self else { return }
            
            let category = self.allCategories[elem.categoryID]
            let listingCardItem = ListingCardItem(id: elem.id, imageURL: elem.imagesURL.small, title: elem.title, price: elem.price, category: category, isUrgent: elem.isUrgent)
            tmp.append(listingCardItem)
        }
        if forReload {
            listingCardItems.appendUnique(contentsOf: tmp)
        } else {
            listingCardItems = tmp
        }
    }
    
    @MainActor func tapOnCategory(with selectedCategory: CategoriesElement) async {
        resetDeadLine()
        if shouldTriggerReload(with: selectedCategory) {
            while await reloadItems(with: selectedCategory) {
                continue
            }
        } else {
            await loadItems()
        }
    }
    
    func resetDeadLine() {
        deadline = Date().addingTimeInterval(30)
    }
}
