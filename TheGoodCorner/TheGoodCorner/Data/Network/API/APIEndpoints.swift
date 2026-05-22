//
//  APIEndpoints.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import  Foundation

public struct APIEndpoints {
    static let baseURLString = "http://localhost:8080"
    
    static func getBaseUrl() throws -> URL {
        guard let baseURL = URL(string: baseURLString) else {
            throw NetworkError.APIRequest.couldNotCreateRequest()
        }
        return baseURL
    }
    
    static func getListings(pagination: (page: Int, limit: Int)?, query: String?) -> Endpoint {
        var queryParams: [String: Any] = [:]
        if let pagination {
            queryParams["page"]  = pagination.page
            queryParams["limit"] = pagination.limit
        }
        if let query {
            queryParams["query"] = query
        }
        return Endpoint(path: EndpointPath(absolute: "/listings"), method: .get, queryParameters: queryParams)
    }
    
    static func getCatgories() -> Endpoint {
        Endpoint(path: EndpointPath(absolute: "/categories"), method: .get)
    }
}
