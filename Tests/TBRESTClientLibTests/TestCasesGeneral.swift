//
//  TestCasesGeneral.swift
//
//
//  Created by Johannes Kinzig on 28.08.24.
//
// Adopted API for Version: CE 3.7.0

import XCTest
@testable import TBRESTClientLib


class FunctionalTestCases: XCTestCase {
    
    // MARK: - TBDataModel instances
    var tbUser: User?
    var tbDevice: Device?
    
    // MARK: - Geneal Test Cases
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
        let expectResponseWithUserInfo = XCTestExpectation(description: "Expected response containing own user info!")
        apiClient?.getUser() { userinfo in
            self.tbUser = userinfo
            XCTAssertEqual(userinfo.name, expectedUsername)
            expectResponseWithUserInfo.fulfill()
        }
        wait(for: [expectResponseWithUserInfo], timeout: 3.0)
        return self.tbUser
    }
    
    /**
     Test getCustomerDevices() - for a given customer ID
     */
    func getCustomerDevices(apiClient: TBUserApiClient?) {
        let expectResponseWithCustomerDevices = XCTestExpectation(description: "Expected response containing customer Device objects!")
        if let customerId = self.tbUser?.customerId.id, let tenantId = self.tbUser?.tenantId.id {
            apiClient?.getCustomerDevices(customerId: customerId) { customerDevices in
                XCTAssertGreaterThanOrEqual(customerDevices.totalElements, 1)
                self.tbDevice = customerDevices[0]
                XCTAssertEqual(customerDevices[0]?.customerId.id , customerId)
                XCTAssertEqual(customerDevices[0]?.tenantId.id , tenantId)
                expectResponseWithCustomerDevices.fulfill()
            }
        }
        wait(for: [expectResponseWithCustomerDevices], timeout: 3.0)
    }
    
    /**
     Test getCustomerDeviceInfos() - for a given customer ID
     */
    func getCustomerDeviceInfos(apiClient: TBUserApiClient?) {
        let expectResponseWithCustomerDeviceInfos = XCTestExpectation(description: "Expected response containing customer's DeviceInfo objects!")
        if let customerId = self.tbUser?.customerId.id, let tenantId = self.tbUser?.tenantId.id {
            apiClient?.getCustomerDeviceInfos(customerId: customerId) { customerDevices in
                XCTAssertGreaterThanOrEqual(customerDevices.totalElements, 1)
                XCTAssertEqual(customerDevices[0]?.customerId.id , customerId)
                XCTAssertEqual(customerDevices[0]?.tenantId.id , tenantId)
                XCTAssertEqual(customerDevices[0]?.type , self.tbDevice?.type)
                expectResponseWithCustomerDeviceInfos.fulfill()
            }
        }
        wait(for: [expectResponseWithCustomerDeviceInfos], timeout: 3.0)
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
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    func getDeviceProfiles(apiClient: TBUserApiClient?) {
        let expectResponseWithCustomerDeviceProfiles = XCTestExpectation(description: "Expected response containing tenant's Device Profile objects!")
        apiClient?.registerAppErrorHandler { tbAppError in
            // fulfill with permission denied - not so good practice but do not let the test fail just in case we do not use a 'TENANT\_ADMIN' authority
            XCTAssertNotNil(tbAppError)
            XCTAssertEqual(tbAppError.status, 403)
            XCTAssertEqual(tbAppError.errorCode, 20)
            expectResponseWithCustomerDeviceProfiles.fulfill()
        }
        apiClient?.getDeviceProfiles() { deviceProfiles in
            if deviceProfiles.totalElements > 0 {
                // fulfill for received device profiles
                XCTAssertEqual(deviceProfiles[0]?.id.entityType, "DEVICE_PROFILE")
                expectResponseWithCustomerDeviceProfiles.fulfill()
            }
            else {
                XCTFail("Empty Device Profile Container is not helpful for integration testing...!")
            }
        }
        wait(for: [expectResponseWithCustomerDeviceProfiles], timeout: 3.0)
    }
}
