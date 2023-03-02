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

class EQStorageManager: ObservableObject {
    
    static let shared = EQStorageManager("eqStore")
    
    var name: String
    var fileLocation: URL
    
    internal let encoder = JSONEncoder()
    internal let decoder = JSONDecoder()
    
    var s: EQStorageObject {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                EQStorageManager.saveLoadedObjectToLocalStorage(self)
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
            let starterObj = EQStorageManager.blankTemplate
            let json = try? encoder.encode(starterObj)
            try? json?.write(to: fileLocation, options: .atomic)
            
            // else if it does exist, make sure it successfully gets loaded and decodes, else write a blank template.
        } else if let data = try? Data(contentsOf: fileLocation),
                  let _ = try? decoder.decode(EQStorageObject.self, from: data) {} else {
                      let starterObj = EQStorageManager.blankTemplate
                      let json = try? encoder.encode(starterObj)
                      try? json?.write(to: fileLocation, options: .atomic)
                  }
        
        self.s = EQStorageManager.getObjectFromLocalStorage(decoder, fileLocation, encoder: encoder)
        
        self.objectWillChange.send()
    }
    
    static private func reloadObjectFromLocalStorage(_ self: EQStorageManager) {
        self.objectWillChange.send()
        self.s = EQStorageManager.getObjectFromLocalStorage(self.decoder, self.fileLocation, encoder: self.encoder)
    }
    
    static private func saveLoadedObjectToLocalStorage(_ self: EQStorageManager) {
        print("saving object")
        do {
            let json = try self.encoder.encode(self.s)
            try json.write(to: self.fileLocation, options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static private func getObjectFromLocalStorage(_ decoder: JSONDecoder, _ fileLocation: URL, encoder: JSONEncoder) -> EQStorageObject {
        print("loading object")
        do {
            var file: Data
            if FileManager.default.fileExists(atPath: fileLocation.path) {
                file = try Data(contentsOf: fileLocation)
            } else {
                let json = try encoder.encode(EQStorageManager.blankTemplate)
                file = json
            }
            
            let object = try decoder.decode(EQStorageObject.self, from: file)
            
            return object
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    
    internal static let blankTemplate = EQStorageObject(
        eqBands: [0,0,0,0,0,0,0,0,0,0],
        eqPresets: [
             EQPreset(name: "Default", bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,]),
             EQPreset(name: "Bass Boost", bands: [3, 2.5, 1.8, 0.3, 0, 0, 0, 0, 0, 0]),
             EQPreset(name: "AirPods Pro (1st generation)", bands: [18.400000000000002, 16.8, 11.7, 4.700000000000001, 1.6000000000000005, 1.8000000000000007, 2.5, 1.1000000000000005, 6.300000000000001, 12.5])
        ],
        eqMin: -6,
        eqMax: 12
    )
}

struct EQStorageObject: Codable {
    var eqBands: [Double]
    var eqPresets: [EQPreset]
    var eqMin: Double
    var eqMax: Double
}

struct EQPreset: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var bands: [Double]
}
