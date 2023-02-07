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
                            Text("iPhoneOS 1")
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
    
    @ObservedObject var store = StorageManager.shared
    @ViewBuilder
    var eqSettings: some View {
        VStack {
            let bands = 8
            HStack {
                ForEach(0..<bands, id: \.self) { i in
                    GeometryReader { geo in
                        VerticalSlider(
                            value: $store.s.eqBands[i], geo: geo.size
                        )
                    }
                }
            }
            .frame(height: screenheight / 3.5)
        }
        .navigationTitle("Equaliser")
    }
    
    var screenheight: CGFloat {
        UIScreen.main.bounds.height
    }
}

struct VerticalSlider: View {
    @Binding var value: Double
    var geo: CGSize

    var body: some View {
        Slider(
            value: $value,
            in: -6...12,
            step: 0.1
        )
        .rotationEffect(.degrees(-90.0), anchor: .topLeading)
        .frame(width: geo.height)
        .offset(x: geo.width / 5, y: geo.height)
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
