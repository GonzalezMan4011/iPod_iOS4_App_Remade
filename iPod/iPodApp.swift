//
//  iPodApp.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import SwiftUI

let AccentColor = Color(red: 0.925, green: 0.471, blue: 0.208)

@main
struct iPodApp: App {
    @ObservedObject var store = StorageManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let color = store.s.appColorTheme
                    UIApplication.shared.setTintColor(color)
                }
                .onChange(of: store.s.appColorTheme) { color in
                    UIApplication.shared.setTintColor(color)
                }
        }
    }
}
