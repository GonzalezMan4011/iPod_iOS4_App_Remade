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
                .padding()
            }
            .navigationTitle("Albums")
            .searchable(text: $searchQuery, prompt: Text("Search Albums"))
            .onChange(of: searchQuery) { _ in
                search(searchQuery)
            }
        }
    }
    
    struct AlbumButton: View {
        var album: MPMediaItemCollection
        var body: some View {
            NavigationLink {
                
            } label: {
                VStack(alignment: .leading) {
                    Image(uiImage: album.albumArt ?? Placeholders.noArtwork)
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


