//
//  PlayerClass.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import Foundation
import SwiftUI
import MediaPlayer
import AVFoundation

class Player: ObservableObject {
    static let shared = Player()
    
    @Published var playerBarShown = true
    @Published var playerFullscreen = false
    
    @Published var coverImage: Image = Image("MissingArtwork")
    @Published var trackTitle: String = "Not Playing"
    
    @Published var isPaused: Bool = false
    
    func resume() {
        isPaused = false
    }
    
    func pause() {
        isPaused = true
    }
    
    func togglePlayback() {
        isPaused.toggle()
    }
    
    func nextSong() {
        
    }
    
    func previousSong() {
        
    }
    
    func tabBar(_ egg: Bool) {
        if egg {
            UITabBar.showTabBar(animated: true)
        } else {
            UITabBar.hideTabBar(animated: false)
        }
    }
    
    @Published var playerQueue: [UInt64] = []
    
    internal static func getSongAssetUrlByID(persistentID: UInt64) -> URL? {
        let item = Player.getSongItem(persistentID: persistentID)
        return item?.assetURL
    }
    
    static func getSongItem(persistentID: UInt64) -> MPMediaItem? {
        guard let query = MPMediaQuery.songs().items else { return nil }
        let item = query.first(where: { item in
            item.persistentID == persistentID
        })
        
        return item
    }
    
    public func playSongItem(persistentID: UInt64) async throws {
        guard let song = Player.getSongItem(persistentID: persistentID) else { throw "No song found" }
        self.currentlyPlaying = song
        guard let fileUrl = await Player.getSongFileUrl(persistentID: persistentID)
        else { throw "Asset export failed" }
        do {
            setPlayerData(song)
            try prepareToPlay(url: fileUrl)
        } catch {
            setPlayerData(nil)
            throw error
        }
    }
    
    internal func setPlayerData(_ item: MPMediaItem?) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
            if let song = item {
                self.trackTitle = song.title ?? "Unknown"
                self.coverImage = Image(uiImage: song.art)
            } else {
                self.trackTitle = "Not Playing"
                self.coverImage = Image(uiImage: Placeholders.noArtwork)
            }
        }
    }
    
    internal static func getSongFileUrl(persistentID: UInt64) async -> URL? {
        guard let assetUrl = Player.getSongItem(persistentID: persistentID)?.assetURL else { return nil }
        let asset = AVURLAsset(url: assetUrl)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return nil }
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")
        exporter.outputURL = fileURL
        exporter.outputFileType = .m4a
        await exporter.export()
        return fileURL
    }
    
    internal func prepareToPlay(url: URL) throws {
        // file prep
//        file = try AVAudioFile(forReading: url)
//        audioFileBuffer = AVAudioPCMBuffer(pcmFormat: file!.processingFormat, frameCapacity: UInt32(file!.length))
//        try file!.read(into: audioFileBuffer!)
        
    }
    
    var currentlyPlaying: MPMediaItem? = nil
    private var file: AVAudioFile?
    private var audioFileBuffer: AVAudioPCMBuffer?
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let eq = AVAudioUnitEQ(numberOfBands: 10)
    
    init() {
        engineInit()
    }
    
    internal func engineInit() {
        setEQBands()
    }
    
    func setEQBands() {
        let bands = StorageManager.shared.s.eqBands
        var freq = 32
        for i in 0..<eq.bands.count {
            eq.bands[i].frequency  = Float(freq)
            eq.bands[i].gain       = Float(bands[i])
            eq.bands[i].bypass     = false
            eq.bands[i].filterType = .parametric
            
            freq += freq
        }
    }
}
