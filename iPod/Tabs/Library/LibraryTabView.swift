//
//  LibraryTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 26/02/2023.
//

import SwiftUI
import Combine
import MediaPlayer

struct LibraryTabView: View {
    @ObservedObject var lib = LibraryData.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                recentlyAddedSection
            }
            .navigationTitle("Library")
            .background {
                AlbumCoverFlowBG()
                    .blur(radius: useAltLayout ? 150 : 50)
                    .background(.ultraThinMaterial)
                    .overlay(.black.opacity(0.4))
                    .ignoresSafeArea()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder var recentlyAddedSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(lib.recentlyAddedAlbums.prefix(10)) { album in
                        RecentlyAddedAlbumButton(album: album)
                    }
                }
                .padding(10)
            }
        } header: {
            HStack {
                Text("RECENTLY ADDED")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Spacer()
                NavigationLink {
                    RecentlyAddedSubView()
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
        }
    }
    
    struct RecentlyAddedAlbumButton: View {
        var album: MPMediaItemCollection
        @ObservedObject var store = SettingsStorageManager.shared
        
        init(album: MPMediaItemCollection) {
            self.album = album
        }
        
        var body: some View {
            NavigationLink {
                AlbumView(album: album)
            } label: {
                Image(uiImage: album.albumArt)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .background {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(.gray.opacity(0.2), lineWidth: 0.5, antialiased: true)
                    }
            }
            .shadow(radius: 5)
            .addContextMenu(album: album)
        }
    }
}

class LibraryData: ObservableObject {
    static let shared = LibraryData()
    var cancellable = Set<AnyCancellable>()
    
    @Published var recentlyAddedAlbums: [MPMediaItemCollection] = []
    
    init() {
        self.setReceivers()
    }
    
    func setReceivers() {
        let lib = MusicLibrary.shared
        
        lib.$albums
            .sink(receiveValue: { albums in
                let sorted = albums.sorted { lhs, rhs in
                    (lhs.representativeItem?.dateAdded ?? Date.init(timeIntervalSince1970: 0)) > (rhs.representativeItem?.dateAdded ?? Date.init(timeIntervalSince1970: 0))
                }
                self.recentlyAddedAlbums = sorted
            })
            .store(in: &cancellable)
    }
}

struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView()
    }
}
