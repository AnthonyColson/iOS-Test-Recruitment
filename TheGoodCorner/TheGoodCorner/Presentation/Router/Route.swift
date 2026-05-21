//
//  Route.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

public protocol Route: Hashable, Identifiable {
    associatedtype Body: View

    @ViewBuilder var view: Body { get }
}

public extension Route {
    var id: Self { self }
}
