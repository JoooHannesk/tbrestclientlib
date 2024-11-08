//
//  TBApiHTTPRequest.swift
//  
//
//  Created by Johannes Kinzig on 06.09.24.
//

import Foundation

public class TBHTTPRequest {
    
    // MARK: - Properties
    var httpClient: SimpleHTTPClient
    private(set) var errorHandler: ((TBAppError) -> Void)? = nil
    
    // MARK: - Initialization
    init(httpSessionHandler: URLSessionProtocol) {
        httpClient = SimpleHTTPClient(sessionHandler: httpSessionHandler)
    }
    
    // MARK: - Implementation
    /**
     Register application error function – called when the TB server application responds with an error
     - Parameter errorHandler: callable which taks a single argument of type conforming to 'TBErrorDataModel' protocol
     - Returns: Void
     */
    public func registerAppErrorHandler(errorHandler: @escaping (TBAppError) -> Void) {
        self.errorHandler = errorHandler
    }
    
    /**
     TB API request simplifying each http call
     - Parameter fromEndpoint: Specify endpoint by giving the endpoint URL als 'TBApiEndpoints conforming protocol type'
     - Parameter usingMethod: Give the desired HTTP method, default: .post
     - Parameter withPayload: HTTP request payload given as Dictionary<String, Any>
     - Parameter authData: Authentication data
     - Parameter expectedTBResponseType: expected TB Data Model instance Type
     - Parameter successHandler: function to run in case of success
     */
    internal func tbApiRequest(fromEndpoint endpointURL: String,
                              usingMethod httpMethod: SupportedHTTPMethods = .post,
                              withPayload payload: Dictionary<String, Any>? = nil,
                              authToken authData: AuthLogin? = nil,
                              expectedTBResponseType responseType: TBDataModel.Type,
                              successHandler: @escaping (TBDataModel) -> Void)
    -> Void {
        var tbheaders = ["Content-Type": "application/json", "Accept": "application/json"]
        if let token = authData?.token { tbheaders["x-authorization"] = "Bearer \(token)" }
        httpClient.doHttpRequest(from: endpointURL, usingMethod: httpMethod, withhttpHeaders: tbheaders, withPayload: payload, expectedTBResponseType: responseType) { result in
            switch result {
            case .success(let responseObject):
                successHandler(responseObject)
            case .failure(let error):
                if case TBHTTPClientRequestError.tbAppError(let apperror) = error {
                    // run registered app error handler
                    self.errorHandler?(apperror)
                    // TODO: add logger
                    print("App Error Message: \(error)")
                } else if case TBHTTPClientRequestError.tbGenericError(let apperror) = error {
                    // run registered app error handler
                    self.errorHandler?(apperror)
                    // TODO: add logger
                    print("App Error Message: \(error)")
                } else {
                    // TODO: add logger
                    print("HTTP Request Error: \(error)")
                }
            }
        }
    }
}
