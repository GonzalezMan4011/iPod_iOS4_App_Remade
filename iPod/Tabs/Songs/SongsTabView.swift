//
//  SongsTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import SwiftUI
import MediaPlayer

struct SongsTabView: View {
    @ObservedObject var player = Player.shared
    @ObservedObject var ml = MusicLibrary.shared
    @State var searchQuery: String = ""
    
    @State var songsFiltered: [MPMediaItem] = []
    
    var db: [MPMediaItem] {
        searchQuery.isEmpty ? ml.songs : songsFiltered
    }
    
    var body: some View {
        NavigationView {
            let indexes = Array<String>(Set(
                db.compactMap({ item in
                    var char: String {
                        let character: String = "\((item.title ?? "#").prefix(1))".uppercased()
                        guard alphabet.contains(character) else { return "#" }
                        return character
                    }
                    return char
                })
            )).sorted()
            List {
                ForEach(indexes, id: \.self) { letter in
                    Section(header: Text(letter).id(letter)) {
                        let songlist = db.filter { gm in
                            var char: String {
                                let character: String = "\((gm.title ?? "#").prefix(1))"
                                guard alphabet.contains(character.uppercased()) else { return "#" }
                                return character
                            }
                            return char == letter
                        }
                        ForEach(songlist) { song in
                            Button {
                                Task { try? await player.playSongItem(persistentID: song.persistentID) }
                            } label: {
                                SongButton(song: song)
                                    .drawingGroup()
                            }
                            .addContextMenu(song: song)
                        }
                    }
                }
            }
            .navigationTitle("Songs")
            .listStyle(.plain)
            #if !targetEnvironment(macCatalyst)
            .modifier(VerticalIndex(indexableList: indexes))
            #endif
            .searchable(text: $searchQuery, prompt: Text("Search Songs"))
            .onChange(of: searchQuery) { _ in
                search(searchQuery)
            }
            
            if useAltLayout { // idk if this is necessary but better safe than sorry
                PlayerPopover()
                    .background(
                        ArtCoverBackground()
                    )
            }
        }
        .introspectSplitViewController { vc in
            vc.maximumPrimaryColumnWidth = 400
            #if targetEnvironment(macCatalyst)
            vc.preferredPrimaryColumnWidth = 400
            #endif
        }
    }
    
    func search(_ q: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            let filtered = ml.songs.filter { song in
                song.title?.lowercased().contains(q.lowercased()) ?? false
                ||
                song.artist?.lowercased().contains(q.lowercased()) ?? false
            }
            
            DispatchQueue.main.async {
                self.songsFiltered = filtered
            }
        }
    }
    
    struct SongButton: View {
        var song: MPMediaItem
        var body: some View {
            HStack {
                Image(uiImage: song.art)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.large)
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)
                
                VStack(alignment: .leading) {
                    Text(song.title ?? Placeholders.noItemTitle)
                    Text(song.artist ?? Placeholders.noItemTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
