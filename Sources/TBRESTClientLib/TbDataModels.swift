//
//  tb-data-models.swift
//  TBClientAPI
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
    var description: String { return getStringRepresentation(for: self) }
}

protocol TBResponseDataModel: TBDataModel  { }
protocol TBErrorDataModel: TBDataModel { }

protocol PageDataResponseType<T> {
    associatedtype T
    var data: Array<T>?  { get }
}

extension PageDataResponseType {
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

struct AuthLogin: TBResponseDataModel {
    let token: String
    let refreshToken: String
}

struct User: TBResponseDataModel {
    // TODO: implement equality check
    let id: ID
    let createdTime: Int
    let tenantId: ID
    let customerId: ID
    let email: String
    let authority: String
    let firstName: String
    let lastName: String
    let phone: String?
    let name: String
    let additionalInfo: AdditionalInfo?
}

struct Device: TBResponseDataModel {
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

struct DeviceProfile: TBResponseDataModel {
    // TODO: implement equality check because there exists more than one API call to receive object
}

struct ID: TBResponseDataModel {
    // TODO: implement equality check
    let id: String
    let entityType: String
}

struct AdditionalInfo: TBResponseDataModel {
    let defaultDashboardFullscreen: Bool?
    let defaultDashboardId: String?
    let description: String?
    let failedLoginAttempts: Int?
    let homeDashboardHideToolbar: Bool?
    let homeDashboardId: String?
    let lang: String?
    let lastLoginTs: Int?
    let userCredentialsEnabled: Bool?
}

struct PageDataContainer<T>: TBResponseDataModel, PageDataResponseType where T: TBResponseDataModel {
    let data: Array<T>?
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
}

// MARK: - Application Error Data Models
struct TBAppError: TBErrorDataModel {
    let status: Int
    let message: String
    let errorCode: Int
    let timestamp: Int
}
