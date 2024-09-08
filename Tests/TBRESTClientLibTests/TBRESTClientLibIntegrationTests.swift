//
//  TBRESTClientLibIntegrationTests.swift
//
//
//  Created by Johannes Kinzig on 30.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
@testable import TBRESTClientLib

final class TBRESTClientLibIntegrationLoginAuth: TCGTBRESTClientLibLoginAuth {
    
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
    
}
