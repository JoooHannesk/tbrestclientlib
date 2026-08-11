//
//  TestCasesGeneralAsync.swift
//
//
//  Async counterparts of the FunctionalTestCases helpers in TestCasesGeneral.swift.
//  Same helper names, resolved by context (SE-0296): async test methods pick these overloads.
//  Errors are asserted via do/catch on the thrown TBHTTPClientRequestError instead of
//  registered error handlers; no XCTestExpectation/wait(for:) needed.
//

import XCTest
@testable import TBRESTClientLib


extension FunctionalTestCases {

    // MARK: - General Test Cases (async)

    func loginFailsBecauseOfUnknownHost(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        do {
            _ = try await apiClient.login()
            XCTFail("Expected login to throw")
        } catch TBHTTPClientRequestError.system(let systemError) {
            print("System Error: \(systemError)")
        } catch {
            XCTFail("Expected .system error, got \(error)")
        }
    }

    /**
     Async login fails with "bad credentials" tb app error (thrown as TBHTTPClientRequestError.api)
     */
    func loginFails(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        do {
            _ = try await apiClient.login()
            XCTFail("Expected login to throw")
        } catch TBHTTPClientRequestError.api(let apperror) {
            XCTAssertEqual(apperror.status, 401)
            XCTAssertEqual(apperror.errorCode, 10)
            XCTAssertLessThanOrEqual(apperror.timestampDt, Date())
        } catch {
            XCTFail("Expected .api error, got \(error)")
        }
    }

    /**
     Test async login() for success
     */
    @discardableResult
    func loginSucceeds(apiClient: TBUserApiClient?) async throws -> AuthLogin {
        let apiClient = try XCTUnwrap(apiClient)
        let authObject = try await apiClient.login()
        XCTAssertTrue(!authObject.token.isEmpty && !authObject.refreshToken.isEmpty)
        XCTAssertNotNil(apiClient.getAccessToken())
        return authObject
    }

    /**
     Test async login(withUsername:andPassword:) for success
     */
    @discardableResult
    func renewLogin(apiClient: TBUserApiClient?, username: String, password: String) async throws -> AuthLogin {
        let apiClient = try XCTUnwrap(apiClient)
        let authObject = try await apiClient.login(withUsername: username, andPassword: password)
        XCTAssertTrue(!authObject.token.isEmpty && !authObject.refreshToken.isEmpty)
        return authObject
    }

    /**
     Test async getUser() – get current user info
     */
    @discardableResult
    func getUser(apiClient: TBUserApiClient?, expectedUsername: String) async throws -> User? {
        let apiClient = try XCTUnwrap(apiClient)
        let userinfo = try await apiClient.getUser()
        self.tbUser = userinfo
        XCTAssertEqual(userinfo.name, expectedUsername)
        return self.tbUser
    }

    /**
     Test async getCustomerById() - get customer info the user belongs to
     */
    @discardableResult
    func getCustomerById(apiClient: TBUserApiClient?, expectedCustomerName: String) async throws -> Customer? {
        let apiClient = try XCTUnwrap(apiClient)
        let customerId = try XCTUnwrap(self.tbUser?.customerId.id)
        let customer = try await apiClient.getCustomerById(customerId: customerId)
        XCTAssertEqual(customer.name, expectedCustomerName)
        return customer
    }

    /**
     Test async getCustomerDevices() - for a given customer ID
     - Note: This test requires to have **at least two different devices** in the GetCustomerDevices.json resource file (for unit tests)
     or in your TB tenant (for integration tests)
     */
    @discardableResult
    func getCustomerDevices(apiClient: TBUserApiClient?) async throws -> Array<Device>? {
        let apiClient = try XCTUnwrap(apiClient)
        let customerId = try XCTUnwrap(self.tbUser?.customerId.id)
        let tenantId = try XCTUnwrap(self.tbUser?.tenantId.id)
        let customerDevices = try await apiClient.getCustomerDevices(customerId: customerId)
        XCTAssertGreaterThanOrEqual(customerDevices.itemsOnPage, 2)
        self.tbDevice = customerDevices[0]
        XCTAssertEqual(customerDevices[0]?.customerId.id, customerId)
        XCTAssertEqual(customerDevices[0]?.tenantId.id, tenantId)
        self.tbDevices = customerDevices.getItemsInsideArray()
        return self.tbDevices
    }

