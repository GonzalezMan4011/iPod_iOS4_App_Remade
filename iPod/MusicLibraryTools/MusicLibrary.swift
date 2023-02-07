//
//  MusicLibrary.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import MediaPlayer


class MusicLibrary: ObservableObject {
    static let shared = MusicLibrary()
    
    let ml: MPMediaLibrary = MPMediaLibrary.default()
    
    @Published public var status: MPMediaLibraryAuthorizationStatus
    
    @Published public var albums: [MPMediaItemCollection] = []
    @Published public var songs: [MPMediaItem] = []
    @Published public var playlists: [MPMediaItemCollection] = []
    @Published public var artists: [MPMediaItem] = []

    init() {
        status = MPMediaLibrary.authorizationStatus()
        
        ml.beginGeneratingLibraryChangeNotifications()
        
        NotificationCenter.default.addObserver(forName: .MPMediaLibraryDidChange, object: nil, queue: nil, using: { _ in
            Task { self.updateLibrary() }
        })
        
        if status == .authorized { updateLibrary() }
        
        guard status != .authorized else { return }
        MPMediaLibrary.requestAuthorization { status in
            self.status = status
            self.updateLibrary()
        }
    }
    
    internal func updateLibrary() {
        DispatchQueue.main.async {
            if let albums = MPMediaQuery.albums().collections { self.albums = albums }
            if let playlists = MPMediaQuery.playlists().collections { self.playlists = playlists }
            if let songs = MPMediaQuery.songs().items { self.songs = songs }
            if let artists = MPMediaQuery.artists().items { self.artists = artists }
        }
    }
}

extension MPMediaItem: Identifiable, Comparable {
    public static func < (lhs: MPMediaItem, rhs: MPMediaItem) -> Bool {
        lhs.title ?? "" < rhs.title ?? ""
    }
    
    public var id: String { self.persistentID.description }
    public var art: UIImage? {
        let item = self
        guard let artwork = item.artwork else { return nil }
        return artwork.image(at: artwork.bounds.size)
    }
    
}

extension MPMediaItemCollection: Identifiable {
    public var id: String { self.persistentID.description }
    public var playlistTitle: String? { self.value(forProperty: MPMediaPlaylistPropertyName) as? String}
    public var albumTitle: String? { self.representativeItem?.albumTitle}
    public var albumArt: UIImage? {
        guard let item = self.representativeItem else { return nil }
        guard let artwork = item.artwork else { return nil }
        return artwork.image(at: artwork.bounds.size)
    }
}
