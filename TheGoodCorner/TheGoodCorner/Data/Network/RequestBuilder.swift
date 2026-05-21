//
//  RequestBuilder.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

public protocol RequestBuilderProtocol: Sendable {
    func build(baseURL: URL, endpoint: Endpoint) throws -> URLRequest
    func getURL(baseURL: URL, endpoint: Endpoint) throws -> URL
    func getPath(from endpointPath: EndpointPath) -> String
}

public final class RequestBuilder: RequestBuilderProtocol {
    public func build(baseURL: URL, endpoint: Endpoint) throws -> URLRequest {
        let url = try getURL(baseURL: baseURL, endpoint: endpoint)
        
        var urlRequest = URLRequest(url: url, cachePolicy: endpoint.cachePolicy)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.allHTTPHeaderFields = endpoint.headerParameters
        
        if !endpoint.bodyParamaters.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: endpoint.bodyParamaters, options: .sortedKeys)
        }
        
        urlRequest.httpMethod = endpoint.method.rawValue
        return urlRequest
    }
    
    public func getURL(baseURL: URL, endpoint: Endpoint) throws -> URL {
        let baseURL = baseURL.absoluteString.last != "/" ? baseURL.absoluteString + "/" : baseURL.absoluteString
        let path = getPath(from: endpoint.path)
        let url = baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: url) else { throw NSError(domain: "200", code: 201) }
        
        var urlQueryItems = [URLQueryItem]()
        
        endpoint.queryParameters.sorted(by: { $0.key < $1.key }).forEach { queryParameter in
            if let values = queryParameter.value as? [Any] {
                for value in values {
                    urlQueryItems.append(URLQueryItem(name: queryParameter.key, value: "\(value)"))
                }
            } else {
                urlQueryItems.append(URLQueryItem(name: queryParameter.key, value: "\(queryParameter.value)"))
            }
        }
        
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let urlUnwrap = urlComponents.url else { throw NSError(domain: "", code: 200) }
        return urlUnwrap
    }
    
    public func getPath(from endpointPath: EndpointPath) -> String {
        if endpointPath.components.isEmpty {
            return endpointPath.absolute
        } else {
            return String(format: endpointPath.absolute, arguments: endpointPath.components)
        }
    }
}
