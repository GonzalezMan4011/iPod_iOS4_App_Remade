//
//  AlbumView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI
import MediaPlayer

struct AlbumView: View {
    var album: MPMediaItemCollection
    @ObservedObject var player = Player.shared
    var body: some View {
        ScrollView {
            Image(uiImage: album.albumArt)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Button("Play All") {
                let newQueue = album.items.map({ $0.persistentID })
                player.beginPlayingFromQueue(newQueue)
            }
            .buttonStyle(.bordered)
        }
    }
}
