//
//  iPodApp.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import SwiftUI
import WelcomeSheet

let AccentColor = Color(red: 0.925, green: 0.471, blue: 0.208)

@main
struct iPodApp: App {
    @ObservedObject var store = StorageManager.shared
    @AppStorage("LastOnboardingVersion") var lastObVer: String = UserDefaults.standard.string(forKey: "LastOnboardingVersion") ?? "0.0.0"
    @State var isShowingOnboarding = false
    @Environment(\.colorScheme) var cs
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
//                    #if DEBUG
//                    self.isShowingOnboarding = true
//                    #else
                    let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0"
                    if lastObVer < appVersion {
                        self.isShowingOnboarding = true
                        self.lastObVer = appVersion
                    }
//                    #endif
                    
                    
                    let color = store.s.appColorTheme
                    UIApplication.shared.setTintColor(color)
                    
                    #if targetEnvironment(macCatalyst)
                    let scenes = UIApplication.shared.connectedScenes.compactMap { scene in
                        return scene as? UIWindowScene
                    }

                    scenes.forEach { scene in
                        if let titlebar = scene.titlebar {
                            titlebar.titleVisibility = .hidden
                            titlebar.toolbar = nil
                        }
                    }
                    #endif
                }
                .onChange(of: store.s.appColorTheme) { color in
                    UIApplication.shared.setTintColor(color)
                }
                .welcomeSheet(
                    isPresented: $isShowingOnboarding,
                    isSlideToDismissDisabled: true,
                    preferredColorScheme: .dark,
                    pages: obPages
                )
        }
    }
    
    let obPages = [
        WelcomeSheetPage(
            title: "Welcome to iPod",
            rows: [
                .init(
                    image: Image(systemName: "ipod"),
                    accentColor: .init(red: 0.968627451, green: 0.7098039216, blue: 0.2901960784),
                    title: "Nostalgic",
                    content: "Brings back the iPod app from iOS 5 with a modern style."
                ),
                .init(
                    image: Image(systemName: "music.note"),
                    accentColor: .init(red: 0.9019607843, green: 0.2666666667, blue: 0.3098039216),
                    title: "Familiar",
                    content: "iPod inherits UI from Apple Music, keeping core looks with nice touches."
                ),
                .init(
                    image: Image(systemName: "slider.horizontal.3"),
                    accentColor: .init(uiColor: .systemBlue),
                    title: "Customisable",
                    content: "Many aspects of the interface can be adjusted in settings."),
                .init(
                    image: Image(systemName: "waveform"),
                    accentColor: .green,
                    title: "Equaliser",
                    content: "iPod includes a powerful EQ, please read the important info before using."
                )
            ],
            accentUIColor: AccentColor.uiColor,
            mainButtonTitle: "Next",
            optionalButtonTitle: "Read this important info...",
            optionalButtonURL: URL(string: "https://github.com/llsc12/iPod#important")
        ),
        .init(title: "What's New?", rows: [
            .init(imageSystemName: "plus.circle.fill", title: "Library", content: "Work is being done to make a place to begin listening to music fast!")
        ], mainButtonTitle: "Finish")
    ]
}
