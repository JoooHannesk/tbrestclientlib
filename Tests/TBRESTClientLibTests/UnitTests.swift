//
//  TBRESTClientLibTests.swift
//  
//
//  Created by Johannes Kinzig on 25.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
@testable import TBRESTClientLib

final class UnitTests: FunctionalTestCases {
    
    // prepare mock api client
    let testableApiClient = MockAPIClientFactory(baseUrlStr: "url.server.com", usernameStr: "user@example.com", passwordStr: "supersecretpassword")

    /**
     Check that initializer runs without throwing when all login fields are given
     */
    func testLoginDataNotEmpty() {
        XCTAssertNoThrow(try TBUserApiClient(baseUrlStr: "url.server.com", usernameStr: "user@example.com", passwordStr: "supersecretpassword"))
    }
    
    /**
     Check that initializer is throwing in case a single login field is missing
     */
    func testLoginDataEmpty() {
        XCTAssertThrowsError(try TBUserApiClient(baseUrlStr: "url.server.com", usernameStr: "", passwordStr: "")) { error in
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
     Test getCustomerDevices()
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
     Test compatibility for 'Device' data model - for sake of an additional test using a different type
     This test requires to have **at least two different devices** in the GetCustomerDevices.json resource file
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
     Test getCustomerDeviceInfos()
     */
    func testGetCustomerDeviceInfos() {
        testGetUser()
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetCustomerDeviceInfos", expectedHTTPStatusCode: 200)
        getCustomerDeviceInfos(apiClient: tbTestClient)
    }
    
    /**
     Test getDeviceProfileInfos()
     */
    func testGetDeviceProfileInfos() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceProfileInfos", expectedHTTPStatusCode: 200)
        getDeviceProfileInfos(apiClient: tbTestClient)
    }
    
    /**
     Test getDeviceProfiles()
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testGetDeviceProfiles() {
        let tbTestClient = testableApiClient.getMockApiClient(expectedHTTPResponse: "GetDeviceProfiles", expectedHTTPStatusCode: 200)
        getDeviceProfiles(apiClient: tbTestClient)
    }
    
}

// TODO: improve client implementation to react to different http status codes
