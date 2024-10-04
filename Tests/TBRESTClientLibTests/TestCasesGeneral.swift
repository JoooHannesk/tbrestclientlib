//
//  TestCasesGeneral.swift
//
//
//  Created by Johannes Kinzig on 28.08.24.
//
// Adopted API for library version: CE 3.7.0

import XCTest
@testable import TBRESTClientLib


class FunctionalTestCases: XCTestCase {
    
    // MARK: - TBDataModel instances
    var tbUser: User?
    var tbDevice: Device?
    var tbDevices: Array<Device>?
    
    // MARK: - General Test Cases
    /**
     Fails with "bad credentials" tb app error
     */
    func loginFails(apiClient: TBUserApiClient?) {
        let expectation = XCTestExpectation(description: "Expected login to fail!")
        XCTAssertNotNil(apiClient)
        
        func showLoginFailed(apperror: TBAppError) {
            XCTAssertNotNil(apperror)
            XCTAssertEqual(apperror.status, 401)
            XCTAssertEqual(apperror.errorCode, 10)
            expectation.fulfill()
        }
        
        apiClient?.registerAppErrorHandler(errorHandler: showLoginFailed)
        apiClient?.login()
        wait(for: [expectation], timeout: 3.0)
    }
    
    /**
     Test login() for success
     */
    func loginSucceeds(apiClient: TBUserApiClient?) {
        let expectLogin = XCTestExpectation(description: "Expected login!")
        XCTAssertNotNil(apiClient)
        
        apiClient?.registerAppErrorHandler { tbAppError in
            XCTFail("\(tbAppError)")
        }
        
        apiClient?.login() { authObject in
            XCTAssertTrue(!authObject.token.isEmpty && !authObject.refreshToken.isEmpty)
            expectLogin.fulfill()
        }
        wait(for: [expectLogin], timeout: 3.0)
    }
    
    /**
     Test getUser() – get current user info
     */
    @discardableResult
    func getUser(apiClient: TBUserApiClient?, expectedUsername: String) -> User? {
        let expectedResponseWithUserInfo = XCTestExpectation(description: "Expected response containing own user info!")
        apiClient?.getUser() { userinfo in
            self.tbUser = userinfo
            XCTAssertEqual(userinfo.name, expectedUsername)
            expectedResponseWithUserInfo.fulfill()
        }
        wait(for: [expectedResponseWithUserInfo], timeout: 3.0)
        return self.tbUser
    }
    
    /**
     Test getCustomerDevices() - for a given customer ID
     - Note: This test requires to have **at least two different devices** in the GetCustomerDevices.json resource file (for unit tests)
     or in your TB tenant (for integration tests)
     */
    @discardableResult
    func getCustomerDevices(apiClient: TBUserApiClient?) -> Array<Device>? {
        let expectedResponseWithCustomerDevices = XCTestExpectation(description: "Expected response containing customer Device objects!")
        if let customerId = self.tbUser?.customerId.id, let tenantId = self.tbUser?.tenantId.id {
            apiClient?.getCustomerDevices(customerId: customerId) { customerDevices in
                XCTAssertGreaterThanOrEqual(customerDevices.itemsOnPage, 2)
                self.tbDevice = customerDevices[0]
                XCTAssertEqual(customerDevices[0]?.customerId.id , customerId)
                XCTAssertEqual(customerDevices[0]?.tenantId.id , tenantId)
                self.tbDevices = customerDevices.getItemsInsideArray()
                expectedResponseWithCustomerDevices.fulfill()
            }
        }
        wait(for: [expectedResponseWithCustomerDevices], timeout: 3.0)
        return self.tbDevices
    }
    
