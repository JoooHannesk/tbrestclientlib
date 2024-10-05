//
//  tb-api-endpoints.swift
//
//
//  Created by Johannes Kinzig on 12.08.24.
//

protocol TbAPIEndpointsEnum: RawRepresentable where RawValue == String { }

// MARK: - API Endpoints
enum TbAPIEndpointsV1: String, TbAPIEndpointsEnum {
    case login = "/api/auth/login"
    case getUser = "/api/auth/user"
    case getCustomerDevices = "/api/customer/{?customerId?}/devices"
    case getCustomerDeviceInfos = "/api/customer/{?customerId?}/deviceInfos"
    case getDeviceProfileInfos =  "/api/deviceProfileInfos"
    case getDeviceProfiles = "/api/deviceProfiles"
    case getAttributeKeys = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/keys/attributes"
    case getAttributeKeysByScope = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/keys/attributes/{?scope?}"
    case saveEntityAttributes = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/attributes/{?scope?}"
    case getAttributes = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/values/attributes"
    case getAttributesByScope = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/values/attributes/{?scope?}"
    case deleteEntityAttributes = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/{?scope?}"
    case getTimeseriesKeys = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/keys/timeseries"
    case saveEntityTelemetry = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/timeseries/{?scope?}"
    case getLatestTimeseries = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/values/timeseries"
    case deleteEntityTimeseries = "/api/plugins/telemetry/{?entityType?}/{?entityId?}/timeseries/delete"
}

// MARK: - Query Parameters
public enum TbQuerySortProperty: String {
    case createdTime = "createdTime"
    case name = "name"
    case deviceProfileName = "deviceProfileName"
    case label = "label"
    case customerTitle = "customerTitle"
}

public enum TbQuerysortOrder: String {
    case ascending = "ASC"
    case descending = "DESC"
}

public enum TbQueryTransportType: String {
    case standard = "DEFAULT"
    case mqtt = "MQTT"
    case coap = "COAP"
    case lwm2m = "LWM2M"
    case snmp = "SNMP"
}

public enum TbEntityScopes: String {
    case server = "SERVER_SCOPE" /// for all entity types
    case client = "CLIENT_SCOPE" /// for devices
    case shared = "SHARED_SCOPE" /// for devices
    case any = "ANY" /// required by server to stay backwards compatible
}

public enum TbEntityTypes: String {
    case tenant = "TENANT"
    case customer = "CUSTOMER"
    case user = "USER"
    case dahsboard = "DASHBOARD"
    case asset = "ASSET"
    case device = "DEVICE"
    case alarm = "ALARM"
    case entitiyView = "ENTITY_VIEW"
}

// MARK: - URL Paths Modification
struct URLModifier {
    let searchString: String
    let replaceString: String
}

struct APIEndpointManager {
    private static var tbServerBaseURL: String = ""
    
    /**
     Set TB Server base url (without trailing slash)
     - Parameter baseURL: server base URL as String
     */
    internal static func setTbServerBaseURL(_ serverSettings: ServerSettings) {
        tbServerBaseURL = serverSettings.baseUrl
    }
    
    /**
     Get API endpoint url with path information
     - Parameter apiPath: API identifier as type conforming to protocol 'TbAPIEndpointsEnum'
     - Parameter replacePaths: replace paths in URL (optional)
     - Parameter appendQuery: append query parameters to URL
     - Returns: API endpoint URL as string
     */
    internal static func getEndpointURL(
        _ apiPath: some TbAPIEndpointsEnum,
        replacePaths: [URLModifier]? = nil,
        appendQuery: String? = nil
    ) -> String {
        var urlAsString = tbServerBaseURL + apiPath.rawValue
        if let replacePaths = replacePaths {
            for replacePath in replacePaths {
                urlAsString = urlAsString.replacingOccurrences(of: replacePath.searchString, with: replacePath.replaceString)
            }
        }
        if let appendQuery = appendQuery {
            urlAsString += "?" + appendQuery
        }
        return urlAsString
    }
    
    /**
     Get full qualified endpoint url with path and query parameters.
     - Parameter apiPath: API identifier as type conforming to protocol 'TbAPIEndpointsEnum'
     - Parameter replacePaths: replace paths in URL (optional)
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter deviceProfileId: String value representing the device profile id. For example, '784f394c-42b6-435a-983c-b7beff2784f9'
     - Parameter active: Boolean value indicating if a device is currently available and communicating with the cloud
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter keys: array of strings containing the keys
     - Parameter deleteAllDataForKeys: delete all time-series data for given key (should be false when used with `startTs`/`endTs`)
     - Parameter startTs: delete time-series data for given periode – specified by startTs and endTs (milliseconds, int64)
     - Parameter endTs: delete time-series data for given periode – specified by startTs and endTs (milliseconds, int64)
     - Parameter deleteLatest: delete latest value (stored in separate table for performance), if the value's timestamp matches the time-frame
     - Parameter rewriteLatestIfDeleted: rewrite latest value (stored in separate table for performance) if the value's timestamp matches the time-frame and `deleteLatest` is true;
     - Parameter transportType: Type of the transport the device profiles support: DEFAULT, MQTT, COAP, LWM2M, SNMP
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Returns: API endpoint URL as string
     */
    internal static func getEndpointURLWithQueryParameters(
        apiPath: some TbAPIEndpointsEnum,
        replacePaths: [URLModifier]? = nil,
        pageSize: Int32? = nil,
        page: Int32? = nil,
        type: String? = nil,
        deviceProfileId: String? = nil,
        active: Bool? = nil,
        textSearch: String? = nil,
        keys: [String]? = nil,
        deleteAllDataForKeys: Bool? = nil,
        startTs: Int64? = nil,
        endTs: Int64? = nil,
        deleteLatest: Bool? = nil,
        rewriteLatestIfDeleted: Bool? = nil,
        transportType: TbQueryTransportType? = nil,
        sortProperty: TbQuerySortProperty? = nil,
        sortOrder: TbQuerysortOrder? = nil
    ) -> String {
        var queryParameter = ""
        if let pageSize = pageSize { queryParameter += "&pageSize=\(pageSize)" }
        if let page = page { queryParameter += "&page=\(page)" }
        if let type = type { queryParameter += "&type=\(type)" }
        if let deviceProfileId = deviceProfileId { queryParameter += "&deviceProfileId=\(deviceProfileId)" }
        if let active = active { queryParameter += "&active=\(active)" }
        if let textSearch = textSearch { queryParameter += "&textSearch=\(textSearch)" }
        if let keys = keys { queryParameter += "&keys=\(keys.joined(separator: ","))" }
        if let deleteAllDataForKeys = deleteAllDataForKeys { queryParameter += "&deleteAllDataForKeys=\(deleteAllDataForKeys)" }
        if let startTs = startTs { queryParameter += "&startTs=\(startTs)" }
        if let endTs = endTs { queryParameter += "&endTs=\(endTs)" }
        if let deleteLatest = deleteLatest { queryParameter += "&deleteLatest=\(deleteLatest)" }
        if let rewriteLatestIfDeleted = rewriteLatestIfDeleted { queryParameter += "&rewriteLatestIfDeleted=\(rewriteLatestIfDeleted)"}
        if let transportType = transportType { queryParameter += "&transportType=\(transportType.rawValue)"}
        if let sortProperty = sortProperty { queryParameter += "&sortProperty=\(sortProperty.rawValue)" }
        if let sortOrder = sortOrder { queryParameter += "&sortOrder=\(sortOrder.rawValue)" }
        return getEndpointURL(apiPath, replacePaths: replacePaths, appendQuery: queryParameter)
    }
}

