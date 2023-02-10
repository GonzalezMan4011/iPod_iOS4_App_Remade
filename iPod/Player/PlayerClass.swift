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
    
    @Published var isPaused: Bool = true
    
    func resume() {
        self.player.play()
        DispatchQueue.main.async {
            self.isPaused = false
        }
    }
    
    func pause() {
        self.player.pause()
        DispatchQueue.main.async {
            self.isPaused = true
        }
    }
    
    func stop() {
        self.player.stop()
        self.currentlyPlaying = nil
        DispatchQueue.main.async {
            self.isPaused = true
        }
    }
    
    func togglePlayback() {
        if self.player.isPlaying {
            self.pause()
        } else {
            self.resume()
        }
    }
    
    func nextSong() async throws {
        guard let _ = self.playerQueue.first else { return }
        let nextQueueItem = self.playerQueue.popFirst()!
        try await self.playSongItem(persistentID: nextQueueItem, addToHistory: true)
    }
    
    func previousSong() async throws {
        guard let _ = StorageManager.shared.s.playbackHistory.last else { return }
        let item = StorageManager.shared.s.playbackHistory.popLast()!
        if let playing = self.currentlyPlaying {
            self.playerQueue.insert(playing.persistentID, at: 0)
        }
        try await self.playSongItem(persistentID: item, addToHistory: false)
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
    
    public func playSongItem(persistentID: UInt64, addToHistory: Bool = false) async throws {
        self.stop()
        setPlayerData(nil)
        guard let song = Player.getSongItem(persistentID: persistentID) else { throw "No song found" }
        self.currentlyPlaying = song
        guard let fileUrl = song.assetURL else { throw "Asset track fetch failed" }
        if addToHistory, let playing = self.currentlyPlaying {
            StorageManager.shared.s.playbackHistory.append(playing.persistentID)
        }
        do {
            setPlayerData(song)
            try prepareToPlay(url: fileUrl)
            self.resume()
        } catch {
            setPlayerData(nil)
            await UIApplication.shared.presentAlert(title: "Track Error", message: "This track cannot be played.\n\(error.localizedDescription)\n\n\(String(reflecting: error))", actions: [UIAlertAction(title: "OK", style: .cancel)])
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
                self.isPaused = true
            }
        }
    }
    
    internal func prepareToPlay(url: URL) throws {
//      file prep
        file = try AVAudioFile(forReading: url)
        
        engineInit()
    }
    
    var currentlyPlaying: MPMediaItem? = nil
    private var file: AVAudioFile?
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let eq = AVAudioUnitEQ(numberOfBands: 10)
    
    init() {
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        
        setEQBands()
        
        // attach nodes to engine
        engine.attach(eq)
        engine.attach(player)
        
        // connect player to eq node
        let mixer = engine.mainMixerNode
        engine.connect(player, to: eq, format: mixer.outputFormat(forBus: 0))
        
        // connect eq node to mixer
        engine.connect(eq, to: mixer, format: mixer.outputFormat(forBus: 0))
    }
    
    internal func engineInit() {
        setEQBands()
        guard let file = file else {
            UIApplication.shared.presentAlert(title: "Engine Init Error", message: "Audio File Buffer did not exist.")
            return
        }
//        player.scheduleBuffer(audioBuffer, at: nil, options: .interrupts, completionHandler: nil)
        player.scheduleFile(file, at: nil)
        engine.prepare()
        do {
            try engine.start()
        } catch {
            UIApplication.shared.presentAlert(title: "Engine Init Error", message: error.localizedDescription)
        }
    }
    
    var computedFrequencies: [Int] {
        var array: [Int] = []
        var freq = 32
        for _ in 0..<eq.bands.count {
            array.append(freq)
            freq += freq
        }
        return array
    }
    
    func setEQBands() {
        let bands = StorageManager.shared.s.eqBands
        var freq = 32
        eq.globalGain = 1
        for i in 0..<eq.bands.count {
            eq.bands[i].frequency  = Float(freq)
            eq.bands[i].gain       = Float(bands[i])
            eq.bands[i].bypass     = false
            eq.bands[i].filterType = .parametric
            
            freq += freq
        }
    }
}


let AVFileTypeLookupTable: [String: AVFileType] = [
    "mov": .mov,
    "mp4": .mp4,
    "m4v": .m4v,
    "m4a": .m4a,
    "3gp": .mobile3GPP,
    "3gpp": .mobile3GPP,
    "sdv": .mobile3GPP,
    "3g2": .mobile3GPP2,
    "3gp2": .mobile3GPP2,
    "caf": .caf,
    "wav": .wav,
    "wave": .wav,
    "bwf": .wav,
    "aif": .aiff,
    "aiff": .aiff,
    "aifc": .aifc,
    "cdda": .aifc,
    "amr": .amr,
    "mp3": .mp3,
    "au": .au,
    "snd": .au,
    "ac3": .ac3,
    "eac3": .eac3,
    "jpg": .jpg,
    "jpeg": .jpg,
    "dng": .dng,
    "heic": .heic,
    "avci": .avci,
    "heif": .heif,
    "tif": .tif,
    "tiff": .tif
]
