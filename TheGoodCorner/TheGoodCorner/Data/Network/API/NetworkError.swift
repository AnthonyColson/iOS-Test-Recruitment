//
//  NetworkError.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

public protocol ReportableError: Error {
    var domain: String { get }
    var name: String { get }
    var code: Int { get }
}

public extension ReportableError {
    var debugDescription: String { name }
}

public enum NetworkError {
    public enum APIResponse: ReportableError {
        case statusCodeError(code: Int)
        case dtoMismatch
        case unexpected
    }
    
    public enum Network {
        case notConnected
    }
    
    public enum APIRequest: ReportableError {
        case couldNotCreateRequest(call: String = #function)
        case couldNotCreateData(call: String = #function)
    }
}

public extension NetworkError.APIResponse {
    var domain: String { "API_RESPONSE" }
    
    var name: String {
        switch self {
        case .statusCodeError:
            "Status_Code_Error"
        case .dtoMismatch:
            "DTO_Mismatch"
        case .unexpected:
            "Unexpected"
        }
    }
    
    var code: Int {
        switch self {
        case .statusCodeError:
            10101
        case .dtoMismatch:
            10102
        case .unexpected:
            10103
        }
    }
    
    var debugDecription: String {
        switch self {
        case .statusCodeError(let code):
            "Backend respond with status code error: \(code)"
        case .dtoMismatch:
            "Could not parse response body to dto"
        case .unexpected:
            "Unexpected"
        }
    }
}

public extension NetworkError.APIRequest {
    var domain: String { "API_REQUEST" }
    
    var name: String {
        switch self {
        case .couldNotCreateRequest:
            "Could_Not_Create_Request"
        case .couldNotCreateData:
            "Could_Not_Create_Data"
        }
    }
    
    var code: Int {
        switch self {
        case .couldNotCreateRequest:
            10208
        case .couldNotCreateData:
            10209
        }
    }
    
    var debugDecription: String {
        switch self {
        case .couldNotCreateRequest(let call):
            "Could not create request for API call from method: \(call.uppercased())"
        case .couldNotCreateData(let call):
            "Could not create data for API call from method: \(call.uppercased())"
        }
    }
}
