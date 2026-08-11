//
//  TBHTTPRequest+Async.swift
//
//
//  Async counterpart to tbApiRequest(...successHandler:).
//

import Foundation

extension TBHTTPRequest {

    /**
     TB API request (async) simplifying each http call

     Unlike the callback-based ``tbApiRequest(fromEndpoint:usingMethod:withPayload:authToken:expectedTBResponseType:successHandler:)``,
     failures are NOT routed to the handlers registered via ``registerErrorHandler(apiErrorHandler:systemErrorHandler:)``;
     they are thrown as ``TBHTTPClientRequestError`` instead.

     - Parameter fromEndpoint: Specify endpoint by giving the endpoint URL als 'TBApiEndpoints conforming protocol type'
     - Parameter usingMethod: Give the desired HTTP method, default: .post
     - Parameter withPayload: HTTP request payload given as Dictionary<String, Any>
     - Parameter authToken: Authentication data
     - Parameter expectedTBResponseType: expected TB Data Model instance Type
     - Returns: the decoded TB data model object
     - Throws: ``TBHTTPClientRequestError``
     - Note: If the package later opts into strict concurrency, revisit by marking `TBDataModel: Sendable`.
     */
    internal func tbApiRequest(fromEndpoint endpointURL: String,
                               usingMethod httpMethod: SupportedHTTPMethods = .post,
                               withPayload payload: Dictionary<String, Any>? = nil,
                               authToken authData: AuthLogin? = nil,
                               expectedTBResponseType responseType: any TBDataModel.Type)
    async throws -> any TBDataModel {
        var tbheaders = ["Content-Type": "application/json", "Accept": "application/json"]
        if let token = authData?.token { tbheaders["x-authorization"] = "Bearer \(token)" }
        return try await withCheckedThrowingContinuation { continuation in
            httpClient.doHttpRequest(from: endpointURL,
                                     usingMethod: httpMethod,
                                     withhttpHeaders: tbheaders,
                                     withPayload: payload,
                                     expectedTBResponseType: responseType) { result in
                switch result {
                case .success(let responseObject):
                    continuation.resume(returning: responseObject)
                case .failure(let error):
                    switch error {
                    case .api(let apiError):
                        self.logger?.error("TBRESTClientLib (serverside) Error Message: \(apiError) - \(apiError.localizedDescription)")
                    case .system(let systemError):
                        self.logger?.error("TBRESTClientLib (system) Error Message: \(systemError) - \(systemError.localizedDescription)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
