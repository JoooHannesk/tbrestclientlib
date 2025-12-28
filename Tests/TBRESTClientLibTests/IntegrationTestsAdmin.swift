//
//  IntegrationTestsAdminAuthority.swift
//  TBRESTClientLib
//
//  Created by Johannes Kinzig on 28.12.25.
//

import XCTest
import OSLog
@testable import TBRESTClientLib


final class IntegrationTestsAdmin: FunctionalTestCases {

    static let logger = Logger(subsystem: "TestBundle.TBRESTClientLibTests", category: "IntegrationTests")

    func prepare() -> (TBUserApiClient?, ServerSettings?) {
        let serversettings = FileResourceLoader(searchPath: "Resources").loadServerSettingsFromFile(fileName: "ServerSettingsAdmin")
        let tbTestClient = try? TBUserApiClient(baseUrlStr: serversettings!.baseUrl,
                                                username: serversettings!.username,
                                                password: serversettings!.password,
                                                logger: Self.logger)
        return (tbTestClient, serversettings)
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
     Test create new device and delete device

     Create a device for the current tenant and delete this device afterwards.
     */
    func testCreateNewDeviceDeleteDevice() {
        let newDeviceName = "TestDevice"
        let newDeviceLabel = "Should not be here!"
        let (tbTestClient, serversettings) = prepare()
        loginSucceeds(apiClient: tbTestClient)
        getUser(apiClient: tbTestClient, expectedUsername: serversettings!.username)
        if let newDevice = createNewDeviceForCustomer(apiClient: tbTestClient, name: newDeviceName, label: newDeviceLabel) {
            XCTAssertEqual(newDeviceName, newDevice.name)
            XCTAssertEqual(newDeviceLabel, newDevice.label)
            deleteDevice(apiClient: tbTestClient, deviceId: newDevice.id.id)
        } else {
            XCTFail("Did not create new device!")
        }
    }

    

}
