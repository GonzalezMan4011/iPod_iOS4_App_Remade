//
//  ContentView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI

struct ContentView: View {
    @State var rotation: UIDeviceOrientation = .unknown
    @ObservedObject var player = Player.shared
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
        .popover(isPresented: !$player.playerIsMini) {
            PlayerOverlay()
                .background(Transparency())
        }
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
        }
    }
}








struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        egg()
    }
}
struct egg: View {
    @State var obj: AnyClass? = nil
    var body: some View {
        Text(obj == nil ? "n" : ":D")
            .task {
                try? await Task.sleep(for: .seconds(2))
                let gm: AnyClass? = NSClassFromString("AVAudioEngine")
                self.obj = gm
            }
    }
}
