//
//  TBRESTClientLibTests.swift
//  
//
//  Created by Johannes Kinzig on 25.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
import OSLog
@testable import TBRESTClientLib

final class UnitTests: FunctionalTestCases {
    
    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "UnitTests")
    
    // prepare mock api client
    let testableApiClient = MockAPIClientFactory(baseUrlStr: "url.server.com", username: "user@example.com", password: "supersecretpassword")

    /**
     Check that initializer runs without throwing when all login fields are given
     */
    func testLoginDataNotEmpty() {
        XCTAssertNoThrow(try TBUserApiClient(baseUrlStr: "url.server.com", username: "user@example.com", password: "supersecretpassword", logger: Self.logger))
    }
    
    /**
     Check that initializer is throwing in case a single login field is missing
     */
    func testLoginDataEmpty() {
        XCTAssertThrowsError(try TBUserApiClient(baseUrlStr: "url.server.com", username: "", password: "", logger: Self.logger)) { error in
            if case TBHTTPClientRequestError.emptyLogin = error {
                // expected error case returned
                XCTAssertTrue(true, "Correct error type thrown!")
            }
            else {
                XCTFail("Wrong error type triggered!")
            }
        }
    }
    
    /**
     Test login() - expect failure with "Bad Credentials"
     */
    func testLoginFails() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "LoginFailsBadCredentials", expectedHTTPStatusCode: 200)
        loginFails(apiClient: tbTestClient)
    }
    
    /**
     Test login() - expect success
     */
    func testLoginSucceeds() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "Login", expectedHTTPStatusCode: 200)
        loginSucceeds(apiClient: tbTestClient)
    }
    
    /**
     Test getUser()
     */
    func testGetUser() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "SampleUser1Info", expectedHTTPStatusCode: 200)
        getUser(apiClient: tbTestClient, expectedUsername: "user1@example.com")
    }
    
    /**
     Test 'User' data model equality check
     Equality check (==) was moved from 'User' struct to a protocol extension to support all conforming entity data models
     */
    func testUserEqualityCheck() {
        let tbTestClient1 = testableApiClient.getMockApiClient(expectedHTTPResponse: "SampleUser1Info", expectedHTTPStatusCode: 200)
        let tbTestClient2 = testableApiClient.getMockApiClient(expectedHTTPResponse: "SampleUser2Info", expectedHTTPStatusCode: 200)
        let user1 = getUser(apiClient: tbTestClient1, expectedUsername: "user1@example.com")
        let user2 = getUser(apiClient: tbTestClient2, expectedUsername: "user2@example.com")
        // expected users to be equal
        XCTAssertEqual(user1, user1)
        // expect users to be unequal
        XCTAssertNotEqual(user1, user2)
    }
    
    /**
     Test `getCustomerDevices()`
     */
    @discardableResult
    func testGetCustomerDevices() -> Array<Device>? {
        testGetUser()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetCustomerDevices", expectedHTTPStatusCode: 200)
        let customer_devices = getCustomerDevices(apiClient: tbTestClient)
        return customer_devices
    }
    
    /**
     Test 'Device' data model equality check
     Equality check (==) was moved to a protocol extension to support all conforming entity data models in commit
     Test compatibility for 'Device' data model.
     This test requires to have **at least two different devices** in the `GetCustomerDevices.json` resource file
     */
    func testDeviceEqualityCheck() {
        let devices = testGetCustomerDevices()
        // expect devices to be equal
        XCTAssertEqual(devices?[0], devices?[0])
        XCTAssertEqual(devices?[1], devices?[1])
        // expect devices to be unequal
        XCTAssertNotEqual(devices?[0], devices?[1])
    }
    
    /**
     Test `getCustomerDeviceInfos()`
     */
    func testGetCustomerDeviceInfos() {
        testGetUser()
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetCustomerDeviceInfos", expectedHTTPStatusCode: 200)
        getCustomerDeviceInfos(apiClient: tbTestClient)
    }
    
    /**
     Test `getDeviceProfileInfos()`
     */
    func testGetDeviceProfileInfos() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceProfileInfos", expectedHTTPStatusCode: 200)
        getDeviceProfileInfos(apiClient: tbTestClient)
    }
    
    /**
     Test `getDeviceProfiles()`
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testGetDeviceProfiles() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceProfiles", expectedHTTPStatusCode: 200)
        getDeviceProfiles(apiClient: tbTestClient)
    }
    
    /**
     Test `getAttributeKeys()`
     */
    func testGetAttributeKeys() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributeKeys", expectedHTTPStatusCode: 200)
        getAttributeKeys(apiClient: tbTestClient)
    }
    
    /**
     Test `getAttributeKeysByScope()`
     */
    func testGetAttributeKeysByScope() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributeKeys", expectedHTTPStatusCode: 200)
        getAttributeKeysByScope(apiClient: tbTestClient)
    }
    
    /**
     Test `getAttributesSuccess()`
     */
    func testGetAttributesSuccess() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributes", expectedHTTPStatusCode: 200)
        getAttributesSuccess(apiClient: tbTestClient)
    }
    
    /**
     Test `getAttributesByScopeSuccess()`
     */
    func testGetAttributesByScopeSuccess() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetAttributes", expectedHTTPStatusCode: 200)
        getAttributesByScopeSuccess(apiClient: tbTestClient)
    }
    
    /**
     Test `getLatestTimeseries()`
     Values as strings  (`useStrictDataTypes = false`)
     */
    func testGetLatestTimeseriesValuesAsStrings() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetLatestTimeseriesAsStrings", expectedHTTPStatusCode: 200)
        getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }
    
    /**
     Test `getLatestTimeseries()`
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetLatestTimeseriesValuesAsNativeTypes() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetLatestTimeseriesAsNativeTypes", expectedHTTPStatusCode: 200)
        getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }
    
    /**
     Test `getTimeseries()`
     Values as strings  (`useStrictDataTypes = false`)
     */
    func testGetTimeseriesValuesAsStrings() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetTimeseriesAsStrings", expectedHTTPStatusCode: 200)
        getTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }
    
    /**
     Test `getTimeseries()`
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetTimeseriesValuesAsNativeTypes() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetTimeseriesAsNativeTypes", expectedHTTPStatusCode: 200)
        getTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }
    
    /**
     Test `getTimeseriesKeys()`
     */
    func testGetTimeseriesKeys() {
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetTimeseriesKeys", expectedHTTPStatusCode: 200)
        getTimeseriesKeys(apiClient: tbTestClient)
    }
    
}

// TODO: improve client implementation for different http status codes