    /**
     Test getCustomerDeviceInfos() - for a given customer ID
     */
    func getCustomerDeviceInfos(apiClient: TBUserApiClient?) {
        let expectedResponseWithCustomerDeviceInfos = XCTestExpectation(description: "Expected response containing customer's DeviceInfo objects!")
        if let customerId = self.tbUser?.customerId.id, let tenantId = self.tbUser?.tenantId.id {
            apiClient?.getCustomerDeviceInfos(customerId: customerId) { customerDevices in
                XCTAssertGreaterThanOrEqual(customerDevices.totalElements, 1)
                XCTAssertEqual(customerDevices[0]?.customerId.id , customerId)
                XCTAssertEqual(customerDevices[0]?.tenantId.id , tenantId)
                XCTAssertEqual(customerDevices[0]?.type , self.tbDevice?.type)
                expectedResponseWithCustomerDeviceInfos.fulfill()
            }
        }
        wait(for: [expectedResponseWithCustomerDeviceInfos], timeout: 3.0)
    }
    
    /**
     Test getDeviceProfileInfos()
     */
    func getDeviceProfileInfos(apiClient: TBUserApiClient?) {
        let expectResponseWithCustomerDeviceProfileInfos = XCTestExpectation(description: "Expected response containing tenants's Device Profile Info objects!")
        apiClient?.getDeviceProfileInfos() { deviceProfileInfos in
            if deviceProfileInfos.totalElements > 0 {
                XCTAssertEqual(deviceProfileInfos[0]?.id.entityType, "DEVICE_PROFILE")
                expectResponseWithCustomerDeviceProfileInfos.fulfill()
            }
            else {
                XCTFail("Empty Device Profile Container is not helpful for integration testing...!")
            }
        }
        wait(for: [expectResponseWithCustomerDeviceProfileInfos], timeout: 3.0)
    }
    
    /**
     Test getDeviceProfiles()
     - Note: works with 'TENANT\_ADMIN' authority only! Make sure to use a user with this authority when performing integration tests.
     */
    func getDeviceProfiles(apiClient: TBUserApiClient?) {
        let expectedResponseWithCustomerDeviceProfiles = XCTestExpectation(description: "Expected response containing tenant's Device Profile objects!")
        apiClient?.registerAppErrorHandler { tbAppError in
            // fulfill with permission denied - not so good practice but do not let the test fail just in case we do not use a 'TENANT\_ADMIN' authority
            XCTAssertNotNil(tbAppError)
            XCTAssertEqual(tbAppError.status, 403)
            XCTAssertEqual(tbAppError.errorCode, 20)
            expectedResponseWithCustomerDeviceProfiles.fulfill()
        }
        apiClient?.getDeviceProfiles() { deviceProfiles in
            if deviceProfiles.totalElements > 0 {
                // fulfill for received device profiles
                XCTAssertEqual(deviceProfiles[0]?.id.entityType, "DEVICE_PROFILE")
                expectedResponseWithCustomerDeviceProfiles.fulfill()
            }
            else {
                XCTFail("Empty Device Profile Container is not helpful for integration testing...!")
            }
        }
        wait(for: [expectedResponseWithCustomerDeviceProfiles], timeout: 3.0)
    }
    
