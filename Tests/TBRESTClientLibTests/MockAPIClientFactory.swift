//
//  MockAPIClientFactory.swift
//
//
//  Created by Johannes Kinzig on 25.08.24.
//

import Foundation
@testable import TBRESTClientLib

struct MockURLResponse {
    let httpResponseResourceLoader = FileResourceLoader(searchPath: "Resources/HTTPResponses")
    
    /**
     Create a mock HTTP session with custom response, status code and error
     - Parameter jsonFileName: filename to a mock http response inside a json file (which exists inside this library)
     - Parameter httpStatusCode: http response status code
     - Parameter error: http error
     */
    func createMockHttpSession(jsonFileName: String, httpStatusCode: Int, error: Error? = nil) -> MockURLSession? {
        let data = httpResponseResourceLoader.loadTextFromFile(fileName: jsonFileName)
        let response = HTTPURLResponse(url: URL(string: "url.server.com")!, statusCode: httpStatusCode, httpVersion: nil, headerFields: nil)
        return MockURLSession(cmplHdlrData: data, cmplHdlrURLResponse: response, cmplHdlrError: error)
    }
}

struct MockAPIClientFactory {
    let baseUrlStr: String
    let username: String
    let password: String
    
    let mhs = MockURLResponse()
    
    /**
     Get a unit testable API client which receives given response, status code and error
     - Parameter expectedHTTPResponse: filename to a mock http response inside a json file (which exists inside this library)
     - Parameter httpStatusCode: http response status code
     - Parameter error: http error
     - Note: In case the api client cannot be created and is nil, nil will be returned
     */
    func getMockApiClient(expectedHTTPResponse: String, expectedHTTPStatusCode: Int, expectedError: Error? = nil) -> TBUserApiClient? {
        let mockLoginHTTPSession = mhs.createMockHttpSession(jsonFileName: expectedHTTPResponse, httpStatusCode: expectedHTTPStatusCode, error: expectedError)
        let tbTestClient = try? TBUserApiClient(baseUrlStr: baseUrlStr, username: username, password: password, apiEndpointVersion: TbAPIEndpointsV1(), httpSessionHandler: mockLoginHTTPSession!)
        return tbTestClient
    }
}
