//
//  TBRESTClientLib.swift
//  
//
//  Created by Johannes Kinzig on 30.07.24.
//
// Thingsboard Client Library - implementing the thingsboard administration / user-space api (not device api)

import Foundation

class TBUserApiClient: TBHTTPRequest {
    
    // MARK: - Properties
    typealias TBApiEndpoints = TbAPIEndpointsV1
    typealias AEM = APIEndpointManager
    private let serverSettings: ServerSettings
    private(set) var authData: AuthLogin
    
    
    // MARK: - Initialization
    /**
     Initialize TB client
     - Parameter baseUrlStr: server url as utf8 string without trailing slash (no API endpoint, just base server URL)
     - Parameter usernameStr: user's username as utf8 string
     - Parameter passwordStr: user's password as utf8 string
     - Parameter httpSessionHandler: HTTP session handler to use for http request
     - Note: Intention for httpSessionHandler: can take a mock-http session handler for unit testing the http calls
     */
    init?(baseUrlStr: String, usernameStr: String, passwordStr: String, httpSessionHandler: URLSessionProtocol) throws {
        guard !baseUrlStr.isEmpty && !usernameStr.isEmpty && !passwordStr.isEmpty else {
            throw TBHTTPClientRequestError.emptyLogin
        }
        serverSettings = ServerSettings(baseUrl: baseUrlStr, username: usernameStr, password: passwordStr)
        authData = AuthLogin(token: "", refreshToken: "")
        AEM.setTbServerBaseURL(self.serverSettings)
        super.init(httpSessionHandler: httpSessionHandler)
    }
    
    convenience init?(baseUrlStr: String, usernameStr: String, passwordStr: String) throws {
        try self.init(baseUrlStr: baseUrlStr, usernameStr: usernameStr, passwordStr: passwordStr, httpSessionHandler: URLSession.shared)
    }
    
    // MARK: – Authentication
    /**
     Request authentication with the thingsboard server to optain an authentication token
     - Parameter responseHandler: Register a function/method to be called after login succeeded
     - Returns: Void
     - Note: authData contains token and refreshToken after login succeeded
     */
    func login(responseHandler: ((AuthLogin) -> Void)? = nil) -> Void {
        let authDataDict: Dictionary<String, String> = ["username": serverSettings.username, "password": serverSettings.password]
        tbApiRequest(fromEndpoint: AEM.getEndpointURL(TBApiEndpoints.login),
                     withPayload: authDataDict,
                     expectedTBResponseObject: AuthLogin.self) { responseObject -> Void in
            self.authData = responseObject as! AuthLogin
            responseHandler?(self.authData)
        }
    }
    
    // MARK: - User related requests
    /**
     Get currently logged in user info
     - Parameter responseHandler: Register a function/method to be called after user info was fetched
     - Returns: Void
     */
    func getUser(responseHandler: ((User) -> Void)? = nil) -> Void {
        tbApiRequest(fromEndpoint: AEM.getEndpointURL(TBApiEndpoints.getUser),
                     usingMethod: .get,
                     authToken: self.authData,
                     expectedTBResponseObject: User.self) { responseObject -> Void in
            responseHandler?(responseObject as! User)
        }
    }
    
    // MARK: - Device related requests
    /**
     Get Customer Devices – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     Receives a page of devices assigned to the customer (by ID). Specify parameters to filter the results, which are wrapped inside a PageData object that allows to iterate over the result set using pagination.
     - Parameter customerId: A string value representing the customer id
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name.
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     */
    func getCustomerDevices(customerId: String,
                            pageSize: Int32 = Int32.max,
                            page: Int32 = 0,
                            type: String? = nil,
                            textSearch: String? = nil,
                            sortProperty: TbQuerySortProperty = .name,
                            sortOrder: TbQuerysortOrder = .ascending,
                            responseHandler: ((PageDataDevice) -> Void)?) -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getCustomerDevices,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: PageDataDevice.self) { responseObject -> Void in
            responseHandler?(responseObject as! PageDataDevice)
        }
    }
    
    /**
     Get Customer Device Infos – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     Receives a page of devices info objects assigned to the customer (by ID). Specify parameters to filter the results, which are wrapped inside a PageData object that allows you to iterate over the result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter deviceProfileId: String value representing the device profile id. For example, '784f394c-42b6-435a-983c-b7beff2784f9'
     - Parameter active: Boolean value indicating if a device is currently available and communicating with the cloud
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     */
    func getCustomerDeviceInfos(customerId: String,
                                pageSize: Int32 = Int32.max,
                                page: Int32 = 0,
                                type: String? = nil,
                                deviceProfileId: String? = nil,
                                active: Bool? = nil,
                                textSearch: String? = nil,
                                sortProperty: TbQuerySortProperty = .name,
                                sortOrder: TbQuerysortOrder = .ascending,
                                responseHandler: ((PageDataDevice) -> Void)?) -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getCustomerDeviceInfos,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                deviceProfileId: deviceProfileId,
                                                                active: active, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: PageDataDevice.self) { responseObject -> Void in
            responseHandler?(responseObject as! PageDataDevice)
        }
    }
}
