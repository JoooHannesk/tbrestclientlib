//
//  rest-client.swift
//
//
//  Created by Johannes Kinzig on 30.07.24.
//
// Rest client for Thingsboard Client API (Library)

import Foundation

// MARK: - HTTP request (generalized)

enum TBHTTPClientRequestError: Error {
    case badURL
    case improperPayloadDataFormat
    case emptyResponsePayloadData
    case httpRequestFailure
    case emptyLogin
    case badLogin
    case unknownError
    case tbAppError(apperror: TBAppError)
    case tbAppResponseUndefinedDataModelMatch
}

enum SupportedHTTPMethods: String {
    case post = "POST"
    case get = "GET"
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
     - Parameter completionHandler: function wich is executed once request completes of type (Result<TBDataModels, TBHTTPClientRequestError>) -> Void)
     - Note: Result type contains a TBDataModels conforming type in case of success and an item of TBHTTPClientRequestError as error description
     */
    func doHttpRequest(from urlString: String,
                        usingMethod httpMethod: SupportedHTTPMethods,
                        withhttpHeaders httpHeaders: Dictionary<String, String>?,
                        withPayload payload: Dictionary<String, Any>?,
                        expectedTBResponseObject responseObject: TBDataModel.Type,
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
            if let error = error {
                // TODO: add logger
                print("HTTP request failed: \(error)")
                completionHandler(.failure(.httpRequestFailure))
            } else if let responseData = responseData {
                let responseDataResultDict = self.convertResponseToTbDataModelObject(responseData, expectedResponseObject: responseObject)
                completionHandler(responseDataResultDict)
            }
        }
        requestTask.resume()
    }
    
    // MARK: - Helper Methods
    
    /**
     Convert server response from json string to dictionary
     - Parameter responseStr: json string from webserver as response to http request
     - Returns: Result object containing dictionary
     */
    fileprivate func convertResponseToTbDataModelObject(_ responseData: Data, expectedResponseObject: TBDataModel.Type)
    -> Result<TBDataModel, TBHTTPClientRequestError> {
        guard let responseDataStr = String(data: responseData, encoding: .utf8) else {
            return .failure(.improperPayloadDataFormat)
        }
        guard !responseDataStr.isEmpty else {
            return .failure(.emptyResponsePayloadData)
        }
        if let dictionary = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
            let resultDataModelObject = convertDictToDataModelObject(dictionary, expectedResponseObject: expectedResponseObject)
            return resultDataModelObject
        } else {
            // TODO: – add logger here
            print("Improper payload response data format: \(responseDataStr)")
            return .failure(.improperPayloadDataFormat)
        }
    }
    
    
    fileprivate func convertDictToDataModelObject(_ responseDict: Dictionary<String, Any>, expectedResponseObject: TBDataModel.Type)
    -> Result<TBDataModel, TBHTTPClientRequestError> {
        var localError: String = ""
        let decoder = JSONDecoder()
        // try converting to data model object
        do {
            let tbResponse = try decoder.decode(expectedResponseObject.self, from: JSONSerialization.data(withJSONObject: responseDict))
            return .success(tbResponse)
        } catch {
            localError = "\(error.localizedDescription): \(error)\nAPI Response: \(responseDict)\n"
        }
        // try converting to app error model object
        do {
            let tbapperror = try decoder.decode(TBAppError.self, from: JSONSerialization.data(withJSONObject: responseDict))
            return .failure(.tbAppError(apperror: tbapperror))
        } catch {
            localError += "\(error.localizedDescription): \(error)\nAPI Response: \(responseDict)\n"
        }
        // TODO: – add logger here
        print(localError)
        return .failure(.tbAppResponseUndefinedDataModelMatch)
    }
    
}
