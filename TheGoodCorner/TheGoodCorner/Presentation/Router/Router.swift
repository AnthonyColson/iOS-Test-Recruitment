//
//  Router.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI
import Combine

public final class Router<T: Route>: ObservableObject {

    // MARK: - State

    @Published public var path: NavigationPath

    @Published public var sheet: T?

    @Published public var fullCover: T?

    // MARK: - Init

    public init(path: NavigationPath = NavigationPath()) {
        self.path = path
    }

    // MARK: - Navigation

    public func navigate(to route: T, mode: NavigationMode = .push) {
        switch mode {
        case .push:
            path.append(route)
        case .sheet:
            sheet = route
        case .fullCover:
            fullCover = route
        }
    }

    // MARK: - Pop

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    // MARK: - Dismiss

    public func dismissSheet() {
        sheet = nil
    }

    public func dismissFullCover() {
        fullCover = nil
    }

    public func dismiss() {
        sheet = nil
        fullCover = nil
    }

    public func reset() {
        dismiss()
        popToRoot()
    }
}
