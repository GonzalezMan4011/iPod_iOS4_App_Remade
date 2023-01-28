//
//  SongsTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import SwiftUI

struct SongsTabView: View {
    
    @ObservedObject var ml = MusicLibrary.shared
    
    var body: some View {
        NavigationStack {
            let indexes = Array<String>(Set(
                ml.songs.compactMap({ item in
                    var char: String {
                        let character: String = "\((item.title ?? Placeholders.noItemTitle).prefix(1))".uppercased()
                        guard alphabet.contains(character) else { return "#" }
                        return character
                    }
                    return char
                })
            )).sorted()
            List {
                ForEach(indexes, id: \.self) { letter in
                    
                    Section(header: Text(letter).id(letter)) {
                        let songlist = ml.songs.filter { gm in
                            var char: String {
                                let character: String = "\((gm.title ?? Placeholders.noItemTitle).prefix(1))"
                                guard alphabet.contains(character.uppercased()) else { return "#" }
                                return character
                            }
                            return char == letter
                        }
                        ForEach(songlist) { song in
                                HStack {
                                    Image(uiImage: song.art ?? Placeholders.noArtwork)
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
                                }
                        }
                    }
                }
            }
            .navigationTitle("Songs")
            .listStyle(PlainListStyle())
            .modifier(VerticalIndex(indexableList: indexes))
            .scrollIndicators(.hidden)
        }
    }
}

let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "#"] //swiftlint:disable comma
