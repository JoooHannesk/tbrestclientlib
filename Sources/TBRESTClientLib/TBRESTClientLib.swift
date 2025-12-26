//
//  TBRESTClientLib.swift
//
//
//  Created by Johannes Kinzig on 30.07.24.
//
// Thingsboard Client Library - implementing the thingsboard administration / user-space api (not device api)
//

import Foundation
import OSLog

public class TBUserApiClient: TBHTTPRequest {
    // MARK: - Properties
    private var aem: APIEndpointManager
    private var serverSettings: ServerSettings
    private(set) var authData: AuthLogin?
    
    
    // MARK: - Initializers
    /**
     Initialize TB client
     
     - Parameter baseUrlStr: server url as utf8 string without trailing slash (no API endpoint, just base server URL)
     - Parameter username: user's username as utf8 string
     - Parameter password: user's password as utf8 string
     - Parameter httpSessionHandler: HTTP session handler to use for http request
     - Parameter apiEndpointVersion: API version, currently only .v1 supported because no other version is currently implemented.
     - Parameter logger: Logger (from OSLog) instance (optional)
     - Note: Intention for httpSessionHandler: can take a mock-http session handler for unit testing the http calls.
     This initializer's intention is mainly to be used when performing unit testing. When using the library it is recommended to use the
     convenience initializer.
     */
    public init?(baseUrlStr: String, username: String, password: String, apiEndpointVersion: TbApiEndpointsVersion = .v1, httpSessionHandler: URLSessionProtocol = URLSession.shared, logger: Logger? = nil) throws {
        serverSettings = ServerSettings(baseUrl: baseUrlStr, username: username, password: password)
        guard serverSettings.allPartsGiven() else {
            throw TBHTTPClientRequestError.emptyLogin
        }
        aem = APIEndpointManager(serverSettings: self.serverSettings, apiEndpoints: apiEndpointVersion.version)
        super.init(httpSessionHandler: httpSessionHandler, logger: logger)
    }
    
    /**
     Initialize TB client by providing access token
     
     - Parameter baseUrlStr: server url as utf8 string without trailing slash (no API endpoint, just base server URL)
     - Parameter accessToken: AuthLogin object containing `token` and `refreshToken`
     - Parameter apiEndpointVersion: API version, currently only .v1 supported because no other version is currently implemented.
     - Parameter logger: Logger (from OSLog) instance (optional)
     - Note: Re-use tokens from an existing/previous session instead of optaining new ones from the server.
     */
    public init?(baseUrlStr: String, accessToken: AuthLogin, apiEndpointVersion: TbApiEndpointsVersion = .v1, httpSessionHandler: URLSessionProtocol = URLSession.shared, logger: Logger? = nil) throws {
        serverSettings = ServerSettings(baseUrl: baseUrlStr, username: "", password: "")
        guard accessToken.allPartsGiven() && serverSettings.urlGiven() else {
            throw TBHTTPClientRequestError.emptyLogin
        }
        authData = accessToken
        aem = APIEndpointManager(serverSettings: self.serverSettings, apiEndpoints: apiEndpointVersion.version)
        super.init(httpSessionHandler: httpSessionHandler, logger: logger)
    }
    
    // MARK: – Authentication
    /**
     Request authentication with server to optain an authentication token
     
     - Parameter responseHandler: takes an 'AuthLogin' as parameter and is called upon successful server response
     - Note: Property `authData`  contains token and refreshToken after login succeeded
     */
    public func login(responseHandler: ((AuthLogin) -> Void)? = nil) throws -> Void {
        guard serverSettings.allPartsGiven() else {
            throw TBHTTPClientRequestError.emptyLogin
        }
        let authDataDict: Dictionary<String, String> = ["username": serverSettings.username, "password": serverSettings.password]
        tbApiRequest(fromEndpoint: aem.getEndpointURL(\.login),
                     withPayload: authDataDict,
                     expectedTBResponseType: AuthLogin.self) { responseObject -> Void in
            if responseObject is AuthLogin {
                self.authData = responseObject as? AuthLogin
                if let authData = self.authData {
                    responseHandler?(authData)
                }
            }
        }
    }
    
