//
//  TBRESTClientLibIntegrationTests.swift
//
//
//  Created by Johannes Kinzig on 30.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
import OSLog
@testable import TBRESTClientLib

final class IntegrationTests: FunctionalTestCases {
    
    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "IntegrationTests")
    
    func prepare() -> (TBUserApiClient?, ServerSettings?) {
        let serversettings = FileResourceLoader(searchPath: "Resources").loadServerSettingsFromFile(fileName: "ServerSettings")
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl,
                                                username: serversettings!.username,
                                                password: serversettings!.password,
                                                logger: Self.logger)
        return (tbTestClient, serversettings)
    }
    
    
    /**
     Test login() - expect failure because of unknown host
     */
    func testloginFailsBecauseOfUnknownHost() {
        let tbTestClient = try? TBUserApiClient(baseUrlStr: "https://localhorst", username: "user@example.com", password: "mysupersecretpassword", logger: Self.logger)
        loginFailsBecauseOfUnknownHost(apiClient: tbTestClient)
    }
    
    /**
     Test login() - expect failure with "Bad Credentials"
     */
    func testLoginFails() {
        let serversettings = prepare().1
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl, username: "user@example.com", password: "mysupersecretpassword", logger: Self.logger)
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
     Test getAccessToken()
     */
    func testGetAccessToken() {
        let (tbTestClient, _) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        let accessToken = tbTestClient!.getAccessToken()
        XCTAssertNotNil(accessToken)
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
     Test getCustomerById() - expect a valid `Customer` as response
     */
    func testGetCustomerById() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerById(apiClient: tbTestClient, expectedCustomerName: "IoT Playground")
    }
    
    /**
     Test loginWithAccessToken()
     Test login with existing token from previous session
     */
    func testLoginWithAccessToken() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        let authData = tbTestClient!.authData
        let newTbTestClient = try! TBUserApiClient(baseUrlStr: serversettings!.baseUrl, accessToken: authData!, logger: Self.logger)
        newTbTestClient!.registerErrorHandler(apiErrorHandler: { errorMsg in
            XCTFail("API error: \(errorMsg)")
        })
        getUser(apiClient: newTbTestClient, expectedUsername: serversettings!.username)
        renewLogin(apiClient: newTbTestClient, username: serversettings!.username, password: serversettings!.password)
        compareDifferentAuthLogins(apiClientToken1: tbTestClient!.authData!, apiClientToken2: newTbTestClient!.authData!)
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
     Test testGetDeviceById()
     */
    func testGetDeviceById() {
        var deviceOfInterest: Device? = nil
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        // 1. Get all devices for customer, select the first
        let firstDevice = getCustomerDevices(apiClient: tbTestClient)?.first
        XCTAssertNotNil(firstDevice)
        if let firstDevice = firstDevice {
        // 2. Request specific device (test the function which is of interest for this specific test case)
            deviceOfInterest = getDeviceById(apiClient: tbTestClient, deviceId: firstDevice.id.id)
        }
        else {
            XCTFail("No device available! Aborting!")
        }
        XCTAssertEqual(firstDevice, deviceOfInterest)
    }

    /**
     Test testGetDeviceInfoById()
     */
    func testGetDeviceInfoById() {
        var deviceOfInterest: Device? = nil
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        // 1. Get all devices for customer, select the first
        let firstDevice = getCustomerDeviceInfos(apiClient: tbTestClient)?.first
        XCTAssertNotNil(firstDevice)
        if let firstDevice = firstDevice {
        // 2. Request specific device (test the function which is of interest for this specific test case)
            deviceOfInterest = getDeviceInfoById(apiClient: tbTestClient, deviceId: firstDevice.id.id)
        }
        else {
            XCTFail("No device available! Aborting!")
        }
        XCTAssertEqual(firstDevice, deviceOfInterest)
    }

    /**
     Test updateDeviceLabel()
     */
    func testUpdateDeviceLabel() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        updateDeviceLabel(apiClient: tbTestClient)
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
    
    /**
     Test getAttributesByScopeSuccess()
     */
    func testGetAttributesByScopeSuccess() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityAttributesSuccess(apiClient: tbTestClient)
        getAttributesByScopeSuccess(apiClient: tbTestClient)
    }
    
    /**
     Test `deleteEntityAttributes()`
     */
    func testdeleteEntityAttributes() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        deleteEntityAttributes(apiClient: tbTestClient)
    }
    
    /**
     Test `saveEntityTelemetrySuccess()` – Success
     */
    func testSaveEntityTelemetrySuccess() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
    }

    /**
     Test `testGetTimeseriesKeys()`
     */
    func testGetTimeseriesKeys() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
        getTimeseriesKeys(apiClient: tbTestClient)
    }
    
    /**
     Test `getLatestTimeseries()`
     Values as strings  (`useStrictDataTypes = false`)
     */
    func testGetLatestTimeseriesValuesAsStrings() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
        getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }
    
    /**
     Test `getLatestTimeseries()`
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetLatestTimeseriesValuesAsNativeTypes() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
        getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }
    
    /**
     Test `getTimeseries()`
     Values as strings  (`useStrictDataTypes = false`)
     */
    func testGetTimeseriesValuesAsStrings() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
        getTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }
    
    /**
     Test `getTimeseries()`
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetTimeseriesValuesAsNativeTypes() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
        getTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }
    
    /**
     Test `deleteEntityTimeseries()`
     */
    func testdeleteEntityTimeseries() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        getCustomerDevices(apiClient: tbTestClient)
        saveEntityTelemetrySuccess(apiClient: tbTestClient)
        deleteEntityTimeseries(apiClient: tbTestClient)
    }
    
    /**
     Test `logout()`
     */
    func testLogout() {
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        logout(apiClient: tbTestClient)
    }
    
}
