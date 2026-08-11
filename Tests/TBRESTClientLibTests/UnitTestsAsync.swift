//
//  UnitTestsAsync.swift
//
//
//  Async counterparts of the mocked unit tests in UnitTests.swift, exercising the
//  async/await API of TBUserApiClient. Reuses MockAPIClientFactory and the JSON
//  fixtures in Resources/HTTPResponses unchanged.
//

import XCTest
import OSLog
@testable import TBRESTClientLib

final class UnitTestsAsync: FunctionalTestCases {

    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "UnitTestsAsync")

    // prepare mock api client
    let testableApiClient = MockAPIClientFactory(baseUrlStr: "url.server.com", username: "user@example.com", password: "supersecretpassword")

    /**
     Test async login() - expect failure with "Bad Credentials"
     */
    func testLoginFails() async throws {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "LoginFailsBadCredentials", expectedHTTPStatusCode: 200)
        try await loginFails(apiClient: tbTestClient)
    }

    /**
     Test async login() - expect success
     */
    func testLoginSucceeds() async throws {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "Login", expectedHTTPStatusCode: 200)
        try await loginSucceeds(apiClient: tbTestClient)
    }

    /**
     Test async login(withUsername:andPassword:) with empty credentials - expect thrown TBSystemError.emptyLogin
     (async precondition matches the sync login() and the initializers)
     */
    func testLoginEmptyCredentialsThrows() async throws {
        let tbTestClient = try XCTUnwrap(testableApiClient.getMockApiClient(expectedHTTPResponse: "Login", expectedHTTPStatusCode: 200))
        do {
            _ = try await tbTestClient.login(withUsername: "", andPassword: "")
            XCTFail("Expected login to throw")
        } catch TBSystemError.emptyLogin {
            // expected error case thrown
        } catch {
            XCTFail("Wrong error type thrown: \(error)")
        }
    }

    /**
     Test async login() with an injected transport error (e.g. unknown host) - expect thrown .system(.httpRequestFailure)
     */
    func testLoginSystemErrorThrows() async throws {
        let tbTestClient = try XCTUnwrap(testableApiClient.getMockApiClient(expectedHTTPResponse: "Login", expectedHTTPStatusCode: 200,
                                                                            expectedError: URLError(.cannotFindHost)))
        do {
            _ = try await tbTestClient.login()
            XCTFail("Expected login to throw")
        } catch TBHTTPClientRequestError.system(let systemError) {
            XCTAssertEqual(systemError, .httpRequestFailure)
        } catch {
            XCTFail("Expected .system error, got \(error)")
        }
    }

    /**
     Test async login() against a session delivering neither data nor error - expect thrown .system(.httpRequestFailure)
     Regression test for the completion-handler fallthrough in SimpleHTTPClient: without it this test would hang
     (leaked continuation) instead of throwing.
     */
    func testNoDataNoErrorThrows() async throws {
        let mockSession = MockURLSession(cmplHdlrData: nil, cmplHdlrURLResponse: nil, cmplHdlrError: nil)
        let tbTestClient = try TBUserApiClient(baseUrlStr: "url.server.com", username: "user@example.com", password: "supersecretpassword",
                                               httpSessionHandler: mockSession, logger: Self.logger)
        do {
            _ = try await tbTestClient.login()
            XCTFail("Expected login to throw")
        } catch TBHTTPClientRequestError.system(let systemError) {
            XCTAssertEqual(systemError, .httpRequestFailure)
        } catch {
            XCTFail("Expected .system error, got \(error)")
        }
    }

    /**
     Test async getUser()
     */
    func testGetUser() async throws {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "SampleUser1Info", expectedHTTPStatusCode: 200)
        try await getUser(apiClient: tbTestClient, expectedUsername: "user1@example.com")
    }

    /**
     Test async getCustomerById()
     */
    func testGetCustomerById() async throws {
        try await testGetUser()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetCustomerById", expectedHTTPStatusCode: 200)
        try await getCustomerById(apiClient: tbTestClient, expectedCustomerName: "IoT Playground")
    }

    /**
     Test async getCustomerDevices()
     */
    @discardableResult
    func testGetCustomerDevices() async throws -> Array<Device>? {
        try await testGetUser()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetCustomerDevices", expectedHTTPStatusCode: 200)
        let customer_devices = try await getCustomerDevices(apiClient: tbTestClient)
        return customer_devices
    }

    /**
     Test async getDeviceById()
     */
    func testGetDeviceById() async throws {
        try await testGetUser()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceById", expectedHTTPStatusCode: 200)
        let device = try await getDeviceById(apiClient: tbTestClient, deviceId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        XCTAssertNotNil(device)
    }

    /**
     Test async getDeviceInfoById()
     */
    func testGetDeviceInfoById() async throws {
        try await testGetUser()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceInfoById", expectedHTTPStatusCode: 200)
        let device = try await getDeviceInfoById(apiClient: tbTestClient, deviceId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        XCTAssertNotNil(device)
    }

    /**
     Test async getCustomerDeviceInfos()
     */
    func testGetCustomerDeviceInfos() async throws {
        try await testGetUser()
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetCustomerDeviceInfos", expectedHTTPStatusCode: 200)
        try await getCustomerDeviceInfos(apiClient: tbTestClient)
    }

    /**
     Test async getDeviceProfileInfos()
     */
    func testGetDeviceProfileInfos() async throws {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceProfileInfos", expectedHTTPStatusCode: 200)
        try await getDeviceProfileInfos(apiClient: tbTestClient)
    }

    /**
     Test async getAttributeKeys()
     */
    func testGetAttributeKeys() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributeKeys", expectedHTTPStatusCode: 200)
        try await getAttributeKeys(apiClient: tbTestClient)
    }

    /**
     Test async getAttributeKeysByScope()
     */
    func testGetAttributeKeysByScope() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributeKeys", expectedHTTPStatusCode: 200)
        try await getAttributeKeysByScope(apiClient: tbTestClient)
    }

    /**
     Test async getAttributes()
     */
    func testGetAttributesSuccess() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributes", expectedHTTPStatusCode: 200)
        try await getAttributesSuccess(apiClient: tbTestClient)
    }

    /**
     Test async getAttributesByScope()
     */
    func testGetAttributesByScopeSuccess() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributes", expectedHTTPStatusCode: 200)
        try await getAttributesByScopeSuccess(apiClient: tbTestClient)
    }

    /**
     Test async getLatestTimeseries()
     Values as strings (`useStrictDataTypes = false`)
     */
    func testGetLatestTimeseriesValuesAsStrings() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetLatestTimeseriesAsStrings", expectedHTTPStatusCode: 200)
        try await getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }

    /**
     Test async getLatestTimeseries()
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetLatestTimeseriesValuesAsNativeTypes() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetLatestTimeseriesAsNativeTypes", expectedHTTPStatusCode: 200)
        try await getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }

    /**
     Test async getTimeseries()
     Values as strings (`useStrictDataTypes = false`)
     */
    func testGetTimeseriesValuesAsStrings() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetTimeseriesAsStrings", expectedHTTPStatusCode: 200)
        try await getTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }

    /**
     Test async getTimeseries()
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetTimeseriesValuesAsNativeTypes() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetTimeseriesAsNativeTypes", expectedHTTPStatusCode: 200)
        try await getTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }

    /**
     Test async getTimeseriesKeys()
     */
    func testGetTimeseriesKeys() async throws {
        try await testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetTimeseriesKeys", expectedHTTPStatusCode: 200)
        try await getTimeseriesKeys(apiClient: tbTestClient)
    }

}
