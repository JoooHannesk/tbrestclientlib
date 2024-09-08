//
//  Helpers.swift
//
//
//  Created by Johannes Kinzig on 28.08.24.
//

import Foundation
@testable import TBRESTClientLib

struct FileResourceLoader {
    
    let searchPath: String
    
    /**
     Return path to requested test resource, where the resource is a json file
     - Parameter fileName: file name for test resource
     - Returns: URL to test resource
     */
    func getPathToResource(fileName: String) -> URL {
        let fileName = fileName + ".json"
        let urlToThisFile = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent()
        return urlToThisFile.appendingPathComponent(searchPath).appendingPathComponent(fileName)
    }
    
    /**
     Load text from file
     - Parameter fileName: file name (as files in resource location) containing data
     - Returns: text as Data?
     - Note: Returns nil in case data was not able to be loaded from file
     */
    func loadTextFromFile(fileName: String) -> Data? {
        let fileUrl = getPathToResource(fileName: fileName)
        // print("File Path: \(fileUrl)")
        if let jsonData = try? Data(contentsOf: fileUrl) {
            // print("Mock data: \(String(decoding: jsonData, as: UTF8.self))")
            return jsonData
            }
        else {
            return nil
        }
    }
    
    /**
     Load server settings from file
     - Parameter fileName: file name (as files in resource location) containing data
     - Returns: ServerSettings object
     - Note: Returns nil in case data was not able to be loaded from file
     */
    func loadServerSettingsFromFile(fileName: String) -> ServerSettings? {
        let decoder = JSONDecoder()
        if let textData = loadTextFromFile(fileName: fileName) {
            let serversettings = try? decoder.decode(ServerSettings.self, from: textData)
            return serversettings
        }
        return nil
    }
}