    /**
     Request authentication with the server to optain/renew the authentication token
     
     - Parameter username: user's username as utf8 string
     - Parameter password: user's password as utf8 string
     - Parameter responseHandler: takes an 'AuthLogin' as parameter and is called upon successful server response
     - Note: authData contains **new** tokens after login succeeded
     */
    public func login(withUsername username: String, andPassword password: String, responseHandler: ((AuthLogin) -> Void)? = nil) throws -> Void {
        serverSettings.username = username
        serverSettings.password = password
        try login(responseHandler: responseHandler)
    }
    
    /**
     Return the login data
     
     Return the login data which were given during initialisation. Ideal when having to manage multiple instances and need to distinguish between them.
     - Returns: a tuple with (serverUrl, username) - both as String
     - Note: For security reasons, the password is not returned!
     */
    public func getLoginData() -> (String, String) {
        return (serverSettings.baseUrl, serverSettings.username)
    }
    
    /**
     Return access token
     
     Returns the access token currently in use. Useful for session recovery to continue an existing authentication context.
     - Returns: authData (of type ``AuthLogin``)
     - Note: Returns `nil` if authentication has not been attempted, or if the provided credentials were invalid. Call ``login(responseHandler:)`` before accessing this value.
     */
    public func getAccessToken() -> AuthLogin? {
        return self.authData
    }
    
    /**
     Logout
     
     Request user logout on ThingsBoard server and destroy access token locally.
     - Note: Calling `logout()` on the server side serves the purpose of audit logging, as the logout request is written to the audit log. The main logout procedure, however, takes place on the client side by clearing the access token.
     */
    public func logout() -> Void {
        tbApiRequest(fromEndpoint: aem.getEndpointURL(\.logout),
                     usingMethod: .post,
                     authToken: self.authData,
                     expectedTBResponseType: TBAppError.self) { responseObject in
            self.logger?.warning("Logout failed: \(String(describing: responseObject))")
        }
        self.authData = nil
    }


    // MARK: - User related requests
    /**
     Get currently logged in user info
     
     - Parameter responseHandler: takes a 'User' as parameter and is called upon successful server response
     - Note: for supported data models as parameters see: TbDataModels.swift
     */
    public func getUser(responseHandler: ((User) -> Void)? = nil) -> Void {
        tbApiRequest(fromEndpoint: aem.getEndpointURL(\.getUser),
                     usingMethod: .get,
                     authToken: self.authData,
                     expectedTBResponseType: User.self) { responseObject -> Void in
            responseHandler?(responseObject as! User)
        }
    }
    
