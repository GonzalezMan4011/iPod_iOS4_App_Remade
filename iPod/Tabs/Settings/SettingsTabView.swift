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
                        
                    } label: {
                        Text("Equaliser")
                    }
                    Button("gm") { gm = true }
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
}

struct Transparency: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
