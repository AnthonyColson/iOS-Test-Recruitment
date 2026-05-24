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
    
    init(networker: any Networker = NetworkerSession.shared,
         requestBuilder: any RequestBuilderProtocol = RequestBuilder()) {
        self.networker = networker
        self.requestBuilder = requestBuilder
    }
    
    
    public func request<T: Decodable>(baseURL: URL, endpoint: Endpoint) async throws -> T {
        #if DEBUG
        let startedAt = Date()
        print("➡️ [Networker] \(endpoint.method.rawValue) \(baseURL.absoluteString) path=\(endpoint.path.absolute) expecting=\(T.self)")
        #endif

        do {
            guard let urlRequest = try? requestBuilder.build(baseURL: baseURL, endpoint: endpoint) else {
                #if DEBUG
                print("❌ [Networker] Could not build URLRequest for path=\(endpoint.path.absolute)")
                #endif
                throw NetworkError.APIRequest.couldNotCreateRequest()
            }

            #if DEBUG
            print("📤 [Networker] URL=\(urlRequest.url?.absoluteString ?? "nil") headers=\(urlRequest.allHTTPHeaderFields ?? [:])")
            if let body = urlRequest.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                print("📤 [Networker] Body=\(bodyString)")
            }
            #endif

            let (data, response) = try await networker.loadData(from: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                #if DEBUG
                print("❌ [Networker] Unexpected response (not HTTPURLResponse)")
                #endif
                throw NetworkError.APIResponse.unexpected
            }

            #if DEBUG
            let elapsedMS = Int(Date().timeIntervalSince(startedAt) * 1000)
            print("📥 [Networker] status=\(httpResponse.statusCode) bytes=\(data.count) duration=\(elapsedMS)ms")
            if let bodyString = String(data: data, encoding: .utf8) {
                print("📥 [Networker] Body=\(bodyString)")
            }
            #endif

            if (300..<600).contains(httpResponse.statusCode) {
                #if DEBUG
                print("❌ [Networker] Status code error: \(httpResponse.statusCode)")
                #endif
                throw NetworkError.APIResponse.statusCodeError(code: httpResponse.statusCode)
            } else {
                do {
                    let decoded: T = try await decode(data: data)
                    #if DEBUG
                    print("✅ [Networker] Decoded as \(T.self)")
                    #endif
                    return decoded
                } catch {
                    #if DEBUG
                    print("❌ [Networker] DTO mismatch when decoding \(T.self): \(error)")
                    #endif
                    throw error
                }
            }
        }
    }
    
    public func decode<T: Decodable>(data: Data) async throws -> T {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch let error {
            #if DEBUG
            print("❌ [Decode] \(T.self) failed: \(error)")
            #endif
            throw NetworkError.APIResponse.dtoMismatch
        }
    }
}
