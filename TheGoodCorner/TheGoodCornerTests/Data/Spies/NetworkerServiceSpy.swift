//
//  NetworkerServiceSpy.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation
@testable import TheGoodCorner


final class NetworkerServiceSpy: @unchecked Sendable, NetworkerService {

    // MARK: - Stubs

    var requestResponse: Any?
    var requestError: Error?
    var isRequestCalled: Bool = false

    // MARK: - NetworkerService

    func request<T: Decodable>(baseURL: URL, endpoint: Endpoint) async throws -> T {
        isRequestCalled = true
        guard let result = requestResponse as? T else {
            if let requestError {
                throw requestError
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }
}
