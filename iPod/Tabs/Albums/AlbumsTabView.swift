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
            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Albums"))
            .onChange(of: searchQuery) { _ in
                search(searchQuery)
            }
        }
        .introspectSplitViewController { vc in
            vc.maximumPrimaryColumnWidth = 400
            #if targetEnvironment(macCatalyst)
            vc.preferredPrimaryColumnWidth = 400
            #endif
        }
    }
    
    struct AlbumButton: View {
        @ObservedObject var player = Player.shared
        var album: MPMediaItemCollection
        var body: some View {
            link
                .addContextMenu(album: album)
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
                    Text(album.representativeItem?.albumArtist ?? Placeholders.noItemTitle)
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


