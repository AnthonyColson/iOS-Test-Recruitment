//
//  ViewModelFactory.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation
import Combine

final class ViewModelFactory: ObservableObject {

    // MARK: - Dependencies

    private let listingsInteractor: any ListingsInteractor

    // MARK: - Init

    init(listingsInteractor: any ListingsInteractor) {
        self.listingsInteractor = listingsInteractor
    }

    // MARK: - View model builders

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(interactor: listingsInteractor)
    }

    func makeDetailsViewModel(item: ListingCardIViewModel) -> DetailsViewModel {
        DetailsViewModel(item: item)
    }
}

// MARK: - Production wiring

extension ViewModelFactory {
    static func live() -> ViewModelFactory {
        let networkService = NetworkerServiceImpl()
        let repository = ListingsRepositoryImpl(networkService: networkService)
        let interactor = ListingInteractorImpl(repository: repository)
        return ViewModelFactory(listingsInteractor: interactor)
    }
}
