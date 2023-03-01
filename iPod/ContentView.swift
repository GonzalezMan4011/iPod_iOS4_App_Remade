//
//  ContentView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI
import UIKit
import LNPopupUI

struct ContentView: View {
    @State var rotation: UIDeviceOrientation = .unknown
    @ObservedObject var player = Player.shared
    var body: some View {
        TabView {
            LibraryTabView()
                .tabItem {
                    Label("Library", systemImage: "music.note.house.fill")
                }
            AlbumsTabView()
                .tabItem {
                    Label("Albums", systemImage: "square.stack.fill")
                }
            SongsTabView()
                .tabItem {
                    Label("Songs", systemImage: "music.note")
                }
            PlaylistsTabView()
                .tabItem {
                    Label("Playlists", systemImage: "music.note.list")
                }
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .onAppear { player.playerBarShown = false }
                .onDisappear { player.playerBarShown = true }
        }
        .popup(isBarPresented: $player.playerBarShown, isPopupOpen: $player.playerFullscreen, popupContent: {
            PlayerPopover()
                .background(
                    ArtCoverBackground()
                        .preferredColorScheme(.dark)
                )
        })
        .ignoresSafeArea()
        .overlay {
            Coverflow(rotation: $rotation)
                .ignoresSafeArea()
                .opacity(rotation == .landscapeLeft || rotation == .landscapeRight ? 1 : 0)
                .animation(.easeInOut, value: rotation)
        }
        .onAppear { self.rotation = UIDevice.current.orientation }
        .onRotate { gm in
            self.rotation = gm
            
            if rotation == .landscapeLeft || rotation == .landscapeRight {
                player.playerBarShown = false
                player.playerFullscreen = false
            }
        }
    }
}

struct ArtCoverBackground: View {
    @ObservedObject var store = StorageManager.shared
    @ObservedObject var play = Player.shared
    var body: some View {
        play.coverImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: CGFloat(store.s.playerBlurAmount))
            .overlay {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(0)
                    .allowsHitTesting(false)
                    .background(.ultraThinMaterial)
            }
            .ignoresSafeArea()
    }
}

struct previews: PreviewProvider {
    static var previews: some View {
        ArtCoverBackground()
    }
}