    /**
     Test getAttributeKeys()
     */
    func getAttributeKeys(apiClient: TBUserApiClient?) {
        let expectedResponseWithAttributes = XCTestExpectation(description: "Expected response containing entity id's attributes keys")
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.getAttributeKeys(for: .device, entityId: tbDevice) { attrArray -> Void in
                if attrArray.contains("lastActivityTime"), attrArray.contains("lastConnectTime")  {
                    expectedResponseWithAttributes.fulfill()
                } else {
                    XCTFail("Expected keys missing in response!")
                }
            }
        } else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure to have at least two devices in your tenant, assigned to the \
                    current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponseWithAttributes], timeout: 3.0)
    }
    
    /**
     Test getAttributeKeysByScope()
     */
    func getAttributeKeysByScope(apiClient: TBUserApiClient?) {
        let expectedResponseWithAttributesScoped = XCTestExpectation(description: "Expected response containing entity id's attributes keys")
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.getAttributeKeysByScope(for: .device, entityId: tbDevice, scope: .server) { attrArray -> Void in
                if attrArray.contains("lastActivityTime"), attrArray.contains("lastConnectTime")  {
                    expectedResponseWithAttributesScoped.fulfill()
                } else {
                    XCTFail("Expected keys missing in response!")
                }
                expectedResponseWithAttributesScoped.fulfill()
            }
        } else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure to have at least two devices in your tenant, assigned to the \
                    current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponseWithAttributesScoped], timeout: 3.0)
    }
    
    /**
     Test saveEntityAttributes() – success
     **Run with integration tests only**
     */
    func saveEntityAttributesSuccess(apiClient: TBUserApiClient?) {
        let expectedResponse = XCTestExpectation(description: "Expected response...")
        let sampleAttributes = ["sampleAtt1String":"Hello Server", "sampleAtt2Bool": true, "sampleAtt3Int": 4, "sampleAtt4Double": 3.1415926] as [String : Any]
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.saveEntityAttributes(for: .device, entityId: tbDevice, attributesData: sampleAttributes, scope: .shared) {
                expectedResponse.fulfill()
            }
        } else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponse], timeout: 3.0)
    }
    
    /**
     Test saveEntityAttributes() – fails with unmatched Device ID
     Fails because device is not known
     **Run with integration tests only**
     */
    func saveEntityAttributesFailureUnmatchedDeviceID(apiClient: TBUserApiClient?) {
        let expectedResponseDeviceUnknown = XCTestExpectation(description: "Expected unknown device response...")
        apiClient?.registerAppErrorHandler { tbAppError in
            print("Test failed with error: \(tbAppError)")
            XCTAssertEqual(tbAppError.status, 999)
            expectedResponseDeviceUnknown.fulfill()
        }
        let sampleAttributes = ["sampleAtt1String":"Hello Server", "sampleAtt2String": "Hello Client"]
        apiClient?.saveEntityAttributes(for: .device, entityId: "784f394c-42b6-435a-983c-b7beff2784f9", attributesData: sampleAttributes, scope: .shared) {
            XCTFail("Expected server to respond with an error data model.")
        }
        wait(for: [expectedResponseDeviceUnknown], timeout: 3)
    }
    
    /**
     Test saveEntityAttributes() – fails with nonconforming UUID
     Fails because device is not known
     **Run with integration tests only**
     */
    func saveEntityAttributesFailureNonConformingUUID(apiClient: TBUserApiClient?) {
        let expectedResponseDeviceUnknown = XCTestExpectation(description: "Expected unknown device response...")
        apiClient?.registerAppErrorHandler { tbAppError in
            print("Test failed with error: \(tbAppError)")
            XCTAssertEqual(tbAppError.status, 400)
            expectedResponseDeviceUnknown.fulfill()
        }
        let sampleAttributes = ["sampleAtt1String":"Hello Server", "sampleAtt2Bool": true, "sampleAtt3Int": 4, "sampleAtt4Double": 3.1415926] as [String : Any]
        apiClient?.saveEntityAttributes(for: .device, entityId: "7null3928", attributesData: sampleAttributes, scope: .shared) {
            XCTFail("Expected server to respond with an error data model.")
        }
        wait(for: [expectedResponseDeviceUnknown], timeout: 3)
    }
    
    /**
     Test getAttributes
     For integration test to succeed requires that `saveEntityAttributesSuccess()` was run successfully
     */
    func getAttributesSuccess(apiClient: TBUserApiClient?) {
        let expectedResponse = XCTestExpectation(description: "Expected response with attributes...")
        apiClient?.registerAppErrorHandler { tbAppError in
            print("Test failed with error: \(tbAppError)")
            XCTFail(tbAppError.message)
        }
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.getAttributes(for: .device, entityId: tbDevice, keys: ["sampleAtt1String", "sampleAtt2Bool", "sampleAtt3Int", "sampleAtt4Double"]) { responseObject in
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
                    XCTAssertEqual(responseObject[index].value.intVal, 4)
                    att3 = true
                }
                if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt4Double"}) {
                    XCTAssertEqual(responseObject[index].value.doubleVal, 3.1415926)
                    att4 = true
                }
                if att1 && att2 && att3 && att4 {
                    expectedResponse.fulfill()
                } else {
                    XCTFail("Some of the expected attributes could be retrieved")
                }
            }
        } else {
            XCTFail("""
                Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                this test case and is assigned to the current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponse], timeout: 3.0)
    }
    
    /**
     Test getAttributesByScope
     For integration test to succeed requires that `saveEntityAttributesSuccess()` was run successfully
     */
    func getAttributesByScopeSuccess(apiClient: TBUserApiClient?) {
        let expectedResponse = XCTestExpectation(description: "Expected response with attributes...")
        apiClient?.registerAppErrorHandler { tbAppError in
            print("Test failed with error: \(tbAppError)")
            XCTFail(tbAppError.message)
        }
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.getAttributesByScope(for: .device, entityId: tbDevice, keys: ["sampleAtt1String", "sampleAtt2Bool", "sampleAtt3Int", "sampleAtt4Double"], scope: .shared) { responseObject in
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
                    XCTAssertEqual(responseObject[index].value.intVal, 4)
                    att3 = true
                }
                if let index = responseObject.firstIndex(where: {$0.key == "sampleAtt4Double"}) {
                    XCTAssertEqual(responseObject[index].value.doubleVal, 3.1415926)
                    att4 = true
                }
                if att1 && att2 && att3 && att4 {
                    expectedResponse.fulfill()
                } else {
                    XCTFail("Some of the expected attributes could not be retrieved")
                }
            }
        } else {
            XCTFail("""
                Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                this test case and is assigned to the current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponse], timeout: 3.0)
    }
    
    /**
     Test deleteEntityAttributes **Run with integration tests only**
     Test requires  that `saveEntityAttributesSuccess()` was run successfully!
     */
    func deleteEntityAttributes(apiClient: TBUserApiClient?) {
        let expectedResponse = XCTestExpectation(description: "Expected response...")
        let sampleAttributeKeys = ["sampleAtt1String", "sampleAtt2Bool", "sampleAtt3Int", "sampleAtt4Double"]
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.deleteEntityAttributes(for: .device, entityId: tbDevice, keys: sampleAttributeKeys, scope: .shared) {
                expectedResponse.fulfill()
            }
        } else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant has shared attributes as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponse], timeout: 3.0)
    }
    
    /**
     Test saveEntityTelemetry() – success
     **Run with integration tests only**
     */
    func saveEntityTelemetrySuccess(apiClient: TBUserApiClient?) {
        let expectedResponse = XCTestExpectation(description: "Expected response...")
        let sampleTimeseriesData = ["SampleIMEI": 999999999999999, "SampleBattery": 100] as [String : Any]
        // works as well
        // let sampleTimeseriesData = ["ts":1634712287000, "values": ["SampleIMEI": 999999999999999, "SampleBattery": 100]] as [String : Any]
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.saveEntityTelemetry(for: .device, entityId: tbDevice, timeseriesData: sampleTimeseriesData) {
                expectedResponse.fulfill()
            }
        } else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure that the first device in your tenant has time-series keys as required by \
                    this test case and is assigned to the current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponse], timeout: 3.0)
    }
    
    /**
     Test getAttributeKeys()
     */
    func getTimeseriesKeys(apiClient: TBUserApiClient?) {
        let expectedResponseWithKeyNames = XCTestExpectation(description: "Expected response containing entity id's time-series keys")
        if let tbDevice = self.tbDevice?.id.id {
            apiClient?.getTimeseriesKeys(for: .device, entityId: tbDevice) { keyNames -> Void in
                if keyNames.contains("SampleIMEI"), keyNames.contains("SampleBattery") {
                    expectedResponseWithKeyNames.fulfill()
                } else {
                    XCTFail("Expected key missing in response!")
                }
            }
        } else {
            XCTFail("""
                    Device empty, test cannot continue! Make sure to have at least one device in your tenant, assigned to the \
                    current user which is authenticating for this integration test!
                """)
        }
        wait(for: [expectedResponseWithKeyNames], timeout: 3.0)
    }
}
