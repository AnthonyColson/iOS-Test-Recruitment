//
//  NetworkerService.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

public protocol NetworkerService: AnyObject, Sendable {
    func request<T: Decodable>(baseURL: URL, endpoint: Endpoint) async throws -> T
}

public final class SessionDelegate: NSObject, URLSessionDelegate {}
public final class NetworkerSession {
    public static let shared = URLSession(configuration: .default,
                                          delegate: SessionDelegate(),
                                          delegateQueue: nil)
}

public final class NetworkerServiceImpl: NetworkerService {
    let networker: any Networker
    let requestBuilder: any RequestBuilderProtocol
    
    init(networker: any Networker,
         requestBuilder: any RequestBuilderProtocol) {
        self.networker = networker
        self.requestBuilder = requestBuilder
    }
    
    
    public func request<T: Decodable>(baseURL: URL, endpoint: Endpoint) async throws -> T {
        do {
            guard let urlRequest = try? requestBuilder.build(baseURL: baseURL, endpoint: endpoint) else {
                throw NetworkError.APIRequest.couldNotCreateRequest()
            }
            
            let (data, response) = try await networker.loadData(from: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.APIResponse.unexpected
            }
            
            if (300..<600).contains(httpResponse.statusCode) {
                throw NetworkError.APIResponse.statusCodeError(code: httpResponse.statusCode)
            } else {
                return try await decode(data: data)
            }
        }
    }
    
    public func decode<T: Decodable>(data: Data) async throws -> T {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw NetworkError.APIResponse.dtoMismatch
        }
    }
}