    /**
     Test async getCustomerDeviceInfos() - for a given customer ID
     */
    @discardableResult
    func getCustomerDeviceInfos(apiClient: TBUserApiClient?) async throws -> Array<Device>? {
        let apiClient = try XCTUnwrap(apiClient)
        let customerId = try XCTUnwrap(self.tbUser?.customerId.id)
        let tenantId = try XCTUnwrap(self.tbUser?.tenantId.id)
        let customerDevices = try await apiClient.getCustomerDeviceInfos(customerId: customerId)
        XCTAssertGreaterThanOrEqual(customerDevices.totalElements, 1)
        XCTAssertEqual(customerDevices[0]?.id, self.tbDevice?.id)
        XCTAssertEqual(customerDevices[0]?.customerId.id, customerId)
        XCTAssertEqual(customerDevices[0]?.tenantId.id, tenantId)
        XCTAssertEqual(customerDevices[0]?.type, self.tbDevice?.type)
        return customerDevices.getItemsInsideArray()
    }

    /**
     Test async getTenantDevices()
     */
    @discardableResult
    func getTenantDevices(apiClient: TBUserApiClient?) async throws -> Array<Device>? {
        let apiClient = try XCTUnwrap(apiClient)
        let tenantId = try XCTUnwrap(self.tbUser?.tenantId.id)
        let tenantDevicesPaginated = try await apiClient.getTenantDevices()
        let tenantDevices = try XCTUnwrap(tenantDevicesPaginated.getItemsInsideArray())
        XCTAssertGreaterThanOrEqual(tenantDevices.count, 1)
        XCTAssertEqual(tenantDevices[0].tenantId.id, tenantId)
        self.tbDevice = tenantDevices[0]
        self.tbDevices = tenantDevices
        return self.tbDevices
    }

    /**
     Test async getDeviceById() - for a given device ID
     */
    @discardableResult
    func getDeviceById(apiClient: TBUserApiClient?, deviceId: UUID) async throws -> Device? {
        let apiClient = try XCTUnwrap(apiClient)
        let device = try await apiClient.getDeviceById(deviceId: deviceId)
        XCTAssertNotNil(device)
        return device
    }

    /**
     Test async getDeviceInfoById() - for a given device ID
     */
    @discardableResult
    func getDeviceInfoById(apiClient: TBUserApiClient?, deviceId: UUID) async throws -> Device? {
        let apiClient = try XCTUnwrap(apiClient)
        let device = try await apiClient.getDeviceInfoById(deviceId: deviceId)
        XCTAssertNotNil(device)
        return device
    }

    /**
     Test async update device

     - Note: This updates the device label and leaves all other fields unchanged
     */
    func updateDeviceLabel(apiClient: TBUserApiClient?, device: Device, newLabelName: String) async throws -> Device? {
        let apiClient = try XCTUnwrap(apiClient)
        let updatedDevice = try await apiClient.saveDevice(name: device.name,
                                                           label: newLabelName,
                                                           deviceId: device.id.id,
                                                           type: device.type,
                                                           description: device.additionalInfo?.description ?? "",
                                                           deviceProfileId: device.deviceProfileId.id,
                                                           tenantId: device.tenantId.id,
                                                           customerId: device.customerId.id)
        return updatedDevice
    }

    /**
     Test async create device

     Create a new device
     */
    func createNewDeviceForCustomer(apiClient: TBUserApiClient?, name: String, label: String) async throws -> Device? {
        let apiClient = try XCTUnwrap(apiClient)
        let tenantId = try XCTUnwrap(self.tbUser?.tenantId.id)
        let device = try await apiClient.saveDevice(name: name, label: label, tenantId: tenantId)
        return device
    }

