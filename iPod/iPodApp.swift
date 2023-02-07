//
//  iPodApp.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import SwiftUI

let accentColor = Color(red: 0.925, green: 0.471, blue: 0.208)

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

struct preview: PreviewProvider {
    static var previews: some View {
        nog()
    }
}

struct nog: View {
    @State var c: Color? = nil
    var body: some View {
        Rectangle()
            .foregroundColor(c)
            .task {
                struct e: Codable {
                    let color: Color
                }
                let data = "{\"color\":\"0.8 0.2 0.2\"}".data(using: .utf8)!
                
                let json = try? JSONDecoder().decode(e.self, from: data)
                if let json = json {
                    self.c = json.color
                }
            }
    }
}
