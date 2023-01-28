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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(ml.albums) { album in
                        AlbumButton(album: album)
                    }
                }
            }
            .navigationTitle("Albums")
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
}


