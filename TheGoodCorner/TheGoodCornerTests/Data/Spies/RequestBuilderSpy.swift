//
//  RequestBuilderSpy.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation
@testable import TheGoodCorner

final class RequestBuilderSpy: @unchecked Sendable, RequestBuilderProtocol {
    
    var mockedBuildAPIRequestError: NetworkError.APIRequest?
    var mockedURLRequest: URLRequest?
    var buildRequestCalled = false
    func build(baseURL: URL, endpoint: TheGoodCorner.Endpoint) throws -> URLRequest {
        buildRequestCalled = true
        if let mockedBuildAPIRequestError {
            throw mockedBuildAPIRequestError
        }
        return mockedURLRequest!
    }
    
    
    var mockedUrlError: NetworkError.APIRequest?
    var mockedURL: URL?
    var getUrlCalled = false
    func getURL(baseURL: URL, endpoint: TheGoodCorner.Endpoint) throws -> URL {
        getUrlCalled = true
        if let mockedUrlError {
            throw mockedUrlError
        }
        return mockedURL!
    }
    
    func getPath(from endpointPath: TheGoodCorner.EndpointPath) -> String {
        String()
    }
}
