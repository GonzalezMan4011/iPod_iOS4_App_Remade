//
//  AlbumView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI
import MediaPlayer
import Introspect
import ViewExtractor

struct AlbumView: View {
    var album: MPMediaItemCollection
    @ObservedObject var player = Player.shared
    @ObservedObject var store = StorageManager.shared
    @Environment(\.colorScheme) var cs
    @State var palette: Palette = .init()

    var albumColor: Color {
        if store.s.tintAlbumsByArtwork {
            return Color(uiColor: (cs == .light ? palette.DarkMuted?.uiColor : palette.Vibrant?.uiColor) ?? store.s.appColorTheme.uiColor)
        } else {
            return store.s.appColorTheme
        }
    }
    
    func setTint() {
        let artwork = album.albumArt
        let colors = Vibrant.from(artwork).getPalette()
        self.palette = colors
    }
    
    init(album: MPMediaItemCollection) {
        self.album = album
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                cover
                albumInfo
                controls
                songsList
            }
        }
        .tint(albumColor)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(album.albumTitle ?? Placeholders.noItemTitle)
        .task(priority: .high) { setTint() }
        .animation(.easeInOut(duration: 0.2), value: albumColor)
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
        .padding([.horizontal, .bottom],30)
        .padding(.top, 10)
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
    }
    
    @ViewBuilder var controls: some View {
        HStack(alignment: .center) {
            Button {
                play()
            } label: {
                Label("Play", systemImage: "play.fill")
                    .frame(height: 35)
                    .frame(maxWidth: .infinity)
                    .font(.body.bold())
            }
            .buttonStyle(.bordered)
            Button {
                shuffle()
            } label: {
                Label("Shuffle", systemImage: "shuffle")
                    .frame(height: 35)
                    .frame(maxWidth: .infinity)
                    .font(.body.bold())
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    @ViewBuilder var songsList: some View {
        let sorted = album.items.sorted { lhs, rhs in
            lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
        }
        
        let spacing: CGFloat = 6
        VStack(spacing: 0) {
            Divider()
            AlbumDividedVStack(alignment: .trailing, spacing: 0) {
                ForEach(sorted) { song in
                    Button {
                        playSong(song)
                    } label: {
                        HStack {
                            Text(song.albumTrackNumber == 0 ? "" : "\(song.albumTrackNumber)")
                                .foregroundColor(.secondary)
                                .frame(width: 35)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(song.title ?? Placeholders.noItemTitle)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                Text(song.artist ?? Placeholders.noItemTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.vertical, spacing)
                    }
                    .tint(.primary)
                }
            }
            Divider()
        }
        .padding(.horizontal)
    }
    
    func playSong(_ song: MPMediaItem) {
        let songs = album.items.sorted { lhs, rhs in
            lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
        }
        
        guard let index = songs.firstIndex(of: song) else {
            UIApplication.shared.presentAlert(title: "Error", message: "The selected song could not be found.", actions: [UIAlertAction(title: "Ok", style: .cancel)])
            return
        }
        
        let queue = songs.map { $0.persistentID }
        player.beginPlayingFromQueue(queue, atPos: index)
    }
    
    func play() {
        let songs = album.items.sorted { lhs, rhs in
            lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
        }
        
        let queue = songs.map { $0.persistentID }
        player.beginPlayingFromQueue(queue)
    }
    
    func shuffle() {
        var songs = album.items.sorted { lhs, rhs in
            lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
        }
        
        songs.shuffle()
        
        let queue = songs.map { $0.persistentID }
        player.beginPlayingFromQueue(queue)
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
                        Text(album.albumTitle ?? Placeholders.noItemTitle)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Shuffle") {
                        shuffle(open: false)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                } else {
                    ProgressView()
                        .task {
                            shuffle(open: true)
                        }
                }
            }.navigationTitle("Albums")
        }
    }
    
    func shuffle(open: Bool) {
        if let albums = MPMediaQuery.albums().collections {
            let eggs = albums.filter { ($0.albumTitle ?? "").contains("Mario") }
            self.album = eggs.randomElement()
            guard self.album != nil else { return }
            self.open = open
        }
    }
}


fileprivate struct AlbumDividedVStack<Content: View>: View {
    @ViewBuilder let content: Content
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        Extract(content) { views in
            VStack(alignment: alignment, spacing: spacing) {
                let first = views.first?.id

                ForEach(views) { view in
                    if view.id != first {
                        Divider()
                            .padding(.leading, 35)
                    }

                    view
                }
            }
        }
    }
}
