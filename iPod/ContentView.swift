//
//  ContentView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI

struct ContentView: View {
    @State var rotation: UIDeviceOrientation = UIDevice.current.orientation
    var body: some View {
        TabView {
            AlbumsTabView()
                .tabItem {
                    Label("Albums", systemImage: "square.stack.fill")
                }
                .safeAreaInset(edge: .bottom, content: {
                    MiniPlayer()
                })
            SongsTabView()
                .tabItem {
                    Label("Songs", systemImage: "music.note")
                }
                .safeAreaInset(edge: .bottom, content: {
                    MiniPlayer()
                })
            PlaylistsTabView()
                .tabItem {
                    Label("Playlists", systemImage: "music.note.list")
                }
                .safeAreaInset(edge: .bottom, content: {
                    MiniPlayer()
                })
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .overlay {
            Coverflow()
                .ignoresSafeArea()
                .opacity(rotation == .landscapeLeft || rotation == .landscapeRight ? 1 : 0)
                .animation(.easeInOut, value: rotation)
        }
        .onRotate { gm in
            self.rotation = gm
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
