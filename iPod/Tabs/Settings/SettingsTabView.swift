//
//  SettingsTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("App Icon") {
                    
                    Button {
                        UIApplication.shared.setAlternateIconName("AppIcon-3")
                    } label: {
                        Label {
                            Text("iOS 1")
                        } icon: {
                            Image("AppIcon3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                    
                    Button {
                        UIApplication.shared.setAlternateIconName("AppIcon-2")
                    } label: {
                        Label {
                            Text("iOS 4")
                        } icon: {
                            Image("AppIcon2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                    
                    Button {
                        UIApplication.shared.setAlternateIconName(nil)
                    } label: {
                        Label {
                            Text("Modern")
                        } icon: {
                            Image("AppIcon1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                }
                
                Section("Audio") {
                    NavigationLink {
                        eqSettings
                    } label: {
                        Text("Equaliser")
                    }
                    Button("Reset Storage") {
                        StorageManager.shared.s = StorageManager.blankTemplate
                    }
                    Button("Respring") {
                        let window = UIApplication.shared.windows.first!
                        while true {
                            window.snapshotView(afterScreenUpdates: false)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    @State var text1 = ""
    @State var text2 = ""
    @State var alert = false
    @State var focusedBand = 0
    @ObservedObject var store = StorageManager.shared
    @State var options = false
    
    @ViewBuilder
    var eqSettings: some View {
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
                store.s.eqBands[focusedBand] = value
            }
        }
        .alert("Edit Ranges", isPresented: $options) {
            TextField("Max", text: $text2).keyboardType(.decimalPad)
            TextField("Min", text: $text1).keyboardType(.decimalPad)
            Button("Cancel") {}
            Button("Save") {
                if let value = Double(text1) {
                    store.s.eqMin = value
                }
                if let value = Double(text2) {
                    store.s.eqMax = value
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
                    Text("\(store.s.eqBands[i])".prefix(4))
                        .lineLimit(1)
                        .font(.system(size: 9))
                    GeometryReader { geo in
                        VerticalSlider(
                            value: $store.s.eqBands[i],
                            geo: geo.size
                        )
                        .onTapGesture {
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
                        store.s.eqBands = preset.bands
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

struct VerticalSlider: View {
    @Binding var value: Double
    var geo: CGSize
    @ObservedObject var store = StorageManager.shared
    
    var body: some View {
        Slider(
            value: $value,
            in: store.s.eqMin...store.s.eqMax,
            step: 0.1
        )
        .rotationEffect(.degrees(-90.0), anchor: .topLeading)
        .frame(width: geo.height)
        .offset(x: geo.width / 8, y: geo.height)
        .animation(.spring(), value: value)
        .animation(.spring(), value: store.s.eqMax)
        .animation(.spring(), value: store.s.eqMin)
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
