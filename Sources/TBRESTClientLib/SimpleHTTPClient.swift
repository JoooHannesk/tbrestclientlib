//
//  SimpleHTTPClient.swift
//
//
//  Created by Johannes Kinzig on 30.07.24.
//
// Rest client for Thingsboard Client API (Library)

import Foundation

// MARK: - HTTP request (generalized)

public enum TBHTTPClientRequestError: Error {
    case badURL
    case improperPayloadDataFormat
    case httpRequestFailure
    case emptyLogin
    case badLogin
    case tbAppError(appError: TBAppError)
    case tbGenericError(genericError: TBAppError)
}

enum SupportedHTTPMethods: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

class SimpleHTTPClient {
    
    private var sessionHandler: URLSessionProtocol
    
    init(sessionHandler: URLSessionProtocol = URLSession.shared) {
        self.sessionHandler = sessionHandler
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
                       expectedTBResponseType responseType: TBDataModel.Type,
                       completionHandler: @escaping (Result<TBDataModel, TBHTTPClientRequestError>) -> Void)
    -> Void {
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(.badURL))
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
                completionHandler(.failure(.improperPayloadDataFormat))
                return
            }
        }
        
        let requestTask = sessionHandler.dataTask(with: request) { (responseData, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                // TODO: add logger
                print("HTTP status response: \(httpResponse.statusCode)")
            }
            if let error = error {
                // TODO: add logger
                print("HTTP request failed: \(error)")
                completionHandler(.failure(.httpRequestFailure))
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
    fileprivate func convertResponseToTbDataModelObject(_ responseData: Data, expectedResponseType: TBDataModel.Type)
    -> Result<TBDataModel, TBHTTPClientRequestError> {
        guard let responseDataStr = String(data: responseData, encoding: .utf8) else {
            return .failure(.improperPayloadDataFormat)
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
            return .failure(.tbAppError(appError: tbapperror))
        } catch {
            localError += "\(error.localizedDescription): \(error)\nAPI Response: \(responseDataStr)\n"
        }
        // TODO: – add logger here
        print(localError)
        // create error object to keep in convention with other errors – even delivered in other format from server
        let genErr = TBAppError(status: 999, message: responseDataStr, errorCode: 999, timestamp: 0)
        return .failure(.tbGenericError(genericError: genErr))
    }
}
