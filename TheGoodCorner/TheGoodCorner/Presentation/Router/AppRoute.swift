//
//  AppRoute.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

enum AppRoute: Route {
    case details
    case showcase

    @ViewBuilder
    var view: some View {
        switch self {
        case .details: EmptyView()
        case .showcase: DesignSystemShowcaseView()
        }
    }
}
