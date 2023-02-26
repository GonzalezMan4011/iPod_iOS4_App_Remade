//
//  AlbumView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI
import MediaPlayer
import Introspect

struct AlbumView: View {
    var album: MPMediaItemCollection
    @ObservedObject var player = Player.shared
    @Environment(\.colorScheme) var cs
    @State var palette: Palette = .init()
    var albumColor: Color {
        Color(uiColor: (cs == .light ? palette.DarkMuted?.uiColor : palette.Vibrant?.uiColor) ?? StorageManager.shared.s.appColorTheme.uiColor)
    }
    @State var showTitle = false
    
    func setTint() {
        let artwork = album.albumArt
        let colors = Vibrant.from(artwork).getPalette()
        self.palette = colors
    }
    
    var body: some View {
        ScrollView {
            cover
            albumInfo
            controls
            
            List {
                Text("1")
                Text("2")
                Text("3")
                Text("4")
            }
        }
        .tint(albumColor)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(showTitle ? album.albumTitle ?? Placeholders.noItemTitle : "")
        .task(priority: .high) { setTint() }
        .animation(.easeInOut(duration: 0.2), value: albumColor)
        .animation(.easeInOut(duration: 0.2), value: showTitle)
    }
    
    @ViewBuilder var cover: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
        VStack {
            Spacer(minLength: 0)
            Image(uiImage: album.albumArt)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 400)
            Spacer(minLength: 0)
        }
        .aspectRatio(1.0, contentMode: .fill)
        .clipShape(shape)
        .background {
            shape
                .strokeBorder(.gray.opacity(0.2), lineWidth: 0.5, antialiased: true)
        }
        .padding(30)
        .background {
            Image(uiImage: album.albumArt)
                .resizable()
                .scaledToFit()
                .blur(radius: 200)
        }
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder var albumInfo: some View {
        VStack(spacing: 2) {
            Text(album.albumTitle ?? Placeholders.noItemTitle)
                .font(.title3.bold())
            NavigationLink {
                #warning("add artist destination")
            } label: {
                Text(album.representativeItem?.albumArtist ?? Placeholders.noItemTitle)
                    .font(.title3)
                    .foregroundColor(albumColor)
            }
            .buttonStyle(.plain)
            
            if let date = album.representativeItem?.value(forProperty: MPMediaItemPropertyReleaseDate) as? Date {
                let genre = album.representativeItem?.genre ?? ""
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year], from: date)
                let year = components.year == nil ? "" : String(components.year!)
                let separator = genre.isEmpty || year.isEmpty ? "" : " • "
                Text("\(genre + separator + year)".capitalized)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else if let genre = album.representativeItem?.genre {
                Text(genre)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .onAppear { self.showTitle = false }.onDisappear { self.showTitle = true }
    }
    
    @ViewBuilder var controls: some View {
        HStack(alignment: .center) {
            Button {
                play()
            } label: {
                Label("Play", systemImage: "play.fill")
                    .frame(height: 35)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            Button {
                shuffle()
            } label: {
                Label("Shuffle", systemImage: "shuffle")
                    .frame(height: 35)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    @ViewBuilder var songsList: some View {
        let sorted = album.items.sorted { lhs, rhs in
            lhs.albumTrackNumber < rhs.albumTrackNumber
        }
        ForEach(sorted) { song in
            HStack {
                Button {
                    
                } label: {
                    Label {
                        Text(song.title ?? Placeholders.noItemTitle)
                    } icon: {
                        Text("\(song.albumTrackNumber)")
                    }
                }
            }
        }
    }
    
    func play() {
        
    }
    
    func shuffle() {
        
    }
}


struct AlbumViewPreview: PreviewProvider {
    static var previews: some View {
        AlbumViewPreviewView()
    }
}

struct AlbumViewPreviewView: View {
    @State var album: MPMediaItemCollection? = nil
    @State var open = false
    var body: some View {
        NavigationView {
            ScrollView {
                if let album = album {
                    NavigationLink(destination: AlbumView(album: album), isActive: $open) {
                        Text("gm")
                    }
                } else {
                    ProgressView()
                        .task {
                            let gm = true
                            if gm {
                                if let albums = MPMediaQuery.albums().collections {
                                    let eggs = albums.filter { ($0.albumTitle ?? "gm").contains("Burning") }
                                    self.album = eggs.randomElement()
                                    guard self.album != nil else { return }
                                    self.open = true
                                }
                            } else {
                                if let albums = MPMediaQuery.albums().collections {
                                    self.album = albums.randomElement()
                                    guard self.album != nil else { return }
                                    self.open = true
                                }
                            }
                        }
                }
            }.navigationTitle("Albums")
        }
    }
}
