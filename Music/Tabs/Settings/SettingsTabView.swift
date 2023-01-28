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
                Section("Equaliser") {
                    Text("gm")
                }
                
                Section("lol") {
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

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}
