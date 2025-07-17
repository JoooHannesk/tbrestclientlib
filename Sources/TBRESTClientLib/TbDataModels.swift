//
//  TbDataModels.swift
//
//
//  Created by Johannes Kinzig on 01.08.24.
//

import Foundation


// MARK: - Protocols & Extensions

/// Represent all TB data models and make them string representable for debug purposes
public protocol TBDataModel: Codable & CustomStringConvertible & Hashable {
    var description: String { get }
}
extension TBDataModel {
    public var description: String { return getStringRepresentation(for: self) }
}

extension Array: TBDataModel where Element: Codable & Hashable { }
extension Dictionary: TBDataModel where Key: Codable, Value: Codable & Hashable { }

/// Support subscript access for conforming types
public protocol PaginationDataResponse {
    associatedtype T
    var data: Array<T>?  { get }
}
public extension PaginationDataResponse {
    /**
     Return number of items on this page
     - Returns: number of items on this page, Int
     */
    var itemsOnPage: Int {
        get {
            if let itemsInside = data?.count {
                return itemsInside
            }
            else {
                return 0
            }
        }
    }
    /**
     Make conforming types support item access using subscripts
     - Parameter idx: Item index
     - Returns: item T? at index, where T conforms to TBDataModel
     */
    subscript(idx: Int) -> T? {
        get {
            if itemsOnPage > 0 { return data?[idx] }
            else { return nil }
        }
    }
    
    /**
     Return all items fetched for this page as array
     - Returns: Array containing items of type T
     - Note: Returns all fetched items on the current page. If more items exist
     on previous or following pages, these devices must be fetched seperatly with an additional call.
     */
    func getItemsInsideArray() -> Array<T>? {
        return data
    }
}


// MARK: - Helper Functions
/**
 Get a string representation for data model dataModelObject (conforming to protocol 'TBDataModels')
 - Parameter for: type (or instance) conforming to 'TBDataModels' protocol
 - Returns: string representation of dataModelObject
 */
fileprivate func getStringRepresentation(for dataModelObject: any TBDataModel) -> String {
    var propertiesString: String = String(describing: type(of: dataModelObject)) + " – "
    let dataModelObjectMirror: Mirror = Mirror(reflecting: dataModelObject)
    for dataModelObjectProperty in dataModelObjectMirror.children {
        propertiesString += "\(String(describing: dataModelObjectProperty.label ?? "")): \(String(describing: dataModelObjectProperty.value)) "
    }
    return propertiesString
}


// MARK: - Application Data Models

/// hold info required to request login at server
struct ServerSettings: TBDataModel {
    let baseUrl: String
    var username: String
    var password: String
    
    func allPartsGiven() -> Bool {
        return !baseUrl.isEmpty && !username.isEmpty && !password.isEmpty
    }
    
    func urlGiven() -> Bool {
        return !baseUrl.isEmpty
    }
    
}

/// hold authentication tokens received by server upon successful login
public struct AuthLogin: TBDataModel {
    public let token: String
    public let refreshToken: String
    
    func allPartsGiven() -> Bool {
        return !token.isEmpty && !refreshToken.isEmpty
    }
    
}

public struct User: TBDataModel {
    public let id: ID
    public let createdTime: Int
    public let tenantId: ID
    public let customerId: ID
    public let email: String
    public let authority: String
    public let firstName: String
    public let lastName: String
    public let phone: String?
    public let name: String
    public let additionalInfo: AdditionalInfo?
    /// createdTime as Date type
    public var createdTimeDt: Date { Date(timeIntervalSince1970: TimeInterval(createdTime/1000)) }
    
}

/**
 Represent **Device** and **DeviceInfo** objects
 */
public struct Device: TBDataModel {
    public let id: ID
    public let createdTime: Int
    public let tenantId: ID
    public let customerId: ID
    public let name: String
    public let type: String
    public let label: String?
    public let deviceProfileId: ID
    
    // the following properties are defined for DeviceInfo objects only
    public let customerTitle: String?
    public let customerIsPublic: Bool?
    public let deviceProfileName: String?
    public let active: Bool?
    
    /// createdTime as Date type
    public var createdTimeDt: Date { Date(timeIntervalSince1970: TimeInterval(createdTime/1000)) }
    
    // TODO: Think about adding `public let additionalInfo: AdditionalInfo?`
}

