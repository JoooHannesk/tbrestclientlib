//
//  IntegrationTestsAdminAsync.swift
//
//
//  Async counterparts of the admin integration tests in IntegrationTestsAdmin.swift,
//  exercising the async/await API against a live ThingsBoard server with 'TENANT_ADMIN'
//  authority (configured in Resources/ServerSettingsAdmin.json).
//

import XCTest
import OSLog
@testable import TBRESTClientLib


final class IntegrationTestsAdminAsync: FunctionalTestCases {

    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "IntegrationTestsAdminAsync")

    func prepare() -> (TBUserApiClient?, ServerSettings?) {
        let serversettings = FileResourceLoader(searchPath: "Resources").loadServerSettingsFromFile(fileName: "ServerSettingsAdmin")
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl,
                                                username: serversettings!.username!,
                                                password: serversettings!.password!,
                                                logger: Self.logger)
        return (tbTestClient, serversettings)
    }

    /**
     Test async getDeviceProfiles()
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testGetDeviceProfiles() async throws {
        let tbTestClient = prepare().0
        try await loginSucceeds(apiClient: tbTestClient)
        try await getDeviceProfiles(apiClient: tbTestClient)
    }

    /**
     Test async create new device and delete device

     Create a device for the current tenant and delete this device afterwards.
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testCreateNewDeviceDeleteDevice() async throws {
        let newDeviceName = "TestDevice"
        let newDeviceLabel = "Should not be here!"
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username!)
        if let newDevice = try await createNewDeviceForCustomer(apiClient: tbTestClient, name: newDeviceName, label: newDeviceLabel) {
            XCTAssertEqual(newDeviceName, newDevice.name)
            XCTAssertEqual(newDeviceLabel, newDevice.label)
            try await deleteDevice(apiClient: tbTestClient, deviceId: newDevice.id.id)
        } else {
            XCTFail("Did not create new device!")
        }
    }

    /**
     Test async getTenantDevices()

     Get all devices registered at the tenant the user belongs to.

     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func testGetTenantDevices() async throws {
        let (tbTestClient, serversettings) = prepare()
        try await loginSucceeds(apiClient: tbTestClient)
        try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username!)
        try await getTenantDevices(apiClient: tbTestClient)
    }

}

/**
 Integration tests

 Integration tests with new `apiKey` login, therefore just testing a view cases where a login needs to succeed.
 All test cases can be run with `CUSTOMER\_USER` authority.
 */
final class IntegrationTestsAdminAsyncApiKeyLogin: FunctionalTestCases {

    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "IntegrationTests")

    func prepare() -> (TBUserApiClient?, ServerSettings?) {
        let serversettings = FileResourceLoader(searchPath: "Resources").loadServerSettingsFromFile(fileName: "ServerSettingsAdmin")
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl,
                                                apiKey: serversettings!.apiKey!,
                                                logger: Self.logger)
        return (tbTestClient, serversettings)
    }


    func testGetUser() async throws {
        let (tbTestClient, serversettings) = prepare()
        let user = try await getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username!)
        XCTAssertEqual(user?.authority, .tenantAdmin)
    }
}
