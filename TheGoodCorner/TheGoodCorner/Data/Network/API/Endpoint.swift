//
//  Endpoint.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

public enum HTTPMethodType: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
    case patch  = "PATCH"
}

public struct EndpointPath {
    public var absolute: String
    public var components: [any CVarArg]
    
    public init(absolute: String, components: [any CVarArg] = []) {
        self.absolute = absolute
        self.components = components
    }
    
    public init(absolute: String, components: any CVarArg...) {
        self.absolute = absolute
        self.components = components
    }
}

public struct Endpoint {
    var path: EndpointPath
    var method: HTTPMethodType
    var queryParameters: [String: Any]
    var headerParameters: [String: String]
    var bodyParameters: [String: Any?]
    var cachePolicy: NSURLRequest.CachePolicy
    
    init(path: EndpointPath,
         method: HTTPMethodType = .get,
         queryParameters: [String : Any] = [:],
         headerParameters: [String : String] = [:],
         bodyParameters: [String : Any?] = [:],
         cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headerParameters = headerParameters
        self.bodyParameters = bodyParameters
        self.cachePolicy = cachePolicy
    }
}
