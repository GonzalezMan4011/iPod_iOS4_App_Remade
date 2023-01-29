//
//  PlayerOverlay.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import SwiftUI

struct PlayerOverlay: View {
    @ObservedObject var player = Player.shared
    
    @State var offset = CGSize.zero
    var body: some View {
        VStack {
            Button("gn") {
                player.isMini.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: screenheight - 75)
        .background(.regularMaterial)
        .offset(y: player.isMini ? screenheight : 0)
        .opacity(player.isMini ? 0 : 1)
        .animation(.easeInOut, value: player.isMini)
        .cornerRadius(50, corners: [.topLeft, .topRight])
        .offset(y: offset.height / 2)
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
                        player.isMini = true
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            offset = .zero
                        }
                    }
                }
        )
    }
    
    var screenheight: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else { fatalError("no window found") }
        return window.screen.bounds.height
    }
}

struct PlayerOverlay_Previews: PreviewProvider {
    static var previews: some View {
        PlayerOverlay()
    }
}
