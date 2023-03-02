//
//  StorageManager.swift
//  Carpet stuff innit bruv
//
//  Created by Lakhan Lothiyi on 21/11/2022.
//
//  This is a general utility storage system shared between multiple projects.
//

import Foundation
import SwiftUI

class SettingsStorageManager: ObservableObject {
    
    static let shared = SettingsStorageManager("settingsStore")
    
    var name: String
    var fileLocation: URL
    
    internal let encoder = JSONEncoder()
    internal let decoder = JSONDecoder()
    
    var s: SettingsStorageObject {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                SettingsStorageManager.saveLoadedObjectToLocalStorage(self)
            }
        }
    }
        
    init(_ dbName: String) {
        self.name = dbName
        self.fileLocation = {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let storageObjectLocation = docs.appendingPathComponent(dbName).appendingPathExtension("object") // add object file
            print(storageObjectLocation)
            return storageObjectLocation
        }()
        
        // create file if it doesnt exist
        if !FileManager.default.fileExists(atPath: fileLocation.path) {
            let starterObj = SettingsStorageManager.blankTemplate
            let json = try? encoder.encode(starterObj)
            try? json?.write(to: fileLocation, options: .atomic)
            
            // else if it does exist, make sure it successfully gets loaded and decodes, else write a blank template.
        } else if let data = try? Data(contentsOf: fileLocation),
                  let _ = try? decoder.decode(SettingsStorageObject.self, from: data) {} else {
                      let starterObj = SettingsStorageManager.blankTemplate
                      let json = try? encoder.encode(starterObj)
                      try? json?.write(to: fileLocation, options: .atomic)
                  }
        
        self.s = SettingsStorageManager.getObjectFromLocalStorage(decoder, fileLocation, encoder: encoder)
        
        self.objectWillChange.send()
    }
    
    static private func reloadObjectFromLocalStorage(_ self: SettingsStorageManager) {
        self.objectWillChange.send()
        self.s = SettingsStorageManager.getObjectFromLocalStorage(self.decoder, self.fileLocation, encoder: self.encoder)
    }
    
    static private func saveLoadedObjectToLocalStorage(_ self: SettingsStorageManager) {
        print("saving object")
        do {
            let json = try self.encoder.encode(self.s)
            try json.write(to: self.fileLocation, options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static private func getObjectFromLocalStorage(_ decoder: JSONDecoder, _ fileLocation: URL, encoder: JSONEncoder) -> SettingsStorageObject {
        print("loading object")
        do {
            var file: Data
            if FileManager.default.fileExists(atPath: fileLocation.path) {
                file = try Data(contentsOf: fileLocation)
            } else {
                let json = try encoder.encode(SettingsStorageManager.blankTemplate)
                file = json
            }
            
            let object = try decoder.decode(SettingsStorageObject.self, from: file)
            
            return object
        } catch {
            fatalError(error.localizedDescription)
        }
    }    
    
    internal static let blankTemplate = SettingsStorageObject(
        appColorTheme: AccentColor,
        useAppColorMore: false,
        
        playerBlurAmount: 10,
        tintAlbumsByArtwork: true,
        
        playbackHistory: []
    )
}

struct SettingsStorageObject: Codable {
    var appColorTheme: Color
    var useAppColorMore: Bool
    
    var playerBlurAmount: Float
    var tintAlbumsByArtwork: Bool
    
    var playbackHistory: [UInt64]
}
