//
//  PlayerClass.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import Foundation
import SwiftUI

class Player: ObservableObject {
    static let shared = Player()
    
    @Published var isMini = true
    
    var timer: Timer = Timer()
    
    func tabBar(_ egg: Bool) {
        if egg {
            UITabBar.showTabBar(animated: true)
        } else {
//            timer.invalidate()
//            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                UITabBar.hideTabBar(animated: false)
//            })
        }
    }
}
