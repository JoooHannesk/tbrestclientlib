//
//  TBRESTClientLibTests.swift
//  
//
//  Created by Johannes Kinzig on 25.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
@testable import TBRESTClientLib

final class TBRESTClientLibUnitLoginFields: XCTestCase {

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
}

final class TBRESTClientLibUnitLoginAuth: TCGTBRESTClientLibLoginAuth {
    
    let testableApiClient = CreateUnitTestableAPIClient(baseUrlStr: "url.server.com", usernameStr: "user@example.com", passwordStr: "supersecretpassword")
    
    /**
     Test login() - expect failure with "Bad Credentials"
     */
    func testLoginFails() {
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "LoginFailsBadCredentials", expectedHTTPStatusCode: 200)
        loginFails(apiClient: tbTestClient)
    }
    
    /**
     Test login() - expect success
     */
    func testLoginSucceeds() {
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "Login", expectedHTTPStatusCode: 200)
        loginSucceeds(apiClient: tbTestClient)
    }
    
    /**
     Test getUser()
     */
    func testGetUser() {
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "SampleOwnUserInfo", expectedHTTPStatusCode: 200)
        getUser(apiClient: tbTestClient, expectedUsername: "user@example.com")
    }
    
    /**
     Test getCustomerDevices()
     */
    func testGetCustomerDevices() {
        testGetUser()
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "GetCustomerDevices", expectedHTTPStatusCode: 200)
        getCustomerDevices(apiClient: tbTestClient)
    }
    
    /**
     Test getCustomerDeviceInfos()
     */
    func testGetCustomerDeviceInfos() {
        testGetUser()
        testGetCustomerDevices()
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "GetCustomerDeviceInfos", expectedHTTPStatusCode: 200)
        getCustomerDeviceInfos(apiClient: tbTestClient)
    }
    
    /**
     Test getDeviceProfileInfos()
     */
    func testGetDeviceProfileInfos() {
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "GetDeviceProfileInfos", expectedHTTPStatusCode: 200)
        getDeviceProfileInfos(apiClient: tbTestClient)
    }
    
    /**
     Test getDeviceProfiles()
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testGetDeviceProfiles() {
        let tbTestClient = testableApiClient.getUnitTestableApiClient(expectedHTTPResponse: "GetDeviceProfiles", expectedHTTPStatusCode: 200)
        getDeviceProfiles(apiClient: tbTestClient)
    }
    
}

// TODO: improve client implementation to react to different http status codes
