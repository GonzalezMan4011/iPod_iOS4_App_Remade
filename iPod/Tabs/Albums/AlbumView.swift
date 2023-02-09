//
//  AlbumView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI
import MediaPlayer

struct AlbumView: View {
    var album: MPMediaItemCollection
    var body: some View {
        ScrollView {
            Image(uiImage: album.albumArt)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
