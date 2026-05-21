//
//  Endpoint+Mock.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation
@testable import TheGoodCorner

extension Endpoint {
    static func mocked() -> Endpoint {
        Endpoint(path: .init(absolute: "https://google.com"))
    }
}
