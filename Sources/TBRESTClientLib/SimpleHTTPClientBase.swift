//
//  SimpleHTTPClientBase.swift
//
//
//  Created by Johannes Kinzig on 23.08.24.
//

import Foundation


// MARK: - DataTask
protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }


// MARK: - URLSession
protocol URLSessionProtocol {
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol   {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

// MARK: - MOCK URLSession
class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    func resume() { }
}

class MockURLSession: URLSessionProtocol {
    
    var dataTask = MockURLSessionDataTask()
    
    var cmplHdlrData: Data?
    var cmplHdlrURLResponse: URLResponse?
    var cmplHdlrError: Error?
    
    init(cmplHdlrData: Data?, cmplHdlrURLResponse: URLResponse?, cmplHdlrError: Error?) {
        self.cmplHdlrData = cmplHdlrData
        self.cmplHdlrURLResponse = cmplHdlrURLResponse
        self.cmplHdlrError = cmplHdlrError
    }
    
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        completionHandler(self.cmplHdlrData, self.cmplHdlrURLResponse, self.cmplHdlrError)
        return self.dataTask
    }
}
