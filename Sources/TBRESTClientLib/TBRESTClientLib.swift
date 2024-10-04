//
//  TBRESTClientLib.swift
//
//
//  Created by Johannes Kinzig on 30.07.24.
//
// Thingsboard Client Library - implementing the thingsboard administration / user-space api (not device api)

import Foundation

public class TBUserApiClient: TBHTTPRequest {
    
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
     - Note: Intention for httpSessionHandler: can take a mock-http session handler for unit testing the http calls.
     This initializer's intention is mainly to be used when performing unit testing. When using the library it is recommended to use the
     convenience initializer.
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
    
    /**
     Initialize TB client
     - Parameter baseUrlStr: server url as utf8 string without trailing slash (no API endpoint, just base server URL)
     - Parameter usernameStr: user's username as utf8 string
     - Parameter passwordStr: user's password as utf8 string
     - Parameter httpSessionHandler: HTTP session handler to use for http request
     */
    public convenience init?(baseUrlStr: String, usernameStr: String, passwordStr: String) throws {
        try self.init(baseUrlStr: baseUrlStr, usernameStr: usernameStr, passwordStr: passwordStr, httpSessionHandler: URLSession.shared)
    }
    
    // MARK: – Authentication
    /**
     Request authentication with the thingsboard server to optain an authentication token
     - Parameter responseHandler: takes an 'AuthLogin' as parameter and is called upon successful server response
     - Returns: Void
     - Note: authData contains token and refreshToken after login succeeded
     */
    public func login(responseHandler: ((AuthLogin) -> Void)? = nil) -> Void {
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
     - Parameter responseHandler: takes a 'User' as parameter and is called upon successful server response
     - Returns: Void
     - Note: for supported data models as parameters see: TbDataModels.swift
     */
    public func getUser(responseHandler: ((User) -> Void)? = nil) -> Void {
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
     Receives a page of devices assigned to the customer (by ID). Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over the result set using pagination.
     - Parameter customerId: A string value representing the customer id
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name.
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Parameter responseHandler: takes a 'PageDataContainer<Device>' as parameter and is called upon successful server response
     - Returns: Void
     - Note: for supported data models as parameters see: TbDataModels.swift
     */
    public func getCustomerDevices(customerId: String,
                            pageSize: Int32 = Int32.max,
                            page: Int32 = 0,
                            type: String? = nil,
                            textSearch: String? = nil,
                            sortProperty: TbQuerySortProperty = .name,
                            sortOrder: TbQuerysortOrder = .ascending,
                            responseHandler: ((PaginationDataContainer<Device>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getCustomerDevices,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: PaginationDataContainer<Device>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<Device>)
        }
    }
    
    /**
     Get Customer Device Infos – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     Receives a page of devices info objects assigned to the customer (by ID). Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over the result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter deviceProfileId: String value representing the device profile id. For example, '784f394c-42b6-435a-983c-b7beff2784f9'
     - Parameter active: Boolean value indicating if a device is currently available and communicating with the cloud
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Parameter responseHandler: takes a 'PageDataContainer<Device>' as parameter and is called upon successful server response
     - Returns: Void
     - Note: for supported data models as parameters see: TbDataModels.swift
     */
    public func getCustomerDeviceInfos(customerId: String,
                                pageSize: Int32 = Int32.max,
                                page: Int32 = 0,
                                type: String? = nil,
                                deviceProfileId: String? = nil,
                                active: Bool? = nil,
                                textSearch: String? = nil,
                                sortProperty: TbQuerySortProperty = .name,
                                sortOrder: TbQuerysortOrder = .ascending,
                                responseHandler: ((PaginationDataContainer<Device>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getCustomerDeviceInfos,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                deviceProfileId: deviceProfileId,
                                                                active: active, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: PaginationDataContainer<Device>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<Device>)
        }
    }
    
    
    // MARK: - Device Profile related requests
    /**
     Get Device Profile Infos – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     Receives a page of devices profile info objects defined for the tenant. Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Parameter transportType: Type of the transport the device profiles support: DEFAULT, MQTT, COAP, LWM2M, SNMP
     - Parameter responseHandler: takes a 'PageDataContainer<DeviceProfile>' as parameter and is called upon successful server response
     - Returns: void
     */
    public func getDeviceProfileInfos(
        pageSize: Int32 = Int32.max,
        page: Int32 = 0,
        textSearch: String? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerysortOrder = .ascending,
        transportType: TbQueryTransportType? = nil,
        responseHandler: ((PaginationDataContainer<DeviceProfile>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getDeviceProfileInfos,
                                                                pageSize: pageSize, page: page,
                                                                textSearch: textSearch, transportType: transportType,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: PaginationDataContainer<DeviceProfile>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<DeviceProfile>)
        }
    }
    
    /**
     Get Device Profiles – requires 'TENANT\_ADMIN' authority
     Receives a page of devices profile objects defined for the tenant. Specify parameters to filter the results which are wrapped insude a PageData object that
     allows to iterate over result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Parameter responseHandler: takes a 'PageDataContainer<DeviceProfile>' as parameter and is called upon successful server response
     - Returns: void
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    public func getDeviceProfiles(
        pageSize: Int32 = Int32.max,
        page: Int32 = 0,
        textSearch: String? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerysortOrder = .ascending,
        responseHandler: ((PaginationDataContainer<DeviceProfile>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getDeviceProfiles,
                                                                pageSize: pageSize, page: page, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: PaginationDataContainer<DeviceProfile>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<DeviceProfile>)
        }
    }
    
    // MARK: - Attributes and Telemetry
    /**
     Get Attribute Keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     Get a set of unique attribute keys for the requested entity.
     - Parameter entityType: tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter responseHandler: takes an 'Array<String>' as parameter and is called upon successful server response
     - Note: The response will include merged key names set for all attribute scopes: server - for all entity types, client - for devices, shared - for devices
     */
    public func getAttributeKeys(for entityType: TbEntityTypes, entityId: String, responseHandler: ((Array<String>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getAttributeKeys, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)
        ])
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: Array<String>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Array<String>)
        }
    }
    
    /**
     Get Attribute Keys by Scope – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     Get a set of unique attribute keys for the requested entity and given scope
     - Parameter entityType: tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter scope: scope in which the attribute is managed, as defined in ``TbAttributesScope``
     - Parameter responseHandler: takes an 'Array<String>' as parameter and is called upon successful server response
     - Note: The response will include merged key names set for all attribute scopes: server - for all entity types, client - for devices, shared - for devices
     */
    public func getAttributeKeysByScope(for entityType: TbEntityTypes, entityId: String,
                                        scope: TbEntityScopes, responseHandler: ((Array<String>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getAttributeKeysByScope, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ])
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: Array<String>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Array<String>)
        }
    }
    
    /**
     Create or update the attributes based on entity id and the specified attribute scope – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     Implementes the endpoint saveEntityAttributesV2
     - Parameter entityType: tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter attributesData: attributes with values as key value pairs, contained inside a dictionary
     - Parameter scope: scope in which the attribute is managed as defined in ``TbAttributesScope``
     - Parameter responseHandler: takes no parameters and is called upon successful server response
     - Note: Attribute scopes depend on the entity type: .server - supported for all entity; .shared - supported for devices
     */
    public func saveEntityAttributes(for entityType: TbEntityTypes, entityId: String, attributesData:  Dictionary<String, Any>,
                                     scope: TbEntityScopes, responseHandler: (() -> Void)? = nil)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.saveEntityAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ])
        tbApiRequest(fromEndpoint: endpointURL, withPayload: attributesData,
                     authToken: self.authData, expectedTBResponseObject: [String].self) { _ in
            responseHandler?()
        }
    }
    
    /**
     Get all entity attributes (scope-independent)  by keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     - Parameter entityType:tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter responseHandler: takes an array containing items of type ``AttributesResponse``
     */
    public func getAttributes(for entityType: TbEntityTypes, entityId: String, keys: [String] = [], responseHandler: (([AttributesResponse]) -> Void)?) {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)
        ], keys: keys)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get, authToken: self.authData, expectedTBResponseObject: [AttributesResponse].self) { responseObject in
            responseHandler?(responseObject as! [AttributesResponse])
        }
    }
    
    /**
     Get entity attributes by scope and by keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     - Parameter entityType:tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter scope: scope in which the attribute is managed as defined in ``TbAttributesScope``
     - Parameter responseHandler: takes an array containing items of type ``AttributesResponse``
     */
    public func getAttributesByScope(for entityType: TbEntityTypes, entityId: String, keys: [String] = [], scope: TbEntityScopes, responseHandler: (([AttributesResponse]) -> Void)?) {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getAttributesByScope, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ], keys: keys)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get, authToken: self.authData, expectedTBResponseObject: [AttributesResponse].self) { responseObject in
            responseHandler?(responseObject as! [AttributesResponse])
        }
    }
    
    /**
     Delete entity attributes by scope and keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     - Parameter entityType:tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter scope: scope in which the attribute is managed as defined in ``TbAttributesScope``
     - Parameter responseHandler: takes no parameters, is called on success
     */
    public func deleteEntityAttributes(for entityType: TbEntityTypes, entityId: String, keys: [String], scope: TbEntityScopes, responseHandler: (() -> Void)? = nil) {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.deleteEntityAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ], keys: keys)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .delete, authToken: self.authData, expectedTBResponseObject: [String].self) { _ in
            responseHandler?()
        }
    }
    
    
    /**
     Save entity telemetry data for the given entity – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     - Parameter entityType: tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter timeseriesData: timeseries data as key-value pairs (as dictionary)
     - Parameter responseHandler: takes no parameters and is called upon successful server response
     - Note: This library supports pushing time-series data to server but with limited functionality (simple json object).
     This limitation is accepted, as the main scope of this library is not to mimic client device functionality. In principle, this function
     may be used to push mass-data to the server – which results in repetitive function-calls leading to repetitive http requests.
     */
    func saveEntityTelemetry(for entityType: TbEntityTypes, entityId: String, timeseriesData: Dictionary<String, Any>, responseHandler: (() -> Void)? = nil) {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.saveEntityTelemetry, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: TbEntityScopes.any.rawValue)
        ])
        tbApiRequest(fromEndpoint: endpointURL, withPayload: timeseriesData,
                     authToken: self.authData, expectedTBResponseObject: [String].self) { _ in
            responseHandler?()
        }
    }
    
    /**
     Get unique time-series key names for the given entity – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority.
     - Parameter entityType: tb entity types as defined in ``TbEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter responseHandler: takes an 'Array<String>' as parameter and is called upon successful server response
     */
    public func getTimeseriesKeys(for entityType: TbEntityTypes, entityId: String, responseHandler: ((Array<String>) -> Void)?)
    -> Void {
        let endpointURL = AEM.getEndpointURLWithQueryParameters(apiPath: TBApiEndpoints.getTimeseriesKeys, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)
        ])
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseObject: Array<String>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Array<String>)
        }
    }
    
    
    // TODO: implement deleteEntityTimeseries
    
}
