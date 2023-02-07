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

class StorageManager: ObservableObject {
    
    static let shared = StorageManager()
    
    var fileLocation: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storageObjectLocation = docs.appendingPathComponent("storage").appendingPathExtension("object") // add storage.object file
        print(storageObjectLocation)
        return storageObjectLocation
    }()
    
    internal let encoder = JSONEncoder()
    internal let decoder = JSONDecoder()
    
    var s: StorageObject {
        didSet {
            self.objectWillChange.send()
            StorageManager.saveLoadedObjectToLocalStorage(self)
        }
    }
        
    init() {
        
        // create file if it doesnt exist
        if !FileManager.default.fileExists(atPath: fileLocation.path) {
            let starterObj = StorageManager.blankTemplate
            let json = try? encoder.encode(starterObj)
            try? json?.write(to: fileLocation, options: .atomic)
            
            // else if it does exist, make sure it successfully gets loaded and decodes, else write a blank template.
        } else if let data = try? Data(contentsOf: fileLocation),
                  let _ = try? decoder.decode(StorageObject.self, from: data) {} else {
                      let starterObj = StorageManager.blankTemplate
                      let json = try? encoder.encode(starterObj)
                      try? json?.write(to: fileLocation, options: .atomic)
                  }
        
        self.s = StorageManager.getObjectFromLocalStorage(decoder, fileLocation, encoder: encoder)
        
        self.objectWillChange.send()
    }
    
    static private func reloadObjectFromLocalStorage(_ self: StorageManager) {
        self.objectWillChange.send()
        self.s = StorageManager.getObjectFromLocalStorage(self.decoder, self.fileLocation, encoder: self.encoder)
    }
    
    static private func saveLoadedObjectToLocalStorage(_ self: StorageManager) {
        print("saving object")
        do {
            let json = try self.encoder.encode(self.s)
            try json.write(to: self.fileLocation, options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static private func getObjectFromLocalStorage(_ decoder: JSONDecoder, _ fileLocation: URL, encoder: JSONEncoder) -> StorageObject {
        print("loading object")
        do {
            var file: Data
            if FileManager.default.fileExists(atPath: fileLocation.path) {
                file = try Data(contentsOf: fileLocation)
            } else {
                let json = try encoder.encode(StorageManager.blankTemplate)
                file = json
            }
            
            let object = try decoder.decode(StorageObject.self, from: file)
            
            return object
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    
    internal static let blankTemplate = StorageObject(
        eqBands: [0,0,0,0,0,0,0,0,0,0],
        eqPresets: [
            EQPreset(name: "Bass boost", bands: [3, 2.5, 1.8, 0.3, 0, 0, 0, 0, 0, 0])
        ],
        eqMin: -6,
        eqMax: 12,
        appColorTheme: Color(red: 0.925, green: 0.471, blue: 0.208)
    )
}

struct StorageObject: Codable {
    var eqBands: [Double]
    var eqPresets: [EQPreset]
    var eqMin: Double
    var eqMax: Double
    
    var appColorTheme: Color
}

struct EQPreset: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var bands: [Double]
}
