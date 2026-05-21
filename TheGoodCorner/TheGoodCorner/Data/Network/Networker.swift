//
//  Networker.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

public protocol Networker: Sendable {
    func loadData(from request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: Networker {
    public func loadData(from request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request)
    }
}
