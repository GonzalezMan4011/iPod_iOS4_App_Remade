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
                player.isMini.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(.bar)
        .cornerRadius(player.isMini ? 0 : 20, corners: [.topLeft, .topRight])
        .offset(y: player.isMini ? 0 : 60)
        .opacity(player.isMini ? 1 : 0)
        .animation(.easeInOut, value: player.isMini)
        .onChange(of: player.isMini) { newState in
            player.tabBar(newState)
        }
        .offset(y: offset.height / 10)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.height) > 100 {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            offset = .zero
                        }
                        player.isMini = false
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            offset = .zero
                        }
                    }
                }
        )
    }
}
