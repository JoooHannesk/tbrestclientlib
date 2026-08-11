//
//  SimpleHTTPClient.swift
//
//
//  Created by Johannes Kinzig on 30.07.24.
//
// Rest client for Thingsboard Client API (Library)

import Foundation
import OSLog

// MARK: - HTTP request (generalized)

/// Errors originating from the local system or transport layer, e.g. a malformed URL,
/// a failed HTTP request (host unreachable, no internet connection) or a server response
/// which could not be decoded.
public enum TBSystemError: Error, Equatable {
    case badURL
    case improperPayloadDataFormat
    case httpRequestFailure
    case emptyLogin
    case badLogin
    /// The server responded, but the body was neither the expected data model nor a ``TBAppError``.
    /// The raw response body is attached for diagnostics.
    case undecodableResponse(body: String)
}

/// Top-level request error, separating the two error domains:
/// ``api(_:)`` carries an error object provided by the ThingsBoard server (e.g. wrong login),
/// ``system(_:)`` carries a local system/transport error (e.g. no internet connection).
public enum TBHTTPClientRequestError: Error, Equatable {
    case api(TBAppError)
    case system(TBSystemError)
}

enum SupportedHTTPMethods: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

class SimpleHTTPClient {
    
    private var sessionHandler: URLSessionProtocol
    private let logger: Logger?
    
    init(sessionHandler: URLSessionProtocol = URLSession.shared,  logger: Logger? = nil) {
        self.sessionHandler = sessionHandler
        self.logger = logger
    }
    
    /**
     Perform http request
     - Parameter from: (urlString), url as String
     - Parameter usingMethod: (httpMethod)  .get, .post
     - Parameter withhttpHeaders: (httpHeaders) http header as dictionary [String: String]
     - Parameter withPayload: (payload) payload in http request as dictionary [String: String]
     - Parameter expectedTBResponseType: expected TB Data Model instance Type
     - Parameter completionHandler: function wich is executed once request completes of type (Result<TBDataModels, TBHTTPClientRequestError>) -> Void)
     - Note: Result type contains a TBDataModels conforming type in case of success and an item of TBHTTPClientRequestError as error description
     */
    func doHttpRequest(from urlString: String,
                       usingMethod httpMethod: SupportedHTTPMethods,
                       withhttpHeaders httpHeaders: Dictionary<String, String>?,
                       withPayload payload: Dictionary<String, Any>?,
                       expectedTBResponseType responseType: any TBDataModel.Type,
                       completionHandler: @escaping (Result<any TBDataModel, TBHTTPClientRequestError>) -> Void)
    -> Void {
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(.system(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if let httpHeaders = httpHeaders {
            request.allHTTPHeaderFields = httpHeaders
        }
        
        if let httpBody = payload {
            do {
                let httpBody = try JSONSerialization.data(withJSONObject: httpBody, options: [])
                // print(String(data: httpBody, encoding: .utf8)!)
                request.httpBody = httpBody as Data  // typecast to 'Data' type
            } catch {
                completionHandler(.failure(.system(.improperPayloadDataFormat)))
                return
            }
        }
        
        let requestTask = sessionHandler.dataTask(with: request) { (responseData, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                self.logger?.info("TBRESTClientLib (system) HTTP status response: \(httpResponse.statusCode)")
            }
            if let error = error {
                self.logger?.error("TBRESTClientLib (system) HTTP request failed: \(error) - \(error.localizedDescription)")
                completionHandler(.failure(.system(.httpRequestFailure)))
            } else if let responseData = responseData {
                let responseDataResultDict = self.convertResponseToTbDataModelObject(responseData, expectedResponseType: responseType)
                completionHandler(responseDataResultDict)
            }
        }
        requestTask.resume()
    }
    
    // MARK: - Helper Methods
    
    /**
     Convert server response from json string to dictionary
     - Parameter responseData: json string from webserver as response to http request
     - Parameter expectedResponseType: expected TB Data Model instance Type
     - Returns: Result object containing dictionary
     */
    fileprivate func convertResponseToTbDataModelObject(_ responseData: Data, expectedResponseType: any TBDataModel.Type)
    -> Result<any TBDataModel, TBHTTPClientRequestError> {
        guard let responseDataStr = String(data: responseData, encoding: .utf8) else {
            return .failure(.system(.improperPayloadDataFormat))
        }
        
        var localError: String = ""
        let decoder = JSONDecoder()
        
        
        if responseData.isEmpty {
            // some server side responses are empty, therefore return an empty array of type Array<String>
            // empty responses do NOT indicate errors (at least not for the current API version in this lib)
            let emptyResponseArray: Array<String> = []
            return .success(emptyResponseArray)
        }
        
        // try converting to data model object
        do {
            let tbResponse = try decoder.decode(expectedResponseType.self, from: responseData)
            return .success(tbResponse)
        } catch {
            localError = "\(error.localizedDescription): \(error)\nAPI Response: \(responseDataStr)\n"
        }
        // try converting to app error model object
        do {
            let tbapperror = try decoder.decode(TBAppError.self, from: responseData)
            return .failure(.api(tbapperror))
        } catch {
            localError += "\(error.localizedDescription): \(error)\nAPI Response: \(responseDataStr)\n"
        }
        self.logger?.error("TBRESTClientLib (serverside) Error Message: \(localError)")
        return .failure(.system(.undecodableResponse(body: responseDataStr)))
    }
}
