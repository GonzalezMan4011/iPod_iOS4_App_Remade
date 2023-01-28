//
//  PlaylistsTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import SwiftUI
import MediaPlayer
struct PlaylistsTabView: View {
    
    @ObservedObject var ml = MusicLibrary.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(ml.playlists) { playlist in
                    Text(playlist.playlistTitle ?? "Unknown")
                }
            }
            .navigationTitle("Playlists")
        }
    }
}
