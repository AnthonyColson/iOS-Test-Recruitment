//
//  AppRoute.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

enum AppRoute: Route {
    case details(item: ListingCardIViewModel)
    case showcase

    @ViewBuilder
    var view: some View {
        switch self {
        case .details(let item):
            DetailsViewLoader(item: item)
        case .showcase:
            DesignSystemShowcaseView()
        }
    }
}

private struct DetailsViewLoader: View {
    let item: ListingCardIViewModel
    @EnvironmentObject private var factory: ViewModelFactory

    var body: some View {
        DetailsView(viewModel: factory.makeDetailsViewModel(item: item))
    }
}
