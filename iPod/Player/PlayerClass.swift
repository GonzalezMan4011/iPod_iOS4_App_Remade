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
import Combine

class Player: ObservableObject {
    static let shared = Player()
    
    @Published var playerBarShown = true
    @Published var playerFullscreen = false
    
    @Published var coverImage: Image = Image("MissingArtwork")
    @Published var trackTitle: String = "Not Playing"
    
    @Published var progress: Double = 0
    @Published var playbackTime: Double = 0
    @Published var duration: Double = 1
    
    @Published var isPaused: Bool = true
    
    var ignoreCallback = false
    
    func resume() {
        if !self.engine.isRunning { self.engine.prepare(); try? self.engine.start() }
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
        self.setPlayerData(nil)
        DispatchQueue.main.async {
            self.isPaused = true
        }
    }
    
    func togglePlayback() {
        if !self.isPaused {
            self.pause()
        } else {
            self.resume()
        }
    }
    
    func beginPlayingFromQueue(_ queue: [UInt64], atPos index: Int = 0) {
        self.stop()
        
        StorageManager.shared.s.playbackHistory = Array(queue[0..<index])
        let queue = Array(queue[index..<queue.count])
        
        DispatchQueue.main.async {
            self.playerQueue = queue
            Task {
                try? await self.nextSong()
            }
        }
    }
    
    func nextSong() async throws {
        guard let nextQueueItem = self.playerQueue.first else { return }
        DispatchQueue.main.async { if self.playerQueue.first != nil { self.playerQueue.removeFirst() }}
        try await self.playSongItem(persistentID: nextQueueItem)
    }
    
    func previousSong() async throws {
        guard let item = StorageManager.shared.s.playbackHistory.last else { return }
        StorageManager.shared.s.playbackHistory.removeLast()
        if let playing = self.currentlyPlaying {
            DispatchQueue.main.async {
                self.playerQueue.insert(playing.persistentID, at: 0)
            }
        }
        try await self.playSongItem(persistentID: item)
    }
    
    func tabBar(_ egg: Bool) {
        if egg {
            UITabBar.showTabBar(animated: false)
            playerBarShown = true
        } else {
            UITabBar.hideTabBar(animated: false)
            playerBarShown = false
        }
    }
    
    @Published var playerQueue: [UInt64] = []
    
    static func getSongItem(persistentID: UInt64) -> MPMediaItem? {
        guard let query = MPMediaQuery.songs().items else { return nil }
        let item = query.first(where: { item in
            item.persistentID == persistentID
        })
        
        return item
    }
    
    public func playSongItem(persistentID: UInt64) async throws {
        
        // stop whats playing, also clears out player data for us
        self.stop()
        
        // get the song that we need to play now and its asset url
        guard let song = Player.getSongItem(persistentID: persistentID) else { throw "No song found" }
        guard let fileUrl = song.assetURL else { throw "Asset track fetch failed" }
        
        do {
            // reset end of file
            
            // set the data of the class' variables to the currently playing song
            // - coverImage
            // - trackTitle
            
            setPlayerData(song)
            
            // schedules the track to be played if it can and inits the engine
            file = try AVAudioFile(forReading: fileUrl)
            engineInit()
            
            // starts the player
            
            self.resume()
        } catch {
            // clears the data for the player view
            setPlayerData(nil)
            await UIApplication.shared.presentAlert(title: "Track Error", message: "This track cannot be played.\n\(error.localizedDescription)\n\n\(String(reflecting: error))", actions: [UIAlertAction(title: "OK", style: .cancel)])
            throw error
        }
    }
    
    internal func setPlayerData(_ item: MPMediaItem?) {
        DispatchQueue.main.async {
            if let song = item {
                self.trackTitle = song.title ?? "Unknown"
                self.coverImage = Image(uiImage: song.art)
                self.currentlyPlaying = song
                self.duration = song.playbackDuration
            } else {
                self.trackTitle = "Not Playing"
                self.coverImage = Image(uiImage: Placeholders.noArtwork)
                self.currentlyPlaying = nil
                self.progress = 0
                self.playbackTime = 0
                self.duration = 1
                self.isPaused = true
            }
        }
    }
    
    var currentlyPlaying: MPMediaItem? = nil
    var file: AVAudioFile?
    private let engine = AVAudioEngine()
    let player = AVAudioPlayerNodeClass()
    private let eq = AVAudioUnitEQ(numberOfBands: 10)
    
    
    var cancellable = Set<AnyCancellable>()
    
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
        
        player
            .publisher(for: \.duration)
            .sink { duration in
                DispatchQueue.main.async {
                    self.duration = duration
                }
            }
            .store(in: &cancellable)
    }
    
    internal func engineInit() {
        setEQBands()
        guard let file = file else {
            UIApplication.shared.presentAlert(title: "Engine Init Error", message: "Audio File did not exist.")
            return
        }
        player.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { type in
            guard type == .dataPlayedBack else { return }
            self.playerDidFinishPlaying()
        }
    
        engine.prepare()
        do {
            try engine.start()
        } catch {
            UIApplication.shared.presentAlert(title: "Engine Init Error", message: error.localizedDescription)
        }
    }
    
    func playerDidFinishPlaying() {
        // playback ended, do any cleanup
        if let last = self.currentlyPlaying {
            let id = last.persistentID
            StorageManager.shared.s.playbackHistory.append(id)
        }
        DispatchQueue.main.async {
            self.isPaused = true
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
