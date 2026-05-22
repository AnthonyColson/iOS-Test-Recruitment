//
//  ViewModelFactory.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//


final class ViewModelFactory {
    private static let networkService: any NetworkerService = NetworkerServiceImpl()
    
    
    static func makeListingRepository() -> any ListingsRepository {
        ListingsRepositoryImpl(networkService: networkService)
    }
    
    static func makeListingInteractor() -> any ListingsInteractor {
        ListingInteractorImpl(repository: makeListingRepository())
    }
    
    static func makeDashboardViewModel() -> DashbaordViewModel {
        DashbaordViewModel(interactor: makeListingInteractor())
    }

    static func makeDetailsViewModel(item: ListingCardItem) -> DetailsViewModel {
        DetailsViewModel(item: item)
    }
}
