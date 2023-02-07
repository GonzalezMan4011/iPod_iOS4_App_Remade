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
    
    @ObservedObject var ml = MusicLibrary.shared
    @State var searchQuery: String = ""
    
    @State var songsFiltered: [MPMediaItem] = []
    
    var db: [MPMediaItem] {
        searchQuery.isEmpty ? ml.songs : songsFiltered
    }
    
    var body: some View {
        NavigationStack {
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
                                #warning("play song")
                                if let assetURL = song.assetURL {
                                    print(assetURL)
                                    Task {
                //                        guard let fileURL = await export(assetURL) else { return }
                //                        print(fileURL)
                //                        DispatchQueue.main.async {
                //                            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                //                            //present(activityViewController, animated: true, completion: nil)
                //                            guard let vc = view?.window?.rootViewController else { return }
                //                            vc.present(activityViewController, animated: true, completion: nil)
                //                        }
                                    }
                                }
                            } label: {
                                SongButton(song: song)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Songs")
            .listStyle(.plain)
            .modifier(VerticalIndex(indexableList: indexes))
            .scrollIndicators(.hidden)
            .searchable(text: $searchQuery, prompt: Text("Search Songs"))
            .onChange(of: searchQuery) { _ in
                search(searchQuery)
            }
        }
    }
    
    func search(_ q: String) {
        self.songsFiltered = ml.songs.filter { song in
            song.title?.lowercased().contains(q.lowercased()) ?? false
            ||
            song.artist?.lowercased().contains(q.lowercased()) ?? false
        }
    }
    
    struct SongButton: View {
        @State var view: UIView? = nil
        var song: MPMediaItem
        var body: some View {
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
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(ViewIntercept(view: $view))
        }
    }
}
