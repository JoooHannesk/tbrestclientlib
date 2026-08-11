//
//  IntegrationTestsAsync.swift
//
//
//  Async counterparts of the integration tests in IntegrationTests.swift, exercising the
//  async/await API of TBUserApiClient against a live ThingsBoard server (configured in
//  Resources/ServerSettings.json).
//

import XCTest
import OSLog
@testable import TBRESTClientLib

/**
 Integration tests (async API)

 All test cases can be run with `CUSTOMER\_USER` authority.
 */
final class IntegrationTestsAsync: FunctionalTestCases {

    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "IntegrationTestsAsync")

    func prepare() -> (TBUserApiClient?, ServerSettings?) {
        let serversettings = FileResourceLoader(searchPath: "Resources").loadServerSettingsFromFile(fileName: "ServerSettings")
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl,
                                                username: serversettings!.username,
                                                password: serversettings!.password,
                                                logger: Self.logger)
        return (tbTestClient, serversettings)
    }


    /**
     Test async login() - expect failure because of unknown host
     */
    func testloginFailsBecauseOfUnknownHost() async throws {
        let tbTestClient = try? TBUserApiClient(baseUrlStr: "https://localhorst", username: "user@example.com", password: "mysupersecretpassword", logger: Self.logger)
        try await loginFailsBecauseOfUnknownHost(apiClient: tbTestClient)
    }

    /**
     Test async login() - expect failure with "Bad Credentials"
     */
    func testLoginFails() async throws {
        let serversettings = prepare().1
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl, username: "user@example.com", password: "mysupersecretpassword", logger: Self.logger)
        try await loginFails(apiClient: tbTestClient)
    }

    /**
     Test async login() - expect success
     */
    func testLoginSucceeds() async throws {
        let tbTestClient = prepare().0
        try await loginSucceeds(apiClient: tbTestClient)
    }

    /**
     Test getAccessToken() after async login
     */
    func testGetAccessToken() async throws {
        let (tbTestClient, _) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        let accessToken = tbTestClient!.getAccessToken()
        XCTAssertNotNil(accessToken)
    }

    /**
     Test async getUser() - expect correct response with own user info
     */
    func testGetUser() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
    }

    /**
     Test async getCustomerById() - expect a valid `Customer` as response
     */
    func testGetCustomerById() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerById(apiClient: tbTestClient, expectedCustomerName: "IoT Playground")
    }

    /**
     Test login with existing token from previous session (async)
     */
    func testLoginWithAccessToken() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        let authData = tbTestClient!.authData
        let newTbTestClient = try TBUserApiClient(baseUrlStr: serversettings!.baseUrl, accessToken: authData!, logger: Self.logger)
        try await getUser(apiClient: newTbTestClient, expectedUsername: serversettings!.username)
        try await renewLogin(apiClient: newTbTestClient, username: serversettings!.username, password: serversettings!.password)
        compareDifferentAuthLogins(apiClientToken1: tbTestClient!.authData!, apiClientToken2: newTbTestClient.authData!)
    }

    /**
     Test async getCustomerDevices()
     */
    func testGetCustomerDevices() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
    }

    /**
     Test async getCustomerDeviceInfos()
     */
    func testGetCustomerDeviceInfos() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await getCustomerDeviceInfos(apiClient: tbTestClient)
    }

    /**
     Test async getDeviceById()
     */
    func testGetDeviceById() async throws {
        var deviceOfInterest: Device? = nil
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        // 1. Get all devices for customer, select the first
        let firstDevice = try await getCustomerDevices(apiClient: tbTestClient)?.first
        XCTAssertNotNil(firstDevice)
        if let firstDevice = firstDevice {
            // 2. Request specific device (test the function which is of interest for this specific test case)
            deviceOfInterest = try await getDeviceById(apiClient: tbTestClient, deviceId: firstDevice.id.id)
        }
        else {
            XCTFail("No device available! Aborting!")
        }
        XCTAssertEqual(firstDevice, deviceOfInterest)
    }

    /**
     Test async getDeviceInfoById()
     */
    func testGetDeviceInfoById() async throws {
        var deviceOfInterest: Device? = nil
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        // 1. Get all device infos for customer, select the first
        let firstDevice = try await getCustomerDeviceInfos(apiClient: tbTestClient)?.first
        XCTAssertNotNil(firstDevice)
        if let firstDevice = firstDevice {
            // 2. Request specific device (test the function which is of interest for this specific test case)
            deviceOfInterest = try await getDeviceInfoById(apiClient: tbTestClient, deviceId: firstDevice.id.id)
        }
        else {
            XCTFail("No device available! Aborting!")
        }
        XCTAssertEqual(firstDevice, deviceOfInterest)
    }

    /**
     Test async updateDeviceLabel()

     Test requires that devices have their lables not empty
     */
    func testUpdateDeviceLabel() async throws {
        var originalDeviceLabel = ""
        var originalDevice: Device? = nil
        let newDeviceLabel = "Test Device Label"
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        // Change label value to new label value and compare
        if let firstDevice = try await getCustomerDeviceInfos(apiClient: tbTestClient)?.first {
            originalDeviceLabel = firstDevice.label!
            originalDevice = try await updateDeviceLabel(apiClient: tbTestClient, device: firstDevice, newLabelName: newDeviceLabel)
            XCTAssertEqual(originalDevice!.label, newDeviceLabel)
        }
        else {
            XCTFail("No device found to test")
        }
        // Change label back to original value an compare
        if let updatedDevice = try await updateDeviceLabel(apiClient: tbTestClient, device: originalDevice!, newLabelName: originalDeviceLabel) {
            XCTAssertEqual(updatedDevice.label, originalDeviceLabel)
        } else {
            XCTFail("Failed to update device label to original value")
        }
    }

    /**
     Test async getDeviceProfileInfos()
     */
    func testGetDeviceProfileInfos() async throws {
        let tbTestClient = prepare().0
        try await loginSucceeds(apiClient: tbTestClient)
        try await getDeviceProfileInfos(apiClient: tbTestClient)
    }

    /**
     Test async getAttributeKeys()
     */
    func testGetAttributeKeys() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await getAttributeKeys(apiClient: tbTestClient)
    }

    /**
     Test async getAttributeKeysByScope()
     */
    func testGetAttributeKeysByScope() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await getAttributeKeysByScope(apiClient: tbTestClient)
    }

    /**
     Test async saveEntityAttributes() – Success
     */
    func testSaveEntityAttributesSuccess() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityAttributesSuccess(apiClient: tbTestClient)
    }

    /**
     Test async saveEntityAttributes() – Fails with unmatched device ID
     */
    func testSaveEntityAttributesFailureUnmatchedDeviceID() async throws {
        let tbTestClient = prepare().0
        try await loginSucceeds(apiClient: tbTestClient)
        try await saveEntityAttributesFailureUnmatchedDeviceID(apiClient: tbTestClient)
    }

    /**
     Test async saveEntityAttributes() – Fails with non-UUID conforming string as identifier
     */
    func testSaveEntityAttributesFailureNonConformingUUID() async throws {
        let tbTestClient = prepare().0
        try await loginSucceeds(apiClient: tbTestClient)
        try await saveEntityAttributesFailureNonConformingUUID(apiClient: tbTestClient)
    }

    /**
     Test async getAttributes()
     */
    func testGetAttributesSuccess() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityAttributesSuccess(apiClient: tbTestClient)
        try await getAttributesSuccess(apiClient: tbTestClient)
    }

    /**
     Test async getAttributesByScope()
     */
    func testGetAttributesByScopeSuccess() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityAttributesSuccess(apiClient: tbTestClient)
        try await getAttributesByScopeSuccess(apiClient: tbTestClient)
    }

    /**
     Test async deleteEntityAttributes()
     */
    func testdeleteEntityAttributes() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await deleteEntityAttributes(apiClient: tbTestClient)
    }

    /**
     Test async saveEntityTelemetry() – Success
     */
    func testSaveEntityTelemetrySuccess() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
    }

    /**
     Test async getTimeseriesKeys()
     */
    func testGetTimeseriesKeys() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
        try await getTimeseriesKeys(apiClient: tbTestClient)
    }

    /**
     Test async getLatestTimeseries()
     Values as strings (`useStrictDataTypes = false`)
     */
    func testGetLatestTimeseriesValuesAsStrings() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
        try await getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }

    /**
     Test async getLatestTimeseries()
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetLatestTimeseriesValuesAsNativeTypes() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
        try await getLatestTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }

    /**
     Test async getTimeseries()
     Values as strings (`useStrictDataTypes = false`)
     */
    func testGetTimeseriesValuesAsStrings() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
        try await getTimeseries(apiClient: tbTestClient, getValuesAsStrings: true)
    }

    /**
     Test async getTimeseries()
     Values as native datatypes (`useStrictDataTypes = true`)
     */
    func testGetTimeseriesValuesAsNativeTypes() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
        try await getTimeseries(apiClient: tbTestClient, getValuesAsStrings: false)
    }

    /**
     Test async deleteEntityTimeseries()
     */
    func testdeleteEntityTimeseries() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        try await getCustomerDevices(apiClient: tbTestClient)
        try await saveEntityTelemetrySuccess(apiClient: tbTestClient)
        try await deleteEntityTimeseries(apiClient: tbTestClient)
    }

    /**
     Test async logout()
     */
    func testLogout() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        await logout(apiClient: tbTestClient)
    }

}
