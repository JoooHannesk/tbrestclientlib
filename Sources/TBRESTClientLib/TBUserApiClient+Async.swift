//
//  TBUserApiClient+Async.swift
//
//
//  Async/await counterparts of the callback-based public API.
//  Each method mirrors its callback-based sibling in TBRESTClientLib.swift: same name,
//  same parameters and defaults, just without the responseHandler parameter. The result
//  is returned and failures are thrown as ``TBHTTPClientRequestError`` instead of being
//  routed to handlers registered via ``TBHTTPRequest/registerErrorHandler(apiErrorHandler:systemErrorHandler:)``.
//

import Foundation

extension TBUserApiClient {

    // MARK: – Authentication
    /**
     Request authentication with server to optain an authentication token (async)

     - Returns: an ``AuthLogin`` object containing token and refreshToken
     - Throws: ``TBSystemError/emptyLogin`` when username/password are empty, otherwise ``TBHTTPClientRequestError``
     (`.api` for server errors such as bad credentials, `.system` for transport errors)
     - Note: Property `authData` contains token and refreshToken after login succeeded.
     In an async context `try await client.login()` selects this overload; the callback-based
     ``login(responseHandler:)`` remains available in synchronous contexts.
     */
    @discardableResult
    public func login() async throws -> AuthLogin {
        guard serverSettings.allPartsGiven() else {
            throw TBSystemError.emptyLogin
        }
        let authDataDict: Dictionary<String, String> = ["username": serverSettings.username, "password": serverSettings.password]
        let responseObject = try await tbApiRequest(fromEndpoint: aem.getEndpointURL(\.login),
                                                    withPayload: authDataDict,
                                                    expectedTBResponseType: AuthLogin.self)
        guard let authLogin = responseObject as? AuthLogin else {
            throw TBHTTPClientRequestError.system(.undecodableResponse(body: String(describing: responseObject)))
        }
        self.authData = authLogin
        return authLogin
    }

    /**
     Request authentication with the server to optain/renew the authentication token (async)

     - Parameter username: user's username as utf8 string
     - Parameter password: user's password as utf8 string
     - Returns: an ``AuthLogin`` object containing the **new** token and refreshToken
     - Throws: ``TBSystemError/emptyLogin`` when username/password are empty, otherwise ``TBHTTPClientRequestError``
     */
    @discardableResult
    public func login(withUsername username: String, andPassword password: String) async throws -> AuthLogin {
        serverSettings.username = username
        serverSettings.password = password
        return try await login()
    }

    /**
     Logout (async)

     Request user logout on ThingsBoard server and destroy access token locally.
     - Note: Server-side failures are logged and ignored, matching the callback-based ``logout()``;
     the local access token is always cleared.
     */
    public func logout() async {
        _ = try? await tbApiRequest(fromEndpoint: aem.getEndpointURL(\.logout),
                                    usingMethod: .post,
                                    authToken: self.authData,
                                    expectedTBResponseType: TBAppError.self)
        self.authData = nil
    }


