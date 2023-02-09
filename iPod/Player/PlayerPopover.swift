//
//  PlayerPopover.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 08/02/2023.
//

import SwiftUI

struct PlayerPopover: View {
    @ObservedObject var player = Player.shared
    @Environment(\.colorScheme) var cs
    var body: some View {
        VStack {
            Button("gn") {
                player.playerFullscreen = false
            }
        }
        .popupImage(player.coverImage, resizable: true)
        .popupTitle(player.trackTitle)
        .popupBarItems(trailing: {
            Button {
                guard player.currentlyPlaying != nil else { return }
                player.togglePlayback()
            } label: {
                Image(systemName: player.isPaused ? "play.fill" : "pause.fill")
                    .font(.body.bold())
                    .padding(.horizontal, 4)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(cs == .light ? .black : .white)
            .opacity(player.currentlyPlaying == nil ? 0.4 : 1)
            .animation(.easeInOut, value: player.currentlyPlaying)
            
            Button {
                Task {
                    guard player.currentlyPlaying != nil else { return }
                    try? await player.nextSong()
                }
            } label: {
                Image(systemName: "forward.fill")
                    .font(.body.bold())
                    .padding(.leading, 2)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(cs == .light ? .black : .white)
            .opacity(player.currentlyPlaying == nil ? 0.4 : 1)
            .animation(.easeInOut, value: player.currentlyPlaying)
        })
        .popupBarCustomizer({ popupBar in
            if popupBar.imageView.image == Placeholders.noArtwork {
                popupBar.imageView.alpha = 0.5
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlayerPopover_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPopover()
    }
}
