//
//  NetworlServiceTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("NetworkServicesTests")
final class NetworkServiceTests {
    private var sut: NetworkerService
    private var networkerSpy: NetworkerSpy
    private var requestBuilderSpy: RequestBuilderSpy
    
    init() {
        self.networkerSpy = NetworkerSpy()
        self.requestBuilderSpy = RequestBuilderSpy()
        self.sut = NetworkerServiceImpl(networker: networkerSpy, requestBuilder: requestBuilderSpy)
    }
    
    @MainActor @Test func endpointBuildFailed() async {
        // Given
        let endpoint = Endpoint.mocked()
        requestBuilderSpy.mockedBuildAPIRequestError = NetworkError.APIRequest.couldNotCreateRequest()
        
        // When
        do {
            let _: EmptyDTO = try await sut.request(baseURL: URL(string: "https://google.com")!, endpoint: endpoint)
            Issue.record("Should not go here")
        } catch let error {
            #expect(requestBuilderSpy.buildRequestCalled)
            #expect(error is NetworkError.APIRequest)
        }
    }
    
    @MainActor @Test func endpointRequestFailed() async {
        // Given
        let endpoint = Endpoint.mocked()
        let url = URL(string: "https://google.com")!
        requestBuilderSpy.mockedURLRequest = URLRequest(url: url)
        networkerSpy.error = NetworkError.APIResponse.dtoMismatch
        
        // When
        do {
            let _: EmptyDTO = try await sut.request(baseURL: url, endpoint: endpoint)
            Issue.record("Should not go here")
        } catch let error {
            #expect(networkerSpy.isNetworkerCalled)
            #expect(requestBuilderSpy.buildRequestCalled)
            #expect(error is NetworkError.APIResponse)
        }
    }
    
    @MainActor
    @Test(arguments: [309, 404, 500])
    func endpointRequestWithStatusCodeFailed(statusCode: Int) async {
        // Given
        let endpoint = Endpoint.mocked()
        let url = URL(string: "https://google.com")!
        requestBuilderSpy.mockedURLRequest = URLRequest(url: url)
        networkerSpy.dataAndResponse = (Data(), HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:])!)
        
        // When
        do {
            let _: EmptyDTO = try await sut.request(baseURL: url, endpoint: endpoint)
            Issue.record("Should not go here")
        } catch let error {
            #expect(networkerSpy.isNetworkerCalled)
            #expect(requestBuilderSpy.buildRequestCalled)
            #expect(error is NetworkError.APIResponse)
        }
    }
    
    @MainActor
    @Test(arguments: [200, 201, 204])
    func endpointRequestWithDTOMitmatchFailed(statusCode: Int) async {
        // Given
        let endpoint = Endpoint.mocked()
        let url = URL(string: "https://google.com")!
        requestBuilderSpy.mockedURLRequest = URLRequest(url: url)
        networkerSpy.dataAndResponse = (Data(), HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:])!)
        
        // When
        do {
            let _: EmptyDTO = try await sut.request(baseURL: url, endpoint: endpoint)
            #expect(networkerSpy.isNetworkerCalled)
        } catch let error {
            #expect(networkerSpy.isNetworkerCalled)
            #expect(requestBuilderSpy.buildRequestCalled)
            #expect(error is NetworkError.APIResponse)
        }
    }
    
    @MainActor
    @Test(arguments: [200, 201, 204])
    func endpointRequestSuccess(statusCode: Int) async throws {
        // Given
        let endpoint = Endpoint.mocked()
        let url = URL(string: "https://google.com")!
        requestBuilderSpy.mockedURLRequest = URLRequest(url: url)
        let data = try JSONEncoder().encode(EmptyDTO())
        networkerSpy.dataAndResponse = (data, HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:])!)
        
        // When
        do {
            let _: EmptyDTO = try await sut.request(baseURL: url, endpoint: endpoint)
            #expect(networkerSpy.isNetworkerCalled)
        } catch {
            Issue.record("Should not go here")
        }
    }
}
