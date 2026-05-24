//
//  NetworkerSpy.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation
@testable import TheGoodCorner

final class NetworkerSpy: @unchecked Sendable, Networker {
    
    var dataAndResponse: (Data, URLResponse)?
    var error: Error?
    var isNetworkerCalled: Bool = false
    
    init(dataAndResponse: (Data, URLResponse)? = nil, error: Error? = nil) {
        self.dataAndResponse = dataAndResponse
        self.error = error
    }
    
    func loadData(from request: URLRequest) async throws -> (Data, URLResponse) {
        isNetworkerCalled = true
        guard let result = dataAndResponse else {
            if let networkError = error {
                throw networkError
            }
            throw NetworkError.APIResponse.unexpected
        }
        return result
    }
}
