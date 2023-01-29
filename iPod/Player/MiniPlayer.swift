//
//  MiniPlayer.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import SwiftUI
import HidableTabView

struct MiniPlayer: View {
    
    @ObservedObject var player = Player.shared
    
    var body: some View {
        VStack {
            Button("gm") {
                player.isMini.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: player.isMini ? 60 : (screenheight - 80))
        .background(.bar)
        .cornerRadius(player.isMini ? 0 : 20, corners: [.topLeft, .topRight])
        .animation(.easeInOut, value: player.isMini)
        .onChange(of: player.isMini) { newState in
            if newState {
                UITabBar.showTabBar(animated: true)
            } else {
                UITabBar.hideTabBar(animated: true)
            }
        }
    }
}