    // MARK: - User related requests
    /**
     Get currently logged in user info (async)

     - Returns: the ``User`` object
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getUser() async throws -> User {
        let responseObject = try await tbApiRequest(fromEndpoint: aem.getEndpointURL(\.getUser),
                                                    usingMethod: .get,
                                                    authToken: self.authData,
                                                    expectedTBResponseType: User.self)
        return responseObject as! User
    }

    /**
     Get customer info (async)

     A user can only request information for the customer account they belong to.
     - Parameter customerId: A string value representing the customer id
     - Returns: the ``Customer`` object
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getCustomerById(customerId: UUID) async throws -> Customer {
        let endpointURL = aem.getEndpointURL(\.getCustomerById, replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId.uuidString)])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL,
                                                    usingMethod: .get,
                                                    authToken: self.authData,
                                                    expectedTBResponseType: Customer.self)
        return responseObject as! Customer
    }

    // MARK: - Device related requests
    /**
     Get Customer Devices (async) – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Receives a page of devices assigned to the customer (by ID). Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over the result set using pagination.
     - Parameter customerId: A UUID value representing the customer id
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name.
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Returns: a `PaginationDataContainer<Device>`
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getCustomerDevices(customerId: UUID,
                                   pageSize: Int32 = Int32.max,
                                   page: Int32 = 0,
                                   type: String? = nil,
                                   textSearch: String? = nil,
                                   sortProperty: TbQuerySortProperty = .name,
                                   sortOrder: TbQuerySortOrder = .ascending)
    async throws -> PaginationDataContainer<Device> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getCustomerDevices,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId.uuidString)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: PaginationDataContainer<Device>.self)
        return responseObject as! PaginationDataContainer<Device>
    }

    /**
     Get Customer Device Infos (async) – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

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
     - Returns: a `PaginationDataContainer<Device>`
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getCustomerDeviceInfos(customerId: UUID,
                                       pageSize: Int32 = Int32.max,
                                       page: Int32 = 0,
                                       type: String? = nil,
                                       deviceProfileId: String? = nil,
                                       active: Bool? = nil,
                                       textSearch: String? = nil,
                                       sortProperty: TbQuerySortProperty = .name,
                                       sortOrder: TbQuerySortOrder = .ascending)
    async throws -> PaginationDataContainer<Device> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getCustomerDeviceInfos,
                                                                replacePaths: [URLModifier(searchString: "{?customerId?}", replaceString: customerId.uuidString)],
                                                                pageSize: pageSize, page: page, type: type,
                                                                deviceProfileId: deviceProfileId,
                                                                active: active, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: PaginationDataContainer<Device>.self)
        return responseObject as! PaginationDataContainer<Device>
    }

    /**
     Get Tenant Devices (async) – requires 'TENANT\_ADMIN' authority

     Receives a page of devices owned by the tenant. Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over the result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name.
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Returns: a `PaginationDataContainer<Device>`
     - Throws: ``TBHTTPClientRequestError``
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    public func getTenantDevices(pageSize: Int32 = Int32.max,
                                 page: Int32 = 0,
                                 type: String? = nil,
                                 textSearch: String? = nil,
                                 sortProperty: TbQuerySortProperty = .name,
                                 sortOrder: TbQuerySortOrder = .ascending)
    async throws -> PaginationDataContainer<Device> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTenantDevices,
                                                                pageSize: pageSize, page: page, type: type,
                                                                textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: PaginationDataContainer<Device>.self)
        return responseObject as! PaginationDataContainer<Device>
    }

    /**
     Get device by ID (async) – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Before returning the device object, the server checks if the device belongs to the tenant or customer (depending
     whether the request comes from a TENANT\_ADMIN' or 'CUSTOMER\_USER').
     - Parameter deviceId: device id as UUID
     - Returns: the ``Device`` object
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getDeviceById(deviceId: UUID) async throws -> Device {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getDeviceById,
                                                                replacePaths: [URLModifier(searchString: "{?deviceId?}", replaceString: deviceId.uuidString)])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Device.self)
        return responseObject as! Device
    }

    /**
     Get device info by ID (async) – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Before returning the device info object, the server checks if the device belongs to the tenant or customer (depending
     whether the request comes from a TENANT\_ADMIN' or 'CUSTOMER\_USER').
     - Parameter deviceId: device id as UUID
     - Returns: the ``Device`` object
     - Throws: ``TBHTTPClientRequestError``
     - Note: To maintain a consistent interface, this library uses the ``Device`` type for both standard device data and extended *Device Info* results. Rather
     than using two separate models, extended fields (such as `customerTitle` and `deviceProfileName`) are integrated directly into the `Device` object.
     Please note that these extended fields will be *nil* when using standard API endpoints; they are only populated when performing specific *DeviceInfo* requests.
     */
    public func getDeviceInfoById(deviceId: UUID) async throws -> Device {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getDeviceInfoById,
                                                                replacePaths: [URLModifier(searchString: "{?deviceId?}", replaceString: deviceId.uuidString)])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Device.self)
        return responseObject as! Device
    }

    /**
     Create a new device or update an existing one (async) – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     To create a new device, don't provide the device id. When creating a device, ThingsBoard takes care for creating the device id by itself.
     An access token is generated in case it was not provided in the `accessToken` parameter. ThingsBoard responds with the newly created device.
     To update an existing device provide the device id in addition to the other required members.
     Use unique identifiers (e.g. MAC address, IMEI or serial number) for the device *name*. The *label* field is designed for user-friendly presentation and is not required to be unique.
     - Parameter name: device name
     - Parameter label: device label
     - Parameter deviceId: device id as UUID
     - Parameter type: device profile name
     - Parameter description: device description (user defined description)
     - Parameter deviceProfileId: device profile id as UUID
     - Parameter tenantId: tenant id as UUID
     - Parameter customerId: customer id as UUID
     - Parameter gateway: device acts as a gateway; default: false
     - Parameter overwriteActivityTime: if the device is a gateway, it can overwrite the end-devices activity times
     - Parameter accessToken: the access token to use for the (new) device; if the device gets updated and this `accessToken` stays empty, the old access token will be used
     - Returns: the new/updated ``Device`` object
     - Throws: ``TBHTTPClientRequestError``
     - Note: If you don't provide a `description`, `deviceProfileName` and `deviceProfileId` or `customerId` for a new device, it will be created with their corresponding
     default values. **Caution: If you don't provide these fields for an existing device during edit/update, these fields will be (re)set to their default values and may remain empty or get cleared!
     This may result in a device which is not bound to a customer anymore or lost its device profile settings.**
     */
    public func saveDevice(name: String,
                           label: String? = nil,
                           deviceId: UUID? = nil,
                           type: String? = nil,
                           description: String = "",
                           deviceProfileId: UUID? = nil,
                           tenantId: UUID? = nil,
                           customerId: UUID? = nil,
                           gateway: Bool = false,
                           overwriteActivityTime: Bool = false,
                           accessToken: String = "") async throws -> Device {
        // payload construction mirrors saveDevice(...responseHandler:) — keep in sync
        var deviceData = Dictionary<String, Any>()

        deviceData["name"] = name
        deviceData["additionalInfo"] = AdditionalInfoDevice(gateway: gateway, overwriteActivityTime: overwriteActivityTime, description: description).asDict
        if let label = label { deviceData["label"] = label }
        if let type = type { deviceData["type"] = type }

        if let deviceId = deviceId {
            deviceData["id"] = ID(id: deviceId, entityType: .device).asDict
        }

        if let deviceProfileId = deviceProfileId {
            deviceData["deviceProfileId"] = ID(id: deviceProfileId, entityType: .deviceProfile).asDict
        }

        if let tenantId = tenantId {
            deviceData["tenantId"] = ID(id: tenantId, entityType: .tenant).asDict
        }

        if let customerId = customerId {
            deviceData["customerId"] = ID(id: customerId, entityType: .customer).asDict
        }

        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.saveDevice,
                                                                replacePaths: [URLModifier(searchString: "{?accessToken?}", replaceString: accessToken)])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, withPayload: deviceData,
                                                    authToken: self.authData, expectedTBResponseType: Device.self)
        return responseObject as! Device
    }

    /**
     Delete device (async) – requires 'TENANT\_ADMIN' authority

     Delete device for given device id. Delete device and all its relations.
     - Parameter deviceId: device id as UUID
     - Throws: ``TBHTTPClientRequestError``
     */
    public func deleteDevice(deviceId: UUID) async throws {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.deleteDevice,
                                                                replacePaths: [URLModifier(searchString: "{?deviceId?}", replaceString: deviceId.uuidString)])
        _ = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .delete,
                                   authToken: self.authData, expectedTBResponseType: [String].self)
    }


    // MARK: - Device Profile related requests
    /**
     Get Device Profile Infos (async) – requires 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Receives a page of devices profile info objects defined for the tenant. Specify parameters to filter the results, which are wrapped inside a PageData object that
     allows to iterate over result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter transportType: Type of the transport the device profiles support: DEFAULT, MQTT, COAP, LWM2M, SNMP
     - Returns: a `PaginationDataContainer<DeviceProfileInfo>`
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getDeviceProfileInfos(
        pageSize: Int32 = Int32.max,
        page: Int32 = 0,
        textSearch: String? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerySortOrder = .ascending,
        transportType: TbQueryTransportType? = nil)
    async throws -> PaginationDataContainer<DeviceProfileInfo> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getDeviceProfileInfos,
                                                                pageSize: pageSize, page: page,
                                                                textSearch: textSearch, transportType: transportType,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: PaginationDataContainer<DeviceProfileInfo>.self)
        return responseObject as! PaginationDataContainer<DeviceProfileInfo>
    }

    /**
     Get Device Profiles (async) – requires 'TENANT\_ADMIN' authority

     Receives a page of devices profile objects defined for the tenant. Specify parameters to filter the results which are wrapped insude a PageData object that
     allows to iterate over result set using pagination.
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Returns: a `PaginationDataContainer<DeviceProfile>`
     - Throws: ``TBHTTPClientRequestError``
     - Note: works with 'TENANT\_ADMIN' authority only!
     */
    public func getDeviceProfiles(
        pageSize: Int32 = Int32.max,
        page: Int32 = 0,
        textSearch: String? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerySortOrder = .ascending)
    async throws -> PaginationDataContainer<DeviceProfile> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getDeviceProfiles,
                                                                pageSize: pageSize, page: page, textSearch: textSearch,
                                                                sortProperty: sortProperty, sortOrder: sortOrder)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: PaginationDataContainer<DeviceProfile>.self)
        return responseObject as! PaginationDataContainer<DeviceProfile>
    }

    // MARK: - Attributes and Telemetry
    /**
     Get Attribute Keys (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Get a set of unique attribute keys for the requested entity.
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Returns: an `Array<String>` containing the attribute key names
     - Throws: ``TBHTTPClientRequestError``
     - Note: The response includes merged key names for all scopes (supported scopes: ``TbQueryEntityScopes``).
     */
    public func getAttributeKeys(for entityType: TbQueryEntityTypes, entityId: UUID) async throws -> Array<String> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributeKeys, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString)
        ])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Array<String>.self)
        return responseObject as! Array<String>
    }

    /**
     Get Attribute Keys by Scope (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Get a set of unique attribute keys for the requested entity and given scope
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter scope: scope in which the attribute is managed, as defined in ``TbQueryEntityScopes``
     - Returns: an `Array<String>` containing the attribute key names for the requested scope
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getAttributeKeysByScope(for entityType: TbQueryEntityTypes, entityId: UUID,
                                        scope: TbQueryEntityScopes) async throws -> Array<String> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributeKeysByScope, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Array<String>.self)
        return responseObject as! Array<String>
    }

    /**
     Create or update the attributes based on entity id and the specified attribute scope (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Implementes the endpoint saveEntityAttributesV2
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter attributesData: attributes with values as key value pairs, contained inside a dictionary
     - Parameter scope: scope in which the attribute is managed as defined in ``TbQueryEntityScopes``
     - Throws: ``TBHTTPClientRequestError``
     - Note: Attribute scopes depend on the entity type: .server - supported for all entity; .shared - supported for devices
     */
    public func saveEntityAttributes(for entityType: TbQueryEntityTypes, entityId: UUID, attributesData: Dictionary<String, Any>,
                                     scope: TbQueryEntityScopes) async throws {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.saveEntityAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ])
        _ = try await tbApiRequest(fromEndpoint: endpointURL, withPayload: attributesData,
                                   authToken: self.authData, expectedTBResponseType: [String].self)
    }

    /**
     Get all entity attributes (scope-independent) by keys (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Returns: an array containing items of type ``AttributesResponse``
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getAttributes(for entityType: TbQueryEntityTypes, entityId: UUID, keys: [String] = []) async throws -> [AttributesResponse] {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString)
        ], keys: keys)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: [AttributesResponse].self)
        return responseObject as! [AttributesResponse]
    }

    /**
     Get entity attributes by scope and by keys (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter scope: scope in which the attribute is managed as defined in ``TbQueryEntityScopes``
     - Returns: an array containing items of type ``AttributesResponse``
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getAttributesByScope(for entityType: TbQueryEntityTypes, entityId: UUID, keys: [String] = [], scope: TbQueryEntityScopes) async throws -> [AttributesResponse] {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getAttributesByScope, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ], keys: keys)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: [AttributesResponse].self)
        return responseObject as! [AttributesResponse]
    }

    /**
     Delete entity attributes by scope and keys (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter scope: scope in which the attribute is managed as defined in ``TbQueryEntityScopes``
     - Throws: ``TBHTTPClientRequestError``
     */
    public func deleteEntityAttributes(for entityType: TbQueryEntityTypes, entityId: UUID, keys: [String], scope: TbQueryEntityScopes) async throws {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.deleteEntityAttributes, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString),
            URLModifier(searchString: "{?scope?}", replaceString: scope.rawValue)
        ], keys: keys)
        _ = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .delete,
                                   authToken: self.authData, expectedTBResponseType: [String].self)
    }

    /**
     Save entity telemetry data for the given entity (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter timeseriesData: timeseries data as key-value pairs (as dictionary)
     - Throws: ``TBHTTPClientRequestError``
     - Note: This library supports pushing time-series data to server but with limited functionality (simple json object).
     This limitation is accepted, as the main scope of this library is not to mimic client device functionality. In principle, this function
     may be used to push mass-data to the server – which results in repetitive function-calls leading to repetitive http requests.
     */
    public func saveEntityTelemetry(for entityType: TbQueryEntityTypes, entityId: UUID, timeseriesData: Dictionary<String, Any>) async throws {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.saveEntityTelemetry, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString),
            URLModifier(searchString: "{?scope?}", replaceString: TbQueryEntityScopes.any.rawValue)
        ])
        _ = try await tbApiRequest(fromEndpoint: endpointURL, withPayload: timeseriesData,
                                   authToken: self.authData, expectedTBResponseType: [String].self)
    }

    /**
     Get unique time-series key names for the given entity (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Returns: an `Array<String>` containing the time-series key names
     - Throws: ``TBHTTPClientRequestError``
     */
    public func getTimeseriesKeys(for entityType: TbQueryEntityTypes, entityId: UUID) async throws -> Array<String> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTimeseriesKeys, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString)
        ])
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Array<String>.self)
        return responseObject as! Array<String>
    }

    /**
     Get the **latest** time-series data from server (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Latest time-series data is stored in a different table for performance reasons (according to ThingsBoard docs) and can therefore be retrieved
     via a seperate API call.
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the time-series keys
     - Parameter getValuesAsStrings: Get values from servers as strings (not as native datatypes)
     - Returns: a `Dictionary<String, TimeseriesResponse?>` keyed by time-series key, each value being the latest ``TimeseriesResponse`` (or nil)
     - Throws: ``TBHTTPClientRequestError``
     - Note: Retrieving values as strings is recommended if a time-series value is e.g. of type JSON-String.
     JSON-String values cannot be treated by this library as native datatypes currently and should therefore be retrieved as strings. To get the value from a ``TimeseriesResponse`` object, refer to
     ``TimeseriesResponse/value`` and ``MplValueType``.
     */
    public func getLatestTimeseries(for entityType: TbQueryEntityTypes, entityId: UUID, keys: Array<String>? = nil,
                                    getValuesAsStrings: Bool = true) async throws -> Dictionary<String, TimeseriesResponse?> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTimeseries, replacePaths: [
            URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
            URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString)],
                                                                keys: keys, useStrictDataTypes: !getValuesAsStrings)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Dictionary<String, [TimeseriesResponse]>.self)
        let responseObjectArray = responseObject as! Dictionary<String, [TimeseriesResponse]>
        return responseObjectArray.mapValues { $0.last }
    }

    /**
     Get time-series data from server (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Retrieve time-series data according to specified time interval and (optional) aggregation functions:
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the time-series keys
     - Parameter startTs: retrieve time-series data for given periode – specified by startTs and endTs (unix time in milliseconds, int64)
     - Parameter endTs: retrieve time-series data for given periode – specified by startTs and endTs (unix time milliseconds, int64)
     - Parameter intervalType: Value representing the type fo the interval to use for the aggregation function. Supported interval types: ``TbQueryIntervalTypes``
     - Parameter interval: Int64 value specifying the aggregation interval range in milliseconds (in combination with `intervalType` set to `.milliseconds`
     - Parameter timeZone: String value specifying the timezone being used to calculate exact timestamps for ``TbQueryIntervalTypes``
     - Parameter limit: Int value to limit time-series datapoint retrival. Not more than `limit` datapoints wil be fetched – used only in combination with `aggregation` set to `.none`
     - Parameter aggregation: Value specifying the aggregation function, if `interval` or `intervalType`is not given `aggregation` parameter will use `.none`
     - Parameter sortOrder: sort results in ascending or descending order, state according to ``TbQuerySortOrder``; default: `.ascending`
     - Parameter getValuesAsStrings: Get values from servers as strings (not as native datatypes)
     - Returns: a `Dictionary<String, [TimeseriesResponse]>` keyed by time-series key
     - Throws: ``TBHTTPClientRequestError``
     - Note: Retrieving values as strings is recommended if a time-series value is e.g. of type JSON-String.
     JSON-String values cannot be treated by this library as native datatype currently and should therefore be retrieved as strings. To get the value from a ``TimeseriesResponse`` object, refer to
     ``TimeseriesResponse/value`` and ``MplValueType``.
     */
    public func getTimeseries(for entityType: TbQueryEntityTypes, entityId: UUID, keys: Array<String>, startTs: Int64, endTs: Int64,
                              intervalType: TbQueryIntervalTypes? = nil, interval: Int64? = nil, timeZone: String? = nil,
                              limit: Int? = nil, aggregation: TbQueryAggregationOptions = .none, sortOrder: TbQuerySortOrder = .ascending,
                              getValuesAsStrings: Bool = true) async throws -> Dictionary<String, [TimeseriesResponse]> {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.getTimeseries,
                                                                replacePaths: [
                                                                    URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
                                                                    URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString)
                                                                ],
                                                                keys: keys, startTs: startTs, endTs: endTs,
                                                                intervalType: intervalType, interval: interval,
                                                                timeZone: timeZone, limit: limit,
                                                                aggregation: aggregation, orderBy: sortOrder,
                                                                useStrictDataTypes: !getValuesAsStrings)
        let responseObject = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .get,
                                                    authToken: self.authData, expectedTBResponseType: Dictionary<String, [TimeseriesResponse]>.self)
        return responseObject as! Dictionary<String, [TimeseriesResponse]>
    }

    /**
     Delete entity time-series data (async) – 'TENANT\_ADMIN' or 'CUSTOMER\_USER' authority

     Delete time-series data for selected entity based on its id, type and keys
     - Parameter entityType: tb entity types as defined in ``TbQueryEntityTypes`` enum
     - Parameter entityId: entitiy id
     - Parameter keys: array of strings containing the keys
     - Parameter deleteAllDataForKeys: delete all time-series data for given key (should be false when used with `startTs`/`endTs`)
     - Parameter startTs: delete time-series data for given periode – specified by startTs and endTs (unix time in milliseconds, int64)
     - Parameter endTs: delete time-series data for given periode – specified by startTs and endTs (unix time milliseconds, int64)
     - Parameter deleteLatest: delete latest value (stored in separate table for performance), if the value's timestamp matches the time-frame
     - Parameter rewriteLatestIfDeleted: rewrite latest value (stored in separate table for performance) if the value's timestamp matches the time-frame and `deleteLatest` is true;
     the replacement value will be fetched from the 'time-series' table, and its timestamp will be the most recent one before the defined time-range
     - Throws: ``TBHTTPClientRequestError``
     */
    public func deleteEntityTimeseries(for entityType: TbQueryEntityTypes, entityId: UUID, keys: [String],
                                       deleteAllDataForKeys: Bool? = nil,
                                       startTs: Int64? = nil, endTs: Int64? = nil,
                                       deleteLatest: Bool? = nil, rewriteLatestIfDeleted: Bool? = nil) async throws {
        let endpointURL = aem.getEndpointURLWithQueryParameters(apiPath: \.deleteEntityTimeseries,
                                                                replacePaths: [
                                                                    URLModifier(searchString: "{?entityType?}", replaceString: entityType.rawValue),
                                                                    URLModifier(searchString: "{?entityId?}", replaceString: entityId.uuidString)
                                                                ],
                                                                keys: keys, deleteAllDataForKeys: deleteAllDataForKeys, startTs: startTs, endTs: endTs,
                                                                deleteLatest: deleteLatest, rewriteLatestIfDeleted: rewriteLatestIfDeleted)
        _ = try await tbApiRequest(fromEndpoint: endpointURL, usingMethod: .delete,
                                   authToken: self.authData, expectedTBResponseType: [String].self)
    }
}
