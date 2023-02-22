//
//  Player.swift
//  equal sounds
//
//  Created by Gray, John Walker on 12/12/20.
//
//

import Foundation
import AVFoundation

class AVAudioPlayerNodeClass: AVAudioPlayerNode {
    var timer = Timer()
    private var audioFile: AVAudioFile? {
        didSet {
            self.duration = audioFile?.duration ?? 0
            self.isPlayable = audioFile != nil
        }
    }
    @objc dynamic var duration: TimeInterval
    @objc dynamic var currentPlayTime: TimeInterval
    var canBeResumed: Bool
    var isPlayable: Bool
//    var activeSubscription: (()->())?
    
    //MARK:- Player Internal
    
    override init() {
        duration = 0
        currentPlayTime = 0
        audioFile = nil
        canBeResumed = false
        isPlayable = false
        super.init()
        
        let updateInterval: Double = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            print("updating")
            if self.isPlaying {
                self.currentPlayTime += updateInterval
                if self.currentPlayTime > self.duration {
                    self.setPlaybackPosition(0)
                    self.pause()
                }
            }
        }
//        activeSubscription = nil
    }
    
    // There is no good way to extract the current time played within file apparently; there's a way to do it, but when not playing it always returns 0. Using a synchronized timer instead for reliable results
//    private func startTimer() {
//        if timer == nil {
//            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//                self.currentPlayTime += 1.0
////                if let subscriptionClosure = self.activeSubscription {
////                    subscriptionClosure()
////                }
//            }
//        }
//    }
//
//    private func stopTimer() {
//        if timer != nil {
//            timer?.invalidate()
//            timer = nil
//        }
//    }
    
//    func subscribeToTimer(closure: @escaping ()->()) {
//        activeSubscription = closure
//        stopTimer()
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
//        { _ in
//            self.currentPlayTime += 1.0
//            closure()
//        }
//    }
    
//    func unsubscribeFromTimer() {
//        stopTimer()
//        startTimer()
//    }
    
    //available externally but low usage expected, primarily intended for internal use
    func openFile(at url: URL) {
        do {
            print(url.path)
            print("loading song")
            try audioFile = AVAudioFile(forReading: url)
            print("loaded song")
        } catch {
            print("an exception occured during audio file initialization")
            return //false
        }
        self.scheduleFile(audioFile!, at: nil, completionHandler: nil)
        //return true
    }
    
    override func scheduleFile(_ file: AVAudioFile, at when: AVAudioTime?, completionCallbackType callbackType: AVAudioPlayerNodeCompletionCallbackType, completionHandler: AVAudioPlayerNodeCompletionHandler? = nil) {
        self.duration = file.duration
        super.scheduleFile(file, at: when, completionCallbackType: callbackType, completionHandler: completionHandler)
    }
    
    //MARK:- Player Controls
    
    func prepare() {
        guard audioFile != nil else {return}
        self.scheduleFile(audioFile!, at: nil, completionHandler: nil)
    }
    
    override func play() {
        play(at: nil)
    }
    
    override func play(at when: AVAudioTime?) {
        super.play(at: when)
        currentPlayTime = AVAudioTime.seconds(forHostTime: when?.hostTime ?? 0)
//        startTimer()
        canBeResumed = true
    }
    
    func play(file: AVAudioFile) {
        play(file: file, at: nil)
    }
    
    func play(file: AVAudioFile, at when: AVAudioTime?) {
        if isPlaying {
            stop()
        }
        audioFile = file
        prepare()
        play(at: when)
    }
    
    func resume() {
        resume(at: nil)
    }
    
    func resume(at when: AVAudioTime?) {
        if canBeResumed {
            super.play(at: when)
//            startTimer()
        }
    }
    
    override func pause() {
        if isPlaying {
            super.pause()
//            stopTimer()
        }
    }
    
    override func stop() {
        super.stop()
        self.reset()
//        stopTimer()
        currentPlayTime = 0.0
        canBeResumed = false
    }
    
    func fastForward() {
        if canBeResumed {
            if isPlaying {
                pause()
                self.reset()
                canBeResumed = false
            }
            currentPlayTime = (currentPlayTime + 10 > duration) ? duration : (currentPlayTime + 10)
            play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: currentPlayTime)))
        } else if isPlayable {
            currentPlayTime = 10
            play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: currentPlayTime)))
        }
    }
    
    func setPlaybackPosition(_ newPos: Double) {
        pause()
        self.reset()
        currentPlayTime = newPos
        play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: currentPlayTime)))
    }
    
    func rewind() {
        if canBeResumed {
            if isPlaying {
                pause()
                self.reset()
                canBeResumed = false
            }
            currentPlayTime = (currentPlayTime - 10 < 0) ? 0 : (currentPlayTime - 10)
            play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: currentPlayTime)))
        } else if isPlayable {
            play()
        }
    }
}

//MARK:- AVAudioFile Extension
extension AVAudioFile {
    var duration: TimeInterval {
        Double(Double(length) / processingFormat.sampleRate)
    }
}
