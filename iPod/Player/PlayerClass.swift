//
//  PlayerClass.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import Foundation

class Player: ObservableObject {
    static let shared = Player()
    
    @Published var isMini = true
}