    /**
     Async delete device

     Delete existing device for given device id
     */
    func deleteDevice(apiClient: TBUserApiClient?, deviceId: UUID) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        try await apiClient.deleteDevice(deviceId: deviceId)
    }

    /**
     Test async getDeviceProfileInfos()
     */
    func getDeviceProfileInfos(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let deviceProfileInfos = try await apiClient.getDeviceProfileInfos()
        if deviceProfileInfos.totalElements > 0 {
            XCTAssertEqual(deviceProfileInfos[0]?.id.entityType, TbQueryEntityTypes.deviceProfile)
        } else {
            XCTFail("Empty Device Profile Container is not helpful for integration testing...!")
        }
    }

    /**
     Test async getDeviceProfiles()
     - Note: works with 'TENANT\_ADMIN' authority only! Make sure to use a user with this authority when performing integration tests.
     */
    func getDeviceProfiles(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        do {
            let deviceProfiles = try await apiClient.getDeviceProfiles()
            if deviceProfiles.totalElements > 0 {
                XCTAssertEqual(deviceProfiles[0]?.id.entityType, TbQueryEntityTypes.deviceProfile)
            } else {
                XCTFail("Empty Device Profile Container is not helpful for integration testing...!")
            }
        } catch TBHTTPClientRequestError.api(let tbAppError) {
            // accept permission denied - not so good practice but do not let the test fail just in case we do not use a 'TENANT\_ADMIN' authority
            XCTAssertEqual(tbAppError.status, 403)
            XCTAssertEqual(tbAppError.errorCode, 20)
        }
    }

    /**
     Test async getAttributeKeys()
     */
    func getAttributeKeys(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure to have at least two devices in your tenant, assigned to the \
                    current user which is authenticating for this integration test!
                """)
            return
        }
        let attrArray = try await apiClient.getAttributeKeys(for: .device, entityId: tbDevice)
        XCTAssertTrue(attrArray.contains("lastActivityTime") && attrArray.contains("lastConnectTime"), "Expected keys missing in response!")
    }

    /**
     Test async getAttributeKeysByScope()
     */
    func getAttributeKeysByScope(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure to have at least two devices in your tenant, assigned to the \
                    current user which is authenticating for this integration test!
                """)
            return
        }
        let attrArray = try await apiClient.getAttributeKeysByScope(for: .device, entityId: tbDevice, scope: .server)
        XCTAssertTrue(attrArray.contains("lastActivityTime") && attrArray.contains("lastConnectTime"), "Expected keys missing in response!")
    }

    /**
     Test async saveEntityAttributes() – success
     **Run with integration tests only**
     */
    func saveEntityAttributesSuccess(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let sampleAttributes = ["sampleAtt1String":"Hello Server", "sampleAtt2Bool": true, "sampleAtt3Int": 4, "sampleAtt4Double": 3.1415926] as [String : Any]
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        try await apiClient.saveEntityAttributes(for: .device, entityId: tbDevice, attributesData: sampleAttributes, scope: .shared)
    }

    /**
     Test async saveEntityAttributes() – fails with unmatched Device ID
     Fails because device is not known
     **Run with integration tests only**
     */
    func saveEntityAttributesFailureUnmatchedDeviceID(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let sampleAttributes = ["sampleAtt1String":"Hello Server", "sampleAtt2String": "Hello Client"]
        do {
            try await apiClient.saveEntityAttributes(for: .device, entityId: UUID(uuidString: "784f394c-42b6-435a-983c-b7beff2784f9")!, attributesData: sampleAttributes, scope: .shared)
            XCTFail("Expected server to respond with an error data model.")
        } catch TBHTTPClientRequestError.system(let systemError) {
            guard case .undecodableResponse = systemError else {
                XCTFail("Expected .undecodableResponse, got \(systemError)")
                return
            }
        } catch {
            XCTFail("Expected .system error, got \(error)")
        }
    }

    /**
     Test async saveEntityAttributes() – fails with nonconforming UUID
     Fails because device is not known
     **Run with integration tests only**
     */
    func saveEntityAttributesFailureNonConformingUUID(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let sampleAttributes = ["sampleAtt1String":"Hello Server", "sampleAtt2Bool": true, "sampleAtt3Int": 4, "sampleAtt4Double": 3.1415926] as [String : Any]
        do {
            try await apiClient.saveEntityAttributes(for: .device, entityId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, attributesData: sampleAttributes, scope: .shared)
            XCTFail("Expected server to respond with an error data model.")
        } catch TBHTTPClientRequestError.system(let systemError) {
            guard case .undecodableResponse = systemError else {
                XCTFail("Expected .undecodableResponse, got \(systemError)")
                return
            }
        } catch {
            XCTFail("Expected .system error, got \(error)")
        }
    }

    /**
     Test async getAttributes
     For integration test to succeed requires that `saveEntityAttributesSuccess()` was run successfully
     */
    func getAttributesSuccess(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        let responseObject = try await apiClient.getAttributes(for: .device, entityId: tbDevice, keys: ["sampleAtt1String", "sampleAtt2Bool", "sampleAtt3Int", "sampleAtt4Double"])
        var att1 = false, att2 = false, att3 = false, att4 = false
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt1String"}) {
            XCTAssertEqual(responseObject[index].value.stringVal, "Hello Server")
            XCTAssertLessThanOrEqual(responseObject[index].lastUpdateDt, Date())
            att1 = true
        }
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt2Bool"}) {
            XCTAssertEqual(responseObject[index].value.boolVal, true)
            XCTAssertLessThanOrEqual(responseObject[index].lastUpdateDt, Date())
            att2 = true
        }
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt3Int"}) {
            XCTAssertEqual(Int(responseObject[index].value.doubleVal!), 4)
            XCTAssertLessThanOrEqual(responseObject[index].lastUpdateDt, Date())
            att3 = true
        }
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt4Double"}) {
            XCTAssertEqual(responseObject[index].value.doubleVal, 3.1415926)
            XCTAssertLessThanOrEqual(responseObject[index].lastUpdateDt, Date())
            att4 = true
        }
        XCTAssertTrue(att1 && att2 && att3 && att4, "Some of the expected attributes could not be retrieved")
    }

    /**
     Test async getAttributesByScope
     For integration test to succeed requires that `saveEntityAttributesSuccess()` was run successfully
     */
    func getAttributesByScopeSuccess(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        let responseObject = try await apiClient.getAttributesByScope(for: .device, entityId: tbDevice, keys: ["sampleAtt1String", "sampleAtt2Bool", "sampleAtt3Int", "sampleAtt4Double"], scope: .shared)
        var att1 = false, att2 = false, att3 = false, att4 = false
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt1String"}) {
            XCTAssertEqual(responseObject[index].value.stringVal, "Hello Server")
            att1 = true
        }
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt2Bool"}) {
            XCTAssertEqual(responseObject[index].value.boolVal, true)
            att2 = true
        }
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt3Int"}) {
            XCTAssertEqual(Int(responseObject[index].value.doubleVal!), 4)
            att3 = true
        }
        if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt4Double"}) {
            XCTAssertEqual(responseObject[index].value.doubleVal, 3.1415926)
            att4 = true
        }
        XCTAssertTrue(att1 && att2 && att3 && att4, "Some of the expected attributes could not be retrieved")
    }

    /**
     Test async deleteEntityAttributes **Run with integration tests only**
     Test requires that `saveEntityAttributesSuccess()` was run successfully!
     */
    func deleteEntityAttributes(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let sampleAttributeKeys = ["sampleAtt1String", "sampleAtt2Bool", "sampleAtt3Int", "sampleAtt4Double"]
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        try await apiClient.deleteEntityAttributes(for: .device, entityId: tbDevice, keys: sampleAttributeKeys, scope: .shared)
    }

    /**
     Test async saveEntityTelemetry() – success
     **Run with integration tests only**
     */
    func saveEntityTelemetrySuccess(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let sampleTimeseriesData = ["SampleIMEI": 999999999999999, "SampleBattery": 100] as [String : Any]
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant has time-series keys as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        try await apiClient.saveEntityTelemetry(for: .device, entityId: tbDevice, timeseriesData: sampleTimeseriesData)
    }

    /**
     Test async getTimeseriesKeys()
     */
    func getTimeseriesKeys(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure to have at least one device in your tenant, assigned to the \
                    current user which is authenticating for this integration test!
                """)
            return
        }
        let keyNames = try await apiClient.getTimeseriesKeys(for: .device, entityId: tbDevice)
        XCTAssertTrue(keyNames.contains("SampleIMEI") && keyNames.contains("SampleBattery"), "Expected key missing in response!")
    }

    /**
     Test async getLatestTimeseries()
     getLatestTimeseries() receives at **max one value per key**
     */
    func getLatestTimeseries(apiClient: TBUserApiClient?, getValuesAsStrings: Bool, keys: [String]? = nil) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        var requested_keys = ["SampleIMEI", "SampleBattery"]
        if let keys = keys { requested_keys = keys }
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        let responseObject = try await apiClient.getLatestTimeseries(for: .device, entityId: tbDevice, keys: requested_keys, getValuesAsStrings: getValuesAsStrings)
        guard let sampleimei = responseObject["SampleIMEI"], let samplebattery = responseObject["SampleBattery"] else {
            XCTFail("Expected key missing in response!")
            return
        }
        // allow a few seconds of clock skew between the ThingsBoard server and the test machine
        XCTAssertLessThanOrEqual(sampleimei!.tsDt, Date().addingTimeInterval(5))
        XCTAssertLessThanOrEqual(samplebattery!.tsDt, Date().addingTimeInterval(5))
        if getValuesAsStrings {
            // reflect values-as-string case
            XCTAssertTrue(sampleimei?.value.stringVal == "999999999999999" && samplebattery?.value.stringVal == "100", "Expected different value/type!")
        } else {
            // reflect values-as-native-types case
            XCTAssertTrue(Int(sampleimei!.value.doubleVal!) == 999999999999999 && Int(samplebattery!.value.doubleVal!) == 100, "Expected different value/type!")
        }
    }

    /**
     Test async getTimeseries()
     getTimeSeries() receives **multiple values** for a time-series key **constraint** by its given parameters
     This test case evaluates simple time-series data retrieval for the last 7 days.
     */
    func getTimeseries(apiClient: TBUserApiClient?, getValuesAsStrings: Bool, keys: [String]? = nil) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        var requested_keys = ["SampleIMEI", "SampleBattery"]
        if let keys = keys { requested_keys = keys }
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        let endTs = Int64(Date().timeIntervalSince1970) * 1000
        let sevenDaysPast = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let startTs = Int64(sevenDaysPast!.timeIntervalSince1970) * 1000
        let responseObject = try await apiClient.getTimeseries(for: .device, entityId: tbDevice,
                                                               keys: requested_keys, startTs: startTs, endTs: endTs,
                                                               limit: 10, getValuesAsStrings: getValuesAsStrings)
        guard let sampleimei = responseObject["SampleIMEI"], let samplebattery = responseObject["SampleBattery"] else {
            XCTFail("Expected key missing in response!")
            return
        }
        if getValuesAsStrings {
            // reflect values-as-string case
            XCTAssertTrue(sampleimei[0].value.stringVal == "999999999999999" && samplebattery[0].value.stringVal == "100", "Expected different value/type!")
        } else {
            // reflect values-as-native-types case
            XCTAssertTrue(Int(sampleimei[0].value.doubleVal!) == 999999999999999 && Int(samplebattery[0].value.doubleVal!) == 100, "Expected different value/type!")
        }
    }

    /**
     Test async deleteEntityTimeseries()
     Delete time-series data for given time interval: Epoche 0 until now
     */
    func deleteEntityTimeseries(apiClient: TBUserApiClient?) async throws {
        let apiClient = try XCTUnwrap(apiClient)
        let dateTimeNow = Int64(Date().timeIntervalSince1970) * 1000
        let sampleKeys = ["SampleIMEI", "SampleBattery"]
        guard let tbDevice = self.tbDevice?.id.id else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant time-series keys as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
            return
        }
        try await apiClient.deleteEntityTimeseries(for: .device, entityId: tbDevice, keys: sampleKeys, startTs: 0, endTs: dateTimeNow, deleteLatest: true)
    }

    /**
     Test async logout
     */
    func logout(apiClient: TBUserApiClient?) async {
        await apiClient?.logout()
        XCTAssertNil(apiClient?.getAccessToken())
    }
}
