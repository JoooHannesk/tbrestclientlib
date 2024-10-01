//
//  TBRESTClientLibIntegrationTests.swift
//
//
//  Created by Johannes Kinzig on 30.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
@testable import TBRESTClientLib

final class IntegrationTests: FunctionalTestCases {
    
    func prepare() -> (TBUserApiClient?, ServerSettings?) {
        let serversettings = FileResourceLoader(searchPath: "Resources").loadServerSettingsFromFile(fileName: "ServerSettings")
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl, usernameStr: serversettings!.username, passwordStr: serversettings!.password)
        return (tbTestClient, serversettings)
    }
    /**
     Test login() - expect failure with "Bad Credentials"
     */
    func testLoginFails() {
        let serversettings = prepare().1
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl, usernameStr: "user@example.com", passwordStr: "mysupersecretpassword")
        loginFails(apiClient: tbTestClient)
    }
    
    /**
     Test login() - expect success
     */
    func testLoginSucceeds() {
        //let (tbTestClient, _) = prepare()
        let tbTestClient = prepare().0
        loginSucceeds(apiClient: tbTestClient)
    }
    
    /**
     Test getUser() - expect correct response with own user info
     */
    func testGetUser() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
    }
    
    /**
     Test getCustomerDevices()
     */
    func testGetCustomerDevices() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
    }
    
    /**
     Test getCustomerDeviceInfos()
     */
    func testGetCustomerDeviceInfos() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        getCustomerDeviceInfos(apiClient: tbTestClient)
    }
    
    /**
     Test getDeviceProfileInfos()
     */
    func testGetDeviceProfileInfos() {
        let tbTestClient = prepare().0
        loginSucceeds(apiClient: tbTestClient)
        getDeviceProfileInfos(apiClient: tbTestClient)
    }
    
    /**
     Test getDeviceProfiles()
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testGetDeviceProfiles() {
        let tbTestClient = prepare().0
        loginSucceeds(apiClient: tbTestClient)
        getDeviceProfiles(apiClient: tbTestClient)
    }
    
    /**
     Test getAttributeKeys()
     */
    func testGetAttributeKeys() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        getAttributeKeys(apiClient: tbTestClient)
    }
    
    /**
     Test getAttributeKeysByScope()
     */
    func testGetAttributeKeysByScope() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        getAttributeKeysByScope(apiClient: tbTestClient)
    }
    
    /**
     Test saveEntityAttributes() – Success
     */
    func testSaveEntityAttributesSuccess() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityAttributesSuccess(apiClient: tbTestClient)
    }
    
    /**
     Test saveEntityAttributes() – Fails with unmatched device ID
     TB server responds with two different messages for unmatched device ID (ID not found on server) and
     ID was not given as valid UUID string.
     */
    func testSaveEntityAttributesFailureUnmatchedDeviceID() {
        let tbTestClient = prepare().0
        loginSucceeds(apiClient: tbTestClient)
        saveEntityAttributesFailureUnmatchedDeviceID(apiClient: tbTestClient)
    }
    
    /**
     Test saveEntityAttributes() – Fails with non-UUID conforming string as identifier
     TB server responds with two different messages for unmatched device ID (ID not found on server) and
     ID was not given as valid UUID string.
     */
    func testSaveEntityAttributesFailureNonConformingUUID() {
        let tbTestClient = prepare().0
        loginSucceeds(apiClient: tbTestClient)
        saveEntityAttributesFailureNonConformingUUID(apiClient: tbTestClient)
    }
    
    /**
     Test getAttributesSuccess()
     */
    func testGetAttributesSuccess() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityAttributesSuccess(apiClient: tbTestClient)
        getAttributesSuccess(apiClient: tbTestClient)
    }
}
