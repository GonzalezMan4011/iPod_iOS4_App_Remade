//
//  PlayerPopover.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 08/02/2023.
//

import SwiftUI
import LNPopupUI

struct PlayerPopover: View {
    @ObservedObject var player = Player.shared
    @ObservedObject var store = StorageManager.shared
    @Environment(\.colorScheme) var cs
    var body: some View {
        VStack {
            fullpageView
        }
        .popupBarStyle(.custom)
        .popupBarCustomizer({ popupBar in
            popupBar.progressViewStyle = store.s.miniplayerProgress ? .bottom : .none
        })
        .popupImage(player.coverImage, resizable: true)
        .popupTitle(player.trackTitle)
        .popupProgress(1)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    @ViewBuilder var fullpageView: some View {
        HStack {
            VStack {
                ForEach(0..<store.s.playbackHistory.count, id: \.self) { index in
                    if index <= store.s.playbackHistory.count - 1 {
                        let id = store.s.playbackHistory[index]
                        let item = Player.getSongItem(persistentID: id)
                        Text("\(item?.title ?? "Unknown")")
                    }
                }
            }
            .background(.red)
            VStack {
                ForEach(0..<player.playerQueue.count, id: \.self) { index in
                    if index <= player.playerQueue.count - 1 {
                        let id = player.playerQueue[index]
                        let item = Player.getSongItem(persistentID: id)
                        Text("\(item?.title ?? "Unknown")")
                    }
                }
            }
            .background(.blue)
        }
        .font(.footnote)
    }
}

struct PlayerPopover_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPopover()
    }
}
