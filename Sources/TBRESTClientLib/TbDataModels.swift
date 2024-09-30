//
//  tb-data-models.swift
//
//
//  Created by Johannes Kinzig on 01.08.24.
//

import Foundation


// MARK: - Protocols & Extensions

/// Represent all TB data models and make them printable for debug purposes
public protocol TBDataModel: Codable, CustomStringConvertible {
    var description: String { get }
}
extension TBDataModel {
    public var description: String { return getStringRepresentation(for: self) }
}

extension Array: TBDataModel where Element: Codable { }

/// Support subscript access for conforming types
protocol PaginationDataResponse {
    associatedtype T
    var data: Array<T>?  { get }
}
extension PaginationDataResponse {
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

/// Support equality check for conforming types
protocol EntityEquatable: Equatable {
    var id: ID { get }
    var name: String { get }
}
extension EntityEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}


// MARK: - Helper Functions
/**
 Get a string representation for data model dataModelObject (conforming to protocol 'TBDataModels')
 - Parameter for: type (or instance) conforming to 'TBDataModels' protocol
 - Returns: string representation of dataModelObject
 */
fileprivate func getStringRepresentation(for dataModelObject: TBDataModel) -> String {
    var propertiesString: String = String(describing: type(of: dataModelObject)) + " – "
    let dataModelObjectMirror: Mirror = Mirror(reflecting: dataModelObject)
    for dataModelObjectProperty in dataModelObjectMirror.children {
        propertiesString += "\(String(describing: dataModelObjectProperty.label ?? "")): \(String(describing: dataModelObjectProperty.value)) "
    }
    return propertiesString
}


// MARK: - Application Data Models
struct ServerSettings: TBDataModel {
    let baseUrl: String
    let username: String
    let password: String
}

public struct AuthLogin: TBDataModel {
    public let token: String
    public let refreshToken: String
}

public struct User: TBDataModel, EntityEquatable {
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
}

/** represent
 - Device objects
 - DeviceInfo objects
 */
public struct Device: TBDataModel, EntityEquatable {
    let id: ID
    let createdTime: Int
    let tenantId: ID
    let customerId: ID
    let name: String
    let type: String
    let label: String?
    let deviceProfileId: ID
    
    // the following properties are defined for DeviceInfo objects only
    let customerTitle: String?
    let customerIsPublic: Bool?
    let deviceProfileName: String?
    let active: Bool?
}

public struct DeviceProfile: TBDataModel, EntityEquatable {
    let id: ID
    let createdTime: Int?
    let tenantId: ID
    let name: String
    let description: String?
    let image: String?
    let type: String
    let transportType: String
    let provisionType: String?
    let defaultRuleChainId: ID?
    let defaultDashboardId: ID?
    let defaultQueueName: String?
    let provisionDeviceKey: String?
    let firmwareId: ID?
    let softwareId: ID?
    let defaultEdgeRuleChainId: ID?
}

public struct ID: TBDataModel, Equatable {
    public let id: String
    public let entityType: String
    
    // Support equality check
    public static func == (lhs: ID, rhs: ID) -> Bool {
        return lhs.id == rhs.id && lhs.entityType == rhs.entityType
    }
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
    let data: Array<T>?
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
// alternative way to define this struct:
// struct PaginationDataContainer<T>: TBDataModel, PaginationDataResponse where T: TBDataModel {
}

// MARK: - Application Error Data Models
struct TBAppError: TBDataModel {
    let status: Int
    let message: String
    let errorCode: Int
    let timestamp: Int
}