    /**
     Get customer info
     
     A user can only request information for the customer account they belong to.
     - Parameter customerId: A string value representing the customer id
     - Parameter responseHandler: takes a ``Customer`` as parameter and is called upon successful retrieval of the customer information
     */
    public func getCustomerById(customerId: String, responseHandler: ((Customer) -> Void)? = nil) -> Void {
        let endpointURL = aem.getEndpointURL(\.getCustomerById, replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)])
        tbApiRequest(fromEndpoint: endpointURL,
                     usingMethod: .get,
                     authToken: self.authData,
                     expectedTBResponseType: Customer.self) { responseObject -> Void in
            responseHandler?(responseObject as! Customer)
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
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter responseHandler: takes a 'PageDataContainer<Device>' as parameter and is called upon successful server response
     - Note: for supported data models as parameters see: TbDataModels.swift
     */
    public func getCustomerDevices(customerId: String,
                            pageSize: Int32 = Int32.max,
                            page: Int32 = 0,
                            type: String? = nil,
                            textSearch: String? = nil,
                            sortProperty: TbQuerySortProperty = .name,
                            sortOrder: TbQuerySortOrder = .ascending,
                            responseHandler: ((PaginationDataContainer<Device>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getCustomerDevices,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: PaginationDataContainer<Device>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<Device>)
        }
    }
    
    /**
     Get Customer Device Infos – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Receives a page of devices info objects assigned to the customer (by ID). Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over the result set using pagination.
     - Parameter customerId: customer id (UUID) as string
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter deviceProfileId: String value representing the device profile id. For example, '784f394c-42b6-435a-983c-b7beff2784f9'
     - Parameter active: Boolean value indicating if a device is currently available and communicating with the cloud
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter responseHandler: takes a 'PageDataContainer<Device>' as parameter and is called upon successful server response
     - Note: for supported data models as parameters see: `TbDataModels.swift`
     */
    public func getCustomerDeviceInfos(customerId: String,
                                pageSize: Int32 = Int32.max,
                                page: Int32 = 0,
                                type: String? = nil,
                                deviceProfileId: String? = nil,
                                active: Bool? = nil,
                                textSearch: String? = nil,
                                sortProperty: TbQuerySortProperty = .name,
                                sortOrder: TbQuerySortOrder = .ascending,
                                responseHandler: ((PaginationDataContainer<Device>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getCustomerDeviceInfos,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                deviceProfileId: deviceProfileId,
                                                                active: active, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: PaginationDataContainer<Device>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<Device>)
        }
    }

    /**
     Create a new device or update an existing one – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     To create a new device, don't provide the device id. When creating a device, ThingsBoard takes care for creating the device id by itself.
     An access token is generated in case it was not provided in the 'accessToken' parameter. ThingsBoard responds with the newly created device.
     To update an existing device provide the device id in addition to the other required members.
     Use unique identifiers (e.g. MAC address, IMEI or serial number) for the device *name*. The *label* field is designed for user-friendly presentation and is not required to be unique.

     - Parameters accessToken: the access token to use for the (new) device
     - Returns: the created or updated device

     - Note: If you don't provide a `deviceProfileId` or `customerId` for a new device, it will be created with their corresponding
     default values. **Catuion: If you don't provide these fields for an existing device during update, these fields will be set to their default values!**
     */
    public func saveDevice(name: String,
                           label: String? = nil,
                           deviceId: UUID? = nil,
                           deviceProfileName: String?,
                           deviceProfileId: UUID? = nil,
                           tenantId: UUID? = nil,
                           customerId: UUID? = nil,
                           accessToken: String? = nil) {
        var deviceData = Dictionary<String, Any>()

        deviceData["name"] = name
        if let label = label { deviceData["label"] = label }
        if let deviceProfileName = deviceProfileName { deviceData["deviceProfileName"] = deviceProfileName }

        if let deviceId = deviceId {
            deviceData["id"] = ID(id: deviceId.uuidString, entityType: .device).getAsDict()
        }

        if let deviceProfileId = deviceProfileId {
            deviceData["deviceProfileId"] = deviceProfileId
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
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter transportType: Type of the transport the device profiles support: DEFAULT, MQTT, COAP, LWM2M, SNMP
     - Parameter responseHandler: takes a 'PageDataContainer<DeviceProfile>' as parameter and is called upon successful server response
     
     */
    public func getDeviceProfileInfos(
        pageSize: Int32 = Int32.max,
        page: Int32 = 0,
        textSearch: String? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerySortOrder = .ascending,
        transportType: TbQueryTransportType? = nil,
        responseHandler: ((PaginationDataContainer<DeviceProfileInfo>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getDeviceProfileInfos,
                                                                pageSize: pageSize, page: page,
                                                                textSearch: textSearch, transportType: transportType,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: PaginationDataContainer<DeviceProfileInfo>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<DeviceProfileInfo>)
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
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter responseHandler: takes a 'PageDataContainer<DeviceProfile>' as parameter and is called upon successful server response
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    public func getDeviceProfiles(
        pageSize: Int32 = Int32.max,
        page: Int32 = 0,
        textSearch: String? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerySortOrder = .ascending,
        responseHandler: ((PaginationDataContainer<DeviceProfile>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getDeviceProfiles,
                                                                pageSize: pageSize, page: page, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: PaginationDataContainer<DeviceProfile>.self) { responseObject -> Void in
            responseHandler?(responseObject as! PaginationDataContainer<DeviceProfile>)
        }
    }
    
    // MARK: - Attributes and Telemetry
    /**
     Get Attribute Keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Get a set of unique attribute keys for the requested entity.
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter responseHandler: takes an 'Array<String>' as parameter and is called upon successful server response
     - Note: The response includes merged key names for all scopes (supported scopes: ``TbQueryEntityScopes``).
     */
    public func getAttributeKeys(for entityType: TbQueryEntityTypes, entityId: String, responseHandler: ((Array<String>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributeKeys, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)
        ])
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: Array<String>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Array<String>)
        }
    }
    
    /**
     Get Attribute Keys by Scope – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Get a set of unique attribute keys for the requested entity and given scope
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter scope: scope in which the attribute is managed, as defined in ``TbQueryEntityScopes``
     - Parameter responseHandler: takes an 'Array<String>' as parameter and is called upon successful server response
     - Note: The response includes key names for requested scope.
     */
    public func getAttributeKeysByScope(for entityType: TbQueryEntityTypes, entityId: String,
                                        scope: TbQueryEntityScopes, responseHandler: ((Array<String>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributeKeysByScope, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ])
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: Array<String>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Array<String>)
        }
    }
    
    /**
     Create or update the attributes based on entity id and the specified attribute scope – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Implementes the endpoint saveEntityAttributesV2
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter attributesData: attributes with values as key value pairs, contained inside a dictionary
     - Parameter scope: scope in which the attribute is managed as defined in ``TbQueryEntityScopes``
     - Parameter responseHandler: takes no parameters and is called upon successful server response
     - Note: Attribute scopes depend on the entity type: .server - supported for all entity; .shared - supported for devices
     */
    public func saveEntityAttributes(for entityType: TbQueryEntityTypes, entityId: String, attributesData:  Dictionary<String, Any>,
                                     scope: TbQueryEntityScopes, responseHandler: (() -> Void)? = nil)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.saveEntityAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ])
        tbApiRequest(fromEndpoint: endpointURL, withPayload: attributesData,
                     authToken: self.authData, expectedTBResponseType: [String].self) { _ in
            responseHandler?()
        }
    }
    
    /**
     Get all entity attributes (scope-independent)  by keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     - Parameter entityType:tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter responseHandler: takes an array containing items of type ``AttributesResponse``
     */
    public func getAttributes(for entityType: TbQueryEntityTypes, entityId: String, keys: [String] = [], responseHandler: (([AttributesResponse]) -> Void)?) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)
        ], keys: keys)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get, authToken: self.authData, expectedTBResponseType: [AttributesResponse].self) { responseObject in
            responseHandler?(responseObject as! [AttributesResponse])
        }
    }
    
    /**
     Get entity attributes by scope and by keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     - Parameter entityType:tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter scope: scope in which the attribute is managed as defined in ``TbQueryEntityScopes``
     - Parameter responseHandler: takes an array containing items of type ``AttributesResponse``
     */
    public func getAttributesByScope(for entityType: TbQueryEntityTypes, entityId: String, keys: [String] = [], scope: TbQueryEntityScopes, responseHandler: (([AttributesResponse]) -> Void)?) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributesByScope, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ], keys: keys)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get, authToken: self.authData, expectedTBResponseType: [AttributesResponse].self) { responseObject in
            responseHandler?(responseObject as! [AttributesResponse])
        }
    }
    
    /**
     Delete entity attributes by scope and keys – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     - Parameter entityType:tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter scope: scope in which the attribute is managed as defined in ``TbQueryEntityScopes``
     - Parameter responseHandler: takes no parameters, is called on success
     */
    public func deleteEntityAttributes(for entityType: TbQueryEntityTypes, entityId: String, keys: [String], scope: TbQueryEntityScopes, responseHandler: (() -> Void)? = nil) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.deleteEntityAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ], keys: keys)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .delete, authToken: self.authData, expectedTBResponseType: [String].self) { _ in
            responseHandler?()
        }
    }
    
    /**
     Save entity telemetry data for the given entity – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter timeseriesData: timeseries data as key-value pairs (as dictionary)
     - Parameter responseHandler: takes no parameters and is called upon successful server response
     - Note: This library supports pushing time-series data to server but with limited functionality (simple json object).
     This limitation is accepted, as the main scope of this library is not to mimic client device functionality. In principle, this function
     may be used to push mass-data to the server – which results in repetitive function-calls leading to repetitive http requests.
     */
    public func saveEntityTelemetry(for entityType: TbQueryEntityTypes, entityId: String, timeseriesData: Dictionary<String, Any>, responseHandler: (() -> Void)? = nil) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.saveEntityTelemetry, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId),
            URLModifier(searchString: "{?scope?}", replaceString: TbQueryEntityScopes.any.rawValue)
        ])
        tbApiRequest(fromEndpoint: endpointURL, withPayload: timeseriesData,
                     authToken: self.authData, expectedTBResponseType: [String].self) { _ in
            responseHandler?()
        }
    }
    
    /**
     Get unique time-series key names for the given entity – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter responseHandler: takes an 'Array<String>' as parameter and is called upon successful server response
     */
    public func getTimeseriesKeys(for entityType: TbQueryEntityTypes, entityId: String, responseHandler: ((Array<String>) -> Void)?)
    -> Void {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTimeseriesKeys, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)
        ])
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: Array<String>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Array<String>)
        }
    }
    
    /**
     Get the **latest** time-series data from server – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Latest time-series data is stored in a different table for performance reasons (according to ThingsBoard docs) and can therefore be retrieved
     via a seperate API call.
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the time-series keys
     - Parameter getValuesAsStrings: Get values from servers as strings (not as native datatypes)
     - Parameter responseHandler: takes an 'Dictionary<String, TimeseriesResponse?>' as parameter and is called upon successful server response
     - Note: Retrieving values as strings is recommended if a time-series value is e.g. of type JSON-String.
     JSON-String values cannot be treated by this library as native datatypes currently and should therefore be retrieved as strings. To get the value from a ``TimeseriesResponse`` object, refer to
     ``TimeseriesResponse/value`` and ``MplValueType``.
     */
    public func getLatestTimeseries(for entityType: TbQueryEntityTypes, entityId: String, keys: Array<String>? = nil,
                                    getValuesAsStrings: Bool = true, responseHandler: ((Dictionary<String, TimeseriesResponse?>) -> Void)?) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTimeseries, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId)],
                                                                keys: keys, useStrictDataTypes: !getValuesAsStrings)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: Dictionary<String, [TimeseriesResponse]>.self) { responseObject -> Void in
            let responseObjectArray = responseObject as! Dictionary<String, [TimeseriesResponse]>
            let responseTimeseries: Dictionary<String, TimeseriesResponse?> = responseObjectArray.mapValues { $0.last }
            responseHandler?(responseTimeseries)
        }
    }
    
    /**
     Get time-series data from server – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Retrieve time-series data according to specified time interval and (optional) aggregation functions:
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the time-series keys
     - Parameter startTs: delete time-series data for given periode – specified by startTs and endTs (unix time in milliseconds, int64)
     - Parameter endTs: delete time-series data for given periode – specified by startTs and endTs (unix time milliseconds, int64)
     - Parameter intervalType: Value representing the type fo the interval to use for the aggregation function. Supported interval types: ``TbQueryIntervalTypes``
     - Parameter interval: Int64 value specifying the aggregation interval range in milliseconds (in combination with `intervalType` set to `.milliseconds`
     - Parameter timeZone: String value specifying the timezone being used to calculate exact timestamps for ``TbQueryIntervalTypes``
     - Parameter limit: Int value to limit time-series datapoint retrival. Not more than `limit` datapoints wil be fetched – used only in combination with `aggregation` set to `.none`
     - Parameter aggregation: Value specifying the aggregation function, if `interval` or `intervalType`is not given `aggregation` parameter will use `.none`
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter getValuesAsStrings: Get values from servers as strings (not as native datatypes)
     - Parameter responseHandler: takes an 'Dictionary<String, [TimeseriesResponse]>' as parameter and is called upon successful server response
     - Note: Retrieving values as strings is recommended if a time-series value is e.g. of type JSON-String.
     JSON-String values cannot be treated by this library as native datatype currently and should therefore be retrieved as strings. To get the value from a ``TimeseriesResponse`` object, refer to
     ``TimeseriesResponse/value`` and ``MplValueType``.
     */
    public func getTimeseries(for entityType: TbQueryEntityTypes, entityId: String, keys: Array<String>, startTs: Int64, endTs: Int64,
                              intervalType: TbQueryIntervalTypes? = nil, interval: Int64? = nil, timeZone: String? = nil,
                              limit: Int? = nil, aggregation: TbQueryAggregationOptions = .none, sortOrder: TbQuerySortOrder = .ascending,
                              getValuesAsStrings: Bool = true, responseHandler: ((Dictionary<String, [TimeseriesResponse]>) -> Void)?) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTimeseries,
                                                                replacePaths: [
                                                                    URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
                                                                    URLModifier(searchString: "{?entityId?}", replaceString: entityId)
                                                                ],
                                                                keys: keys, startTs: startTs, endTs: endTs,
                                                                intervalType: intervalType, interval: interval,
                                                                timeZone: timeZone, limit: limit,
                                                                aggregation: aggregation, orderBy: sortOrder,
                                                                useStrictDataTypes: !getValuesAsStrings)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                     authToken: self.authData, expectedTBResponseType: Dictionary<String, [TimeseriesResponse]>.self) { responseObject -> Void in
            responseHandler?(responseObject as! Dictionary<String, [TimeseriesResponse]>)
        }
    }
    
    /**
     Delete entity time-series data – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority
     
     Delete time-series data for selected entity based on its id, type and keys
     - Parameter entityType:tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter deleteAllDataForKeys: delete all time-series data for given key (should be false when used with `startTs`/`endTs`)
     - Parameter startTs: delete time-series data for given periode – specified by startTs and endTs (unix time in milliseconds, int64)
     - Parameter endTs: delete time-series data for given periode – specified by startTs and endTs (unix time milliseconds, int64)
     - Parameter deleteLatest: delete latest value (stored in separate table for performance), if the value's timestamp matches the time-frame
     - Parameter rewriteLatestIfDeleted: rewrite latest value (stored in separate table for performance) if the value's timestamp matches the time-frame and `deleteLatest` is true;
     the replacement value will be fetched from the 'time-series' table, and its timestamp will be the most recent one before the defined time-range
     - Parameter responseHandler: takes no parameters and is called upon successful server response
     */
    public func deleteEntityTimeseries(for entityType: TbQueryEntityTypes, entityId: String, keys: [String],
                                       deleteAllDataForKeys: Bool? = nil,
                                       startTs: Int64? = nil, endTs: Int64? = nil,
                                       deleteLatest: Bool? = nil, rewriteLatestIfDeleted: Bool? = nil,
                                       responseHandler: (() -> Void)? = nil) {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.deleteEntityTimeseries,
                                                                replacePaths: [
                                                                    URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
                                                                    URLModifier(searchString: "{?entityId?}", replaceString: entityId)
                                                                ],
                                                                keys: keys, deleteAllDataForKeys: deleteAllDataForKeys, startTs: startTs, endTs: endTs,
                                                                deleteLatest: deleteLatest, rewriteLatestIfDeleted: rewriteLatestIfDeleted)
        tbApiRequest(fromEndpoint: endpointURL, usingMethod: .delete, authToken: self.authData, expectedTBResponseType: [String].self) { _ in
            responseHandler?()
        }
    }
}
