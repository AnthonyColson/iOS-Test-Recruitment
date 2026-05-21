//
//  RouterView.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

public struct RouterView<T: Route, Root: View>: View {

    @StateObject private var router: Router<T>
    private let root: () -> Root

    public init(
        _ router: Router<T> = Router<T>(),
        @ViewBuilder root: @escaping () -> Root
    ) {
        self._router = StateObject(wrappedValue: router)
        self.root = root
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: T.self) { route in
                    route.view
                }
        }
        .sheet(item: $router.sheet) { route in
            route.view
        }
        .fullScreenCover(item: $router.fullCover) { route in
            route.view
        }
        .environmentObject(router)
    }
}
