//
//  RecentlyAddedSubView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/02/2023.
//

import SwiftUI
import MediaPlayer

struct RecentlyAddedSubView: View {
    
    @ObservedObject var ml = MusicLibrary.shared
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var searchQuery: String = ""
    
    @State var albumsFiltered: [MPMediaItemCollection] = []
    
    var db: [MPMediaItemCollection] {
        searchQuery.isEmpty ?
        ml.albums.sorted { lhs, rhs in
            (lhs.representativeItem?.dateAdded ?? Date.init(timeIntervalSince1970: 0)) > (rhs.representativeItem?.dateAdded ?? Date.init(timeIntervalSince1970: 0))
        }
        :
        albumsFiltered
    }
        
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(db) { album in
                    AlbumButton(album: album)
                }
            }
            .padding(10)
        }
        .navigationTitle("Recently Added")
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Albums"))
        .onChange(of: searchQuery) { _ in
            search(searchQuery)
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
        }.sorted { lhs, rhs in
            (lhs.representativeItem?.dateAdded ?? Date.init(timeIntervalSince1970: 0)) > (rhs.representativeItem?.dateAdded ?? Date.init(timeIntervalSince1970: 0))
        }
    }
}

struct RecentlyAddedSubView_Previews: PreviewProvider {
    static var previews: some View {
        RecentlyAddedSubView()
    }
}
