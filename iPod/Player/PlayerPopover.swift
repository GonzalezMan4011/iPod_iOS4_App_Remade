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
                Image(systemName: player.isPaused ? "pause.fill" : "play.fill")
                    .font(.body.bold())
                    .padding(.horizontal, 4)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(cs == .light ? .black : .white)
            .opacity(player.currentlyPlaying == nil ? 0.4 : 1)

            Button {
                guard player.currentlyPlaying != nil else { return }
                player.nextSong()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.body.bold())
                    .padding(.leading, 2)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(cs == .light ? .black : .white)
            .opacity(player.currentlyPlaying == nil ? 0.4 : 1)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlayerPopover_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPopover()
    }
}
