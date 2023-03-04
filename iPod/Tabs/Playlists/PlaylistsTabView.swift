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
        NavigationView {
            ScrollView {
                ForEach(ml.playlists) { playlist in
                    Text(playlist.playlistTitle ?? "Unknown")
                }
            }
            .navigationTitle("Playlists")
        }
        .introspectSplitViewController { vc in
            vc.maximumPrimaryColumnWidth = 400
            #if targetEnvironment(macCatalyst)
            vc.preferredPrimaryColumnWidth = 400
            #endif
        }
    }
}
