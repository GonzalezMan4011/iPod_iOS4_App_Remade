//
//  AlbumsTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import SwiftUI
import MediaPlayer

struct AlbumsTabView: View {
    
    @ObservedObject var ml = MusicLibrary.shared
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var searchQuery: String = ""
    
    @State var albumsFiltered: [MPMediaItemCollection] = []
    
    var db: [MPMediaItemCollection] {
        searchQuery.isEmpty ? ml.albums : albumsFiltered
    }
        
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(db) { album in
                        AlbumButton(album: album)
                    }
                }
                .padding(10)
            }
            .navigationTitle("Albums")
            .searchable(text: $searchQuery, prompt: Text("Search Albums"))
            .onChange(of: searchQuery) { _ in
                search(searchQuery)
            }
        }
    }
    
    struct AlbumButton: View {
        @ObservedObject var player = Player.shared
        var album: MPMediaItemCollection
        var body: some View {
            if #available(iOS 16.0, *) {
                link
                    .contextMenu {
                        btns
                    } preview: {
                        preview
                    }

            } else {
                link
                    .contextMenu {
                        btns
                    }
            }
        }
        
        @ViewBuilder var btns: some View {
            Button {
                let songs = album.items.sorted { lhs, rhs in
                    lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                }
                
                let queue = songs.map { $0.persistentID }
                player.beginPlayingFromQueue(queue)
            } label: {
                Label("Play", systemImage: "play")
            }
            
            Divider()
            
            Button {
                let songs = album.items.sorted { lhs, rhs in
                    lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                }
                
                let queue = songs.map { $0.persistentID }
                
                player.playerQueue.insert(contentsOf: queue, at: 0)
            } label: {
                Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
            Button {
                let songs = album.items.sorted { lhs, rhs in
                    lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                }
                
                let queue = songs.map { $0.persistentID }
                
                player.playerQueue.append(contentsOf: queue)
            } label: {
                Label("Play Last", systemImage: "text.line.last.and.arrowtriangle.forward")
            }
        }
        
        @ViewBuilder var preview: some View {
            VStack(alignment: .leading) {
                Image(uiImage: album.albumArt)
                    .resizable()
                    .scaledToFit()
                
                Text(album.albumTitle ?? Placeholders.noItemTitle)
                Text(album.representativeItem?.albumArtist ?? Placeholders.noItemTitle)
                    .foregroundColor(.secondary)
            }
        }
        
        @ViewBuilder var link: some View {
            NavigationLink {
                AlbumView(album: album)
            } label: {
                VStack(alignment: .leading) {
                    Image(uiImage: album.albumArt)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(5)
                    Text(album.representativeItem?.albumTitle ?? Placeholders.noItemTitle)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(album.representativeItem?.artist ?? Placeholders.noItemTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(8)
            }
            .buttonStyle(.plain)
        }
    }
    
    func search(_ q: String) {
        self.albumsFiltered = ml.albums.filter { album in
            album.albumTitle?.lowercased().contains(q.lowercased()) ?? false
            ||
            album.representativeItem?.artist?.lowercased().contains(q.lowercased()) ?? false
        }
    }
}


