//
//  MiniPlayer.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import SwiftUI

struct MiniPlayer: View {
    
    @ObservedObject var player = Player.shared
    @State private var offset = CGSize.zero

    var body: some View {
        VStack {
            Button("gm") {
                player.playerIsMini.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(.bar)
        .cornerRadius(player.playerIsMini ? 0 : 20, corners: [.topLeft, .topRight])
        .offset(y: player.playerIsMini ? 0 : 60)
        .opacity(player.playerIsMini ? 1 : 0)
        .animation(.easeInOut, value: player.playerIsMini)
        .onChange(of: player.playerIsMini) { newState in
            player.tabBar(newState)
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    let value = offset.height.rounded()
                    if value < -100 {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            offset = .zero
                        }
                        player.playerIsMini = false
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            offset = .zero
                        }
                    }
                }
        )
    }
}
