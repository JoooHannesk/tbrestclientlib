//
//  tb-data-models.swift
//
//
//  Created by Johannes Kinzig on 01.08.24.
//

import Foundation


// MARK: - Protocols & Extensions
// representing all TB data models
protocol TBDataModel: Codable, CustomStringConvertible {
    var description: String { get }
}

extension TBDataModel {
    public var description: String { return getStringRepresentation(for: self) }
}

protocol PaginationDataResponseType<T> {
    associatedtype T
    var data: Array<T>?  { get }
}

extension PaginationDataResponseType {
    subscript(idx: Int) -> T? {
        return data?[idx]
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

public struct User: TBDataModel, Equatable {
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
    
    // Support equality check
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

struct Device: TBDataModel {
    /** represent
     - Device objects
     - DeviceInfo objects
     */
    // TODO: implement equality check because there exists more than one API call to receive devices
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

struct DeviceProfile: TBDataModel {
    // TODO: implement equality check because there exists more than one API call to receive object
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

struct PaginationDataContainer<T>: TBDataModel, PaginationDataResponseType where T: TBDataModel {
    let data: Array<T>?
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
}

// MARK: - Application Error Data Models
struct TBAppError: TBDataModel {
    let status: Int
    let message: String
    let errorCode: Int
    let timestamp: Int
}
