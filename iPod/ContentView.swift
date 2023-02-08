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
                .background(RemoveBG())
        })
        .ignoresSafeArea()
        .overlay {
            Coverflow()
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


struct RemoveBG: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.superview?.superview?.superview?.superview?.backgroundColor = .clear
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
