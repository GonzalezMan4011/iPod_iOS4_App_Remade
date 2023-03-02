//
//  SettingsTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import SwiftUI
import MediaPlayer

struct SettingsTabView: View {
    @ObservedObject var eqStore = EQStorageManager.shared
    @ObservedObject var settingsStore = SettingsStorageManager.shared
    @ObservedObject var lib = MusicLibrary.shared
    @State var song: MPMediaItem? = nil
    @State var showHiddenAlbum = false
    
    var body: some View {
        NavigationView {
            Form {
                Button {
                    let url = URL(string: "https://github.com/llsc12/iPod")!
                    UIApplication.shared.open(url)
                } label: {
                    Label {
                        Text("Open Source on GitHub!")
                    } icon: {
                        Image("GitHub")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                }
                
                Section("Audio") {
                    NavigationLink {
                        EQSettings()
                    } label: {
                        Text("Equaliser")
                    }
                }
                .onChange(of: eqStore.s.eqBands) { _ in
                    Player.shared.setEQBands()
                }
                
                Section("Theming") {
                    ColorPicker("App Color", selection: $settingsStore.s.appColorTheme, supportsOpacity: false)
                    Button("Reset Color") {
                        settingsStore.s.appColorTheme = AccentColor
                    }
                    Toggle("Prioritise App Color", isOn: $settingsStore.s.useAppColorMore)
                    
                    Toggle("Tint Albums By Artwork", isOn: $settingsStore.s.tintAlbumsByArtwork)
                    
                    Slider(value: $settingsStore.s.playerBlurAmount, in: 1...50)
                        .task {
                            guard let song = lib.songs.randomElement() else { return }
                            self.song = song
                        }
                    
                    VStack(alignment: .leading) {
                        Text("Adjusts the fullscreen player's background blur.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        if let song = song {
                            Image(uiImage: song.art)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .blur(radius: CGFloat(showHiddenAlbum ? 0.0 : settingsStore.s.playerBlurAmount))
                                .overlay {
                                    Rectangle()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .opacity(0)
                                        .allowsHitTesting(false)
                                        .background(.ultraThinMaterial.opacity(showHiddenAlbum ? 0 : 1))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture(count: 2) {
                                    guard let song = lib.songs.randomElement() else { return }
                                    withAnimation(.easeInOut) {
                                        self.song = song
                                    }
                                }
                                .pressAction(onPress: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showHiddenAlbum = true
                                    }
                                }, onRelease: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showHiddenAlbum = false
                                    }
                                })
                            
                            Text("Hold album cover to reveal, double tap to shuffle.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                AppIcons
                
                Section("DEBUG") {
                    Button("Reset Storage") {
                        settingsStore.s = SettingsStorageManager.blankTemplate
                    }
                    Button("Respring") {
                        let window = UIApplication.shared.windows.first!
                        while true {
                            window.snapshotView(afterScreenUpdates: false)
                        }
                    }
                    Button {
                        print(
                            String(reflecting: SettingsStorageManager.shared.s),
                            String(reflecting: EQStorageManager.shared.s)
                        )
                    } label: {
                        Text("print storage to console")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .introspectSplitViewController { vc in
            vc.maximumPrimaryColumnWidth = 400
            #if targetEnvironment(macCatalyst)
            vc.preferredPrimaryColumnWidth = 400
            #endif
        }
    }
    
    @ViewBuilder var AppIcons: some View {
        Section("App Icon") {
            Button {
                UIApplication.shared.setAlternateIconName("AppIcon4")
            } label: {
                Label {
                    HStack {
                        Text("iPhoneOS 1")
                        Spacer()
                        Text("Apple")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon4")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            
            Button {
                UIApplication.shared.setAlternateIconName("AppIcon3")
            } label: {
                Label {
                    HStack {
                        Text("iOS 4")
                        Spacer()
                        Text("Apple")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            
            Button {
                UIApplication.shared.setAlternateIconName("AppIcon2")
            } label: {
                Label {
                    HStack {
                        Text("Modern")
                        Spacer()
                        Text("WhitetailAni")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            .contextMenu {
                Button {
                    let url = URL(string: "https://thanos.lol")!
                    UIApplication.shared.open(url)
                } label: {
                    HStack {
                        Text("WhitetailAni")
                        Spacer()
                        let img = URL(string: "https://thanos.lol/resources/fakekgb.png")!
                        AsyncImage(url: img) {
                            $0
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            
            Button {
                UIApplication.shared.setAlternateIconName(nil)
            } label: {
                Label {
                    HStack {
                        Text("Modern++")
                        Spacer()
                        Text("Alpha Stream")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            .contextMenu {
                Button {
                    let url = URL(string: "https://twitter.com/@Kutarin_")!
                    UIApplication.shared.open(url)
                } label: {
                    HStack {
                        Text("@Kutarin_")
                        Spacer()
                        let img = URL(string: "https://pbs.twimg.com/profile_images/1476283620998336512/roa2yt1o_400x400.jpg")!
                        AsyncImage(url: img) {
                            $0
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            
            Button {
                UIApplication.shared.setAlternateIconName("AppIcon5")
            } label: {
                Label {
                    HStack {
                        Text("Big Sur")
                        Spacer()
                        Text("yazanoo16")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon5")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            .contextMenu {
                Button {
                    let url = URL(string: "https://twitter.com/@yazanoo16")!
                    UIApplication.shared.open(url)
                } label: {
                    HStack {
                        Text("@yazanoo16")
                        Spacer()
                        let img = URL(string: "https://pbs.twimg.com/profile_images/1575535224519270400/Qv48-10B_400x400.png")!
                        AsyncImage(url: img) {
                            $0
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            
            Button {
                UIApplication.shared.setAlternateIconName("AppIcon6")
            } label: {
                Label {
                    HStack {
                        Text("Paint")
                        Spacer()
                        Text("iCraze")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon6")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            .contextMenu {
                Button {
                    let url = URL(string: "https://twitter.com/@iCrazeiOS")!
                    UIApplication.shared.open(url)
                } label: {
                    HStack {
                        Text("@iCrazeiOS")
                        Spacer()
                        let img = URL(string: "https://pbs.twimg.com/profile_images/1076564134261596162/eWvkoFR__400x400.jpg")!
                        AsyncImage(url: img) {
                            $0
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            
            Button {
                UIApplication.shared.setAlternateIconName("AppIcon7")
            } label: {
                Label {
                    HStack {
                        Text("DankPods")
                        Spacer()
                        Text("Alpha Stream")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image("Icon7")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
            .contextMenu {
                Button {
                    UIApplication.shared.setAlternateIconName("AppIcon8")
                } label: {
                    HStack {
                        Text("Secret Icon")
                        Spacer()
                        Image("Icon8")
                    }
                }
                Button {
                    let url = URL(string: "https://twitter.com/@Kutarin_")!
                    UIApplication.shared.open(url)
                } label: {
                    HStack {
                        Text("@Kutarin_")
                        Spacer()
                        let img = URL(string: "https://pbs.twimg.com/profile_images/1476283620998336512/roa2yt1o_400x400.jpg")!
                        AsyncImage(url: img) {
                            $0
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}

struct VerticalSlider: View {
    @Binding var value: Double
    @Binding var state: Bool
    var geo: CGSize
    @ObservedObject var store = EQStorageManager.shared
    
    var body: some View {
        Slider(
            value: $value,
            in: store.s.eqMin...store.s.eqMax,
            step: 0.1,
            onEditingChanged: { state in
                self.state = state
            }
        )
        .rotationEffect(.degrees(-90.0), anchor: .topLeading)
        .frame(width: geo.height)
        .offset(x: geo.width / 8, y: geo.height)
    }
}

struct EQSettings: View {
    @State var text1 = ""
    @State var text2 = ""
    @State var alert = false
    @State var focusedBand = 0
    @ObservedObject var store = EQStorageManager.shared
    @State var options = false
    
    @State var showDbLabels = false
    
    @ViewBuilder
    var body: some View {
        VStack {
            eq
                .frame(height: screenheight / 3.2)
            presets
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    makePreset()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    text1 = "\(store.s.eqMin)"
                    text2 = "\(store.s.eqMax)"
                    options = true
                } label: {
                    Image(systemName: "gear")
                }
                
            }
        })
        .onChange(of: store.s.eqBands) { _ in
#warning("apply changes to eq node")
        }
        .alert("Edit Value", isPresented: $alert) {
            TextField("Band Value", text: $text1).keyboardType(.decimalPad)
            Button("Cancel") {}
            Button("Save") {
                guard let value = Double(text1) else { return }
                withAnimation(.spring()) {
                    store.s.eqBands[focusedBand] = value
                }
            }
        }
        .alert("Edit Ranges", isPresented: $options) {
            TextField("Max", text: $text2).keyboardType(.decimalPad)
            TextField("Min", text: $text1).keyboardType(.decimalPad)
            Button("Cancel") {}
            Button("Save") {
                if let value = Double(text1) {
                    withAnimation(.spring()) {
                        store.s.eqMin = value
                    }
                }
                if let value = Double(text2) {
                    withAnimation(.spring()) {
                        store.s.eqMax = value
                    }
                }
            }
        } message: {
            Text("Edit the ranges for the EQ Sliders.")
        }
    }
    
    @ViewBuilder
    var eq: some View {
        let bands = 10
        HStack {
            ForEach(0..<bands, id: \.self) { i in
                VStack {
#warning("change this to frequency")
                    if !showDbLabels {
                        Text("\(Player.shared.computedFrequencies[i])")
                            .lineLimit(1)
                            .font(.system(size: 9))
                    } else {
                        Text("\(store.s.eqBands[i])".prefix(4))
                            .lineLimit(1)
                            .font(.system(size: 9))
                    }
                    GeometryReader { geo in
                        VerticalSlider(
                            value: $store.s.eqBands[i],
                            state: $showDbLabels,
                            geo: geo.size
                        )
                        .onTapGesture(count: 2) {
                            focusedBand = i
                            text1 = "\(store.s.eqBands[i])"
                            alert = true
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    @State var focusedPreset: UUID = UUID()
    @State var renameAlert = false
    @ViewBuilder
    var presets: some View {
        List {
            Section("Presets") {
                ForEach(store.s.eqPresets) { preset in
                    Button(preset.name) {
                        withAnimation(.default) {
                            store.s.eqBands = preset.bands
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            guard let i = (store.s.eqPresets.firstIndex { x in x == preset }) else { return }
                            store.s.eqPresets.remove(at: i)
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        .tint(.red)
                        Button {
                            focusedPreset = preset.id
                            text1 = preset.name
                            renameAlert = true
                        } label: {
                            Image(systemName: "pencil.line")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            guard let i = (store.s.eqPresets.firstIndex { x in x == preset }) else { return }
                            store.s.eqPresets[i].bands = store.s.eqBands
                        } label: {
                            Image(systemName: "waveform.badge.plus")
                        }
                        
                    }
                }
                .onMove { index, offset in
                    store.s.eqPresets.move(fromOffsets: index, toOffset: offset)
                }
            }
        }
        .animation(.default, value: store.s.eqPresets)
        .alert("Rename", isPresented: $renameAlert) {
            TextField("", text: $text1)
            Button("Cancel") {}
            Button("Save") {
                guard !text1.isEmpty else { return }
                guard let i = (store.s.eqPresets.firstIndex { x in x.id == focusedPreset }) else { return }
                store.s.eqPresets[i].name = text1
            }
        }
    }
    
    func makePreset() {
        let current = store.s.eqBands
        let new = EQPreset(name: "My New Preset", bands: current)
        store.s.eqPresets.append(new)
    }
    
    var screenheight: CGFloat {
        UIScreen.main.bounds.height
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