public struct DeviceProfile: TBDataModel {
    public let id: ID
    public let createdTime: Int?
    public let tenantId: ID
    public let name: String
    public let description: String?
    public let image: String?
    public let type: String
    public let transportType: String
    public let provisionType: String?
    public let defaultRuleChainId: ID?
    public let defaultDashboardId: ID?
    public let defaultQueueName: String?
    public let provisionDeviceKey: String?
    public let firmwareId: ID?
    public let softwareId: ID?
    public let defaultEdgeRuleChainId: ID?
    
    /// createdTime as Date type
    public var createdTimeDt: Date? {
        if let createdTime = createdTime {
            return Date(timeIntervalSince1970: TimeInterval(createdTime/1000))
        }
        else {
            return nil
        }
    }
}

public struct ID: TBDataModel, Hashable {
    public let id: String
    public let entityType: String
}

public struct AdditionalInfo: TBDataModel {
    public let defaultDashboardFullscreen: Bool?
    public let defaultDashboardId: String?
    public let description: String?
    public let failedLoginAttempts: Int?
    public let homeDashboardHideToolbar: Bool?
    public let homeDashboardId: String?
    public let lang: String?
    public let lastLoginTs: Int?
    public let userCredentialsEnabled: Bool?
}

public struct PaginationDataContainer<T: TBDataModel>: TBDataModel, PaginationDataResponse {
    public let data: Array<T>?
    public let totalPages: Int
    public let totalElements: Int
    public let hasNext: Bool
// alternative way to define this struct:
// struct PaginationDataContainer<T>: TBDataModel, PaginationDataResponse where T: TBDataModel {
}

/// Represent a swift-native type for: ThingsBoard entity attribute
public struct AttributesResponse: TBDataModel {
    /// attribute key as string
    public let key: String
    /**
    ThingsBoard data points have **values** of **different types**. This library supports: Bool, Double, String (JSON is currenlty unsupported).
     
    Depending on the value's expected type, use the following members to get the value from the `value` property: `value.doubleVal`, `value.stringVal`, `value.boolVal`
    For further information, see  ``MplValueType``
    */
    public let value: MplValueType
    /// last updated timestamp in milliseconds unix time
    public let lastUpdateTs: Int
    /// last updated timestamp as Date type
    public var lastUpdateDt: Date { Date(timeIntervalSince1970: TimeInterval(lastUpdateTs/1000)) }
}

/// Represent a swift-native type for: ThingsBoard time-series data value
public struct TimeseriesResponse: TBDataModel {
    /**
    ThingsBoard data points have **values** of **different types**. This library supports: Bool, Double, String (JSON is currenlty unsupported).
     
    Depending on the value's expected type, use the following members to get the value from the `value` property: `value.doubleVal`, `value.stringVal`, `value.boolVal`
    For further information, see  ``MplValueType``
    */
    public let value: MplValueType
    /// Value's timestamp in milliseconds unix time
    public let ts: Int
    /// Value's timestamp as Date type
    public var tsDt: Date { Date(timeIntervalSince1970: TimeInterval(ts/1000)) }
}

/**
 ThingsBoard data (e.g. attributes or time-series data) retrieved from the server have values of different types, wrapped inside a JSON response.
 
 `MplValueType` is designed to automatically detect the value's type and cast it into swift-native datatypes. Currently **Bool**, **Double**, **String**
 is supported, a **JSON-String as a value is currenlty unsupported**.
 */
public enum MplValueType: TBDataModel {
    case bool(Bool)
    case double(Double)
    case string(String)
    
    public var boolVal: Bool? {
        if case .bool(let val) = self {
            return val
        }
        return nil
    }
    public var doubleVal: Double? {
        if case .double(let val) = self {
            return val
        }
        return nil
    }
    public var stringVal: String? {
        if case .string(let val) = self {
            return val
        }
        return nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
        } else if let x = try? container.decode(Double.self) {
            self = .double(x)
        } else if let x = try? container.decode(String.self) {
            self = .string(x)
        } else {
            throw DecodingError.typeMismatch(MplValueType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for value, failed to convert JSON response!"))
        }
    }
}

// MARK: - Application Error Data Models
public struct TBAppError: TBDataModel {
    public let status: Int
    public let message: String
    public let errorCode: Int
    public let timestamp: Int
    public var timestampDt: Date { Date(timeIntervalSince1970: TimeInterval(timestamp/1000)) }
}
