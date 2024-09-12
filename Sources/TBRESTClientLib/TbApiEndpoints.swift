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
}


// MARK: - Query Parameters
enum TbQuerySortProperty: String {
    case createdTime = "createdTime"
    case name = "name"
    case deviceProfileName = "deviceProfileName"
    case label = "label"
    case customerTitle = "customerTitle"
}

enum TbQuerysortOrder: String {
    case ascending = "ASC"
    case descending = "DESC"
}

enum TbQueryTransportType: String {
    case standard = "DEFAULT"
    case mqtt = "MQTT"
    case coap = "COAP"
    case lwm2m = "LWM2M"
    case snmp = "SNMP"
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
     Get query parameter string
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter deviceProfileId: String value representing the device profile id. For example, '784f394c-42b6-435a-983c-b7beff2784f9'
     - Parameter active: Boolean value indicating if a device is currently available and communicating with the cloud
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter transportType: transport type (defined for a device), either: DEFAULT, MQTT, COAP, LWM2M, SNMP
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Returns: query parameters as String
     */
    private static func assembleQueryParameters(
        pageSize: Int32,
        page: Int32,
        type: String? = nil,
        deviceProfileId: String? = nil,
        active: Bool? = nil,
        textSearch: String? = nil,
        transportType: TbQueryTransportType? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerysortOrder = .ascending
    ) -> String {
        // always present according to API specification
        var queryParameter = "&pageSize=\(pageSize)&page=\(page)&sortProperty=\(sortProperty.rawValue)&sortOrder=\(sortOrder.rawValue)"
        if let type = type { queryParameter += "&type=\(type)" }
        if let deviceProfileId = deviceProfileId { queryParameter += "&deviceProfileId=\(deviceProfileId)" }
        if let active = active { queryParameter += "&active=\(active)" }
        if let textSearch = textSearch { queryParameter += "&textSearch=\(textSearch)" }
        if let transportType = transportType { queryParameter += "&transportType=\(transportType.rawValue)"}
        return queryParameter
    }
    
    /**
     Get full qualified endpoint url with path and query parameters
     - Parameter apiPath: API identifier as type conforming to protocol 'TbAPIEndpointsEnum'
     - Parameter replacePaths: replace paths in URL (optional)
     - Parameter pageSize: Maximum amount of entities in a one page
     - Parameter page: Sequence number of page starting from 0
     - Parameter type: Device type as the name of the device profile
     - Parameter deviceProfileId: String value representing the device profile id. For example, '784f394c-42b6-435a-983c-b7beff2784f9'
     - Parameter active: Boolean value indicating if a device is currently available and communicating with the cloud
     - Parameter textSearch: The case insensitive 'substring' filter based on the device name
     - Parameter sortProperty: sort resutls according to enumeration 'TbQuerySortProperty'; default: .name
     - Parameter sortOrder: sort results in ascending or descending order, state according to 'TbQuerysortOrder'; default: .ascending
     - Returns: API endpoint URL as string
     */
    internal static func getEndpointURLWithQueryParameters(
        apiPath: some TbAPIEndpointsEnum,
        replacePaths: [URLModifier]? = nil,
        pageSize: Int32,
        page: Int32,
        type: String? = nil,
        deviceProfileId: String? = nil,
        active: Bool? = nil,
        textSearch: String? = nil,
        transportType: TbQueryTransportType? = nil,
        sortProperty: TbQuerySortProperty = .name,
        sortOrder: TbQuerysortOrder = .ascending
    ) -> String {
        let queryParameters = assembleQueryParameters(pageSize: pageSize, page: page, type: type, deviceProfileId: deviceProfileId,
                                                      active: active, textSearch: textSearch, transportType: transportType,
                                                      sortProperty: sortProperty, sortOrder: sortOrder)
        return getEndpointURL(apiPath, replacePaths: replacePaths, appendQuery: queryParameters)
    }
}

