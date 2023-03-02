//
//  PlayerPopover.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 08/02/2023.
//

import SwiftUI
import LNPopupUI
import Combine
import MediaPlayer
import MarqueeText

fileprivate var cancellable = Set<AnyCancellable>()

struct PlayerPopover: View {
    @ObservedObject var player = Player.shared
    @ObservedObject var store = StorageManager.shared
    @Environment(\.colorScheme) var cs
    var body: some View {
        VStack {
            fullpageView
        }
        .popupImage(player.coverImage, resizable: true)
        .popupTitle(player.trackTitle)
        .popupProgress(1)
        .popupBarItems(trailing: {
            Button {
                guard player.currentlyPlaying != nil else { return }
                player.togglePlayback()
            } label: {
                Image(systemName: player.isPaused ? "play.fill" : "pause.fill")
                    .font(.body.bold())
                    .padding(.horizontal, 4)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(cs == .light ? .black : .white)
            .opacity(player.currentlyPlaying == nil ? 0.4 : 1)
            .animation(.easeInOut, value: player.currentlyPlaying)
            
            Button {
                Task {
                    guard player.currentlyPlaying != nil else { return }
                    try? await player.nextSong()
                }
            } label: {
                Image(systemName: "forward.fill")
                    .font(.body.bold())
                    .padding(.leading, 2)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(cs == .light ? .black : .white)
            .opacity(player.currentlyPlaying == nil ? 0.4 : 1)
            .animation(.easeInOut, value: player.currentlyPlaying)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    
    
    
    
    
    
    @ViewBuilder var fullpageView: some View {
        VStack {
            cover
            songInfo
            mainControls
                .allowsHitTesting(player.currentlyPlaying == nil ? false : true)
                .opacity(player.currentlyPlaying == nil ? 0.6 : 1)
        }
        .preferredColorScheme(.dark)
        .padding(.horizontal)
        .frame(maxWidth: 500)
    }
    
    @ViewBuilder var cover: some View {
        VStack {
            player.coverImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(player.isPaused ? 0.8 : 1)
                .animation(
                    .spring(
                        response: 0.4,
                        dampingFraction: 0.5,
                        blendDuration: 0.25
                    ), value: player.isPaused
                )
                .background(HideVolumeHUD())
                .shadow(radius: 8)
        }
        .frame(maxWidth: 500, maxHeight: 500)
        .padding(.horizontal)
    }
    
    @ViewBuilder var songInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                MarqueeText(
                     text: player.currentlyPlaying?.title ?? "Not Playing",
                     font: UIFont.preferredFont(forTextStyle: .title3).bold(),
                     leftFade: 16,
                     rightFade: 16,
                     startDelay: 3
                 )
                Spacer()
            }
            HStack {
                MarqueeText(
                     text: player.currentlyPlaying?.artist ?? "",
                     font: UIFont.preferredFont(forTextStyle: .body).withSize(18),
                     leftFade: 16,
                     rightFade: 16,
                     startDelay: 3
                 )
                .foregroundColor(.white.opacity(0.75))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
//        .padding(.top, useAltLayout ? 15 : 0)
    }
    
    @State var progress: Double = 0
    
    @State var timer: Timer? = nil
    
    func updateProgress() {
        guard let nodeTime = self.player.player.lastRenderTime else { return }
        if let playerTime = self.player.player.playerTime(forNodeTime: nodeTime) {
            let secs = Double(playerTime.sampleTime) / playerTime.sampleRate
            let gm = (secs / self.player.duration)
            self.progress = gm.isLessThanOrEqualTo(1) ? gm : 1
        }
    }
    
    @ViewBuilder var mainControls: some View {
        VStack(spacing: 40) {
            NewSlider(value: $progress, max: 1, leadingView: {
                Text(Double(progress * player.duration).asTimestamp)
                    .font(.caption2)
            }, trailingView: {
                Text(player.duration.asTimestamp)
                    .font(.caption2)
            })
            .task {
                if self.timer == nil {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        Task {
                            await self.updateProgress()
                        }
                    })
                }
            }
            
            HStack(alignment: .center, spacing: 80) {
                Button {
                    Task {
                        guard player.currentlyPlaying != nil else { return }
                        try? await player.previousSong()
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxHeight: 30)
                
                Button {
                    Task {
                        guard player.currentlyPlaying != nil else { return }
                        player.togglePlayback()
                    }
                } label: {
                    Image(systemName: player.isPaused ? "play.fill" : "pause.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxHeight: 35)
                
                Button {
                    Task {
                        guard player.currentlyPlaying != nil else { return }
                        try? await player.nextSong()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxHeight: 30)
            }
            .foregroundColor(.white)
            
            VolumeSlider()
        }
        .padding(.bottom, 30)
    }
}

struct VolumeSlider: View {
    @State var volume: Double
    let avsession = AVAudioSession.sharedInstance()
    init() {
        try? avsession.setActive(true)
        self.volume = Double(avsession.outputVolume)
    }
    
    var body: some View {
        NewSlider(value: $volume, max: 1, leadingView: {
            Image(systemName: "speaker.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 15)
                .frame(width: 25)
        }, trailingView: {
            Image(systemName: "speaker.wave.3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 15)
                .frame(width: 25)
        }, labelStyle: .row)
        .onChange(of: volume, perform: { _ in
            MPVolumeView.setVolume(Float(volume))
        })
        .task {
            avsession.publisher(for: \.outputVolume)
                .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
                .sink { newVol in
                    withAnimation(.spring()) {
                        self.volume = Double(newVol)
                    }
                }
                .store(in: &cancellable)
        }
    }
}

struct NewSlider<Leading: View, Trailing: View>: View {
    @Binding var value: Double
    @State var max: Double
    @ViewBuilder var leadingView: Leading
    @ViewBuilder var trailingView: Trailing
    
    @State var isHeld: Bool = false
    
    var labelStyle: NewSliderLabelStyle = .stack
    
    var percentage: Double {
        value / max
    }
    
    var body: some View {
        VStack {
            if labelStyle == .stack {
                VStack {
                    slider
                    HStack {
                        leadingView
                        Spacer()
                        trailingView
                    }
                }
                .foregroundColor(.white.opacity(isHeld ? 1 : 0.75))
                .scaleEffect(isHeld && !useAltLayout ? 1.1 : 1)
                .padding()
            } else {
                HStack {
                    leadingView
                    slider
                    trailingView
                }
                .foregroundColor(.white.opacity(isHeld ? 1 : 0.75))
                .scaleEffect(isHeld && !useAltLayout ? 1.1 : 1)
                .padding()
            }
        }
        .shadow(color: .black.opacity(isHeld ? 0.4 : 0.1), radius: isHeld ? 8 : 2)
        .animation(.spring().speed(1.5), value: isHeld)
        .animation(.easeInOut(duration: 0.2), value: value)
        .frame(height: labelStyle == .stack ? 70 : 60)
    }
    
    @ViewBuilder var slider: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.white.opacity(0.1))
                Rectangle()
                    .frame(width: geo.size.width * percentage)
            }
            .clipShape(Capsule(style: .continuous))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        self.isHeld = true
                        self.value = min(
                            Swift.max(
                                0,
                                (
                                    Double(value.location.x) / Double(geo.size.width) * max
                                )
                            ),
                            max
                        )
                    })
                    .onEnded({ _ in
                        self.isHeld = false
                    })
            )
            .onChange(of: self.percentage) { newValue in
                if newValue == 0 || newValue == 1 {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
        .frame(height: isHeld ? 15 : 8 )
    }
}

enum NewSliderLabelStyle: String, CaseIterable {
    case stack = "Stack"
    case row = "Row"
}

struct HideVolumeHUD: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        
        let volumeView = MPVolumeView(frame: CGRect.zero)
        volumeView.isHidden = false
        volumeView.clipsToBounds = true
        volumeView.alpha = 0.001
        
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        
    }
}

struct PlayerPopover_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPopover()
            .background {
                Player.shared.coverImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 50)
                    .overlay {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(0)
                            .allowsHitTesting(false)
                            .background(.ultraThinMaterial)
                    }
                    .ignoresSafeArea()
            }
    }
}
