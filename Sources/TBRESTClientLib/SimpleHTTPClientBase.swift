//
//  SimpleHTTPClientBase.swift
//
//
//  Created by Johannes Kinzig on 23.08.24.
//

import Foundation


// MARK: - DataTask
public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }


// MARK: - URLSession
/// - Note: Refines `Sendable` because session handlers are shared across concurrency domains by
/// ``TBUserApiClient``; the completion handler is invoked on an arbitrary thread and must be `@Sendable`.
public protocol URLSessionProtocol: Sendable {
    func dataTask(with url: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {

    public func dataTask(with url: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol   {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

// MARK: - MOCK URLSession
class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    func resume() { }
}

// @unchecked: mutable state is only set at init time by the owning test before any request runs.
final class MockURLSession: URLSessionProtocol, @unchecked Sendable {

    var dataTask = MockURLSessionDataTask()
    
    var cmplHdlrData: Data?
    var cmplHdlrURLResponse: URLResponse?
    var cmplHdlrError: Error?
    
    init(cmplHdlrData: Data?, cmplHdlrURLResponse: URLResponse?, cmplHdlrError: Error?) {
        self.cmplHdlrData = cmplHdlrData
        self.cmplHdlrURLResponse = cmplHdlrURLResponse
        self.cmplHdlrError = cmplHdlrError
    }
    
    func dataTask(with url: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        completionHandler(self.cmplHdlrData, self.cmplHdlrURLResponse, self.cmplHdlrError)
        return self.dataTask
    }
}
