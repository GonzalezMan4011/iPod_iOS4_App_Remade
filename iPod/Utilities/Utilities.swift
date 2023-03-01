//
//  Utilities.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import SwiftUI
import ViewExtractor
import MediaPlayer
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
// MARK: - iPod placeholders
struct Placeholders {
    static let noItemTitle = "Unknown"
    static let noArtwork = UIImage(named: "MissingArtwork")!
}

// MARK: - Make ordered list have index scrollTo
struct VerticalIndex: ViewModifier {
    let indexableList: [String]
    func body(content: Content) -> some View {
        var body: some View {
            ScrollViewReader { scrollProxy in
                content
                    .overlay(alignment: .trailing) {
                        VStack {
                            ForEach(indexableList, id: \.self) { letter in
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            scrollProxy.scrollTo(letter, anchor: .top)
                                        }
                                    }, label: {
                                        Text(letter)
                                            .font(.system(size: 12).bold())
                                            .padding(.trailing, 7)
                                    })
                                }
                            }
                        }
                        .task {
                            print(indexableList)
                        }
                    }
            }
        }
        return body
    }
}

let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "#"] //swiftlint:disable comma

// MARK: - Detect device rotation changes
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

// MARK: - Round specific corners
struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// MARK: - Hiding tab bar
public extension UITabBar {
    static func showTabBar(animated: Bool = true) {
        DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
                if let view = v as? UITabBar {
                    view.setIsHidden(false, animated: animated)
                }
            })
        }
    }
    
    // if tab View is used hide Tab Bar
    static func hideTabBar(animated: Bool = true) {
        DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
                if let view = v as? UITabBar {
                    view.setIsHidden(true, animated: animated)
                }
            })
        }
    }
    
    private static func updateFrame(_ view: UIView) {
        if let sv =  view.superview {
            let currentFrame = sv.frame
            sv.frame = currentFrame.insetBy(dx: 0, dy: 1)
            sv.frame = currentFrame
        }
    }
    
    // logic is implemented for hiding or showing the tab bar with animation
    private func setIsHidden(_ hidden: Bool, animated: Bool) {
        let isViewHidden = self.isHidden
        
        if animated {
            if self.isHidden && !hidden {
                self.isHidden = false
                Self.updateFrame(self)
                self.frame.origin.y = UIScreen.main.bounds.height + 200
            }
            
            if isViewHidden && !hidden {
                self.alpha = 0.0
            }
            
            UIView.animate(withDuration: 0.8, animations: {
                self.alpha = hidden ? 0.0 : 1.0
            })
            UIView.animate(withDuration: 0.6, animations: {
                
                if !isViewHidden && hidden {
                    self.frame.origin.y = UIScreen.main.bounds.height + 200
                }
                else if isViewHidden && !hidden {
                    self.frame.origin.y = UIScreen.main.bounds.height - self.frame.height
                }
            }) { _ in
                if hidden && !self.isHidden {
                    self.isHidden = true
                    Self.updateFrame(self)
                }
            }
        } else {
            if !isViewHidden && hidden {
                self.frame.origin.y = UIScreen.main.bounds.height + 200
            }
            else if isViewHidden && !hidden {
                self.frame.origin.y = UIScreen.main.bounds.height - self.frame.height
            }
            self.isHidden = hidden
            Self.updateFrame(self)
            self.alpha = 1
        }
    }
}

extension UIView {
    func allSubviews() -> [UIView] {
        var allSubviews = subviews
        for subview in subviews {
            allSubviews.append(contentsOf: subview.allSubviews())
        }
        return allSubviews
    }
}

// MARK: - Let bindings of Bool be inverted with ! prefix
prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

// MARK: - Get color values of Color
extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        
#if canImport(UIKit)
        typealias NativeColor = UIColor
#elseif canImport(AppKit)
        typealias NativeColor = NSColor
#endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, o)
    }
}

// MARK: - Make Color conform to codable
extension Color: Codable {
    public func encode(to encoder: Encoder) throws {
        let (r,g,b,a) = self.components
        var container = encoder.singleValueContainer()
        try container.encode("\(r) \(g) \(b) \(a)")
    }
    
    public init(from decoder: Decoder) throws {
        let str = try decoder.singleValueContainer().decode(String.self)
        let components = str.components(separatedBy: " ")
        guard components.count >= 3 else { throw "RGB color values not found"}
        guard let r = Double(components[0]),
              let g = Double(components[1]),
              let b = Double(components[2])
        else { throw "Invalid RGB values"}
        
        if components.count >= 4, let a = Double(components[3]) {
            self.init(red: r, green: g, blue: b, opacity: a)
        } else {
            self.init(red: r, green: g, blue: b)
        }
    }
}

// MARK: - Throw strings for errors
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

// MARK: - Get UIColor from Color
extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}

// MARK: - Function to set the accent color of all windows in the app
extension UIApplication {
    public func setTintColor(_ color: Color) {
        let windows = self.windows
        windows.forEach { win in
            win.tintColor = color.uiColor
        }
    }
}

// MARK: - Detect press and release gesture
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

// MARK: - Quickly present a UIAlert
extension UIApplication {
    public func presentAlert(title: String?, message: String?, actions: [UIAlertAction] = []) {
        guard let window = self.windows.first else { return }
        guard let vc = window.rootViewController else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        vc.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Get current view controller
extension UIApplication {
    static var visibleVC: UIViewController? {
        var currentVC = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        while let presentedVC = currentVC?.presentedViewController {
            if let navVC = (presentedVC as? UINavigationController)?.viewControllers.last {
                currentVC = navVC
            } else if let tabVC = (presentedVC as? UITabBarController)?.selectedViewController {
                currentVC = tabVC
            } else {
                currentVC = presentedVC
            }
        }
        return currentVC
    }
    
}

// MARK: - Dividers between views
struct DividedVStack<Content: View>: View {
    @ViewBuilder let content: Content
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        Extract(content) { views in
            VStack(alignment: alignment, spacing: spacing) {
                let first = views.first?.id
                
                ForEach(views) { view in
                    if view.id != first {
                        Divider()
                    }
                    
                    view
                }
            }
        }
    }
}

// MARK: - Variable to change ui layouts for ipad and mac
var useAltLayout: Bool {
    UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad
}


// MARK: - Extension to add context menu quickly to items
struct LibraryItemContextMenuModifier: ViewModifier {
    var album: MPMediaItemCollection?
    var song: MPMediaItem?
    var playlist: MPMediaItemCollection?
    @ObservedObject var player = Player.shared
    func body(content: Content) -> some View {
        if let album = album {
            if #available(iOS 16.0, *) {
                content
                    .contextMenu {
                        Button {
                            let songs = album.items.sorted { lhs, rhs in
                                lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                            }
                            
                            let queue = songs.map { $0.persistentID }
                            player.beginPlayingFromQueue(queue)
                        } label: {
                            Label("Play", systemImage: "play")
                        }
                        
                        Divider()
                        
                        Button {
                            let songs = album.items.sorted { lhs, rhs in
                                lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                            }
                            
                            let queue = songs.map { $0.persistentID }
                            
                            player.playerQueue.insert(contentsOf: queue, at: 0)
                        } label: {
                            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                        }
                        Button {
                            let songs = album.items.sorted { lhs, rhs in
                                lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                            }
                            
                            let queue = songs.map { $0.persistentID }
                            
                            player.playerQueue.append(contentsOf: queue)
                        } label: {
                            Label("Play Last", systemImage: "text.line.last.and.arrowtriangle.forward")
                        }
                    } preview: {
                        VStack(alignment: .leading) {
                            Image(uiImage: album.albumArt)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            Text(album.albumTitle ?? Placeholders.noItemTitle)
                            Text(album.representativeItem?.albumArtist ?? Placeholders.noItemTitle)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                
            } else {
                content
                    .contextMenu {
                        Button {
                            let songs = album.items.sorted { lhs, rhs in
                                lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                            }
                            
                            let queue = songs.map { $0.persistentID }
                            player.beginPlayingFromQueue(queue)
                        } label: {
                            Label("Play", systemImage: "play")
                        }
                        
                        Divider()
                        
                        Button {
                            let songs = album.items.sorted { lhs, rhs in
                                lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                            }
                            
                            let queue = songs.map { $0.persistentID }
                            
                            player.playerQueue.insert(contentsOf: queue, at: 0)
                        } label: {
                            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                        }
                        Button {
                            let songs = album.items.sorted { lhs, rhs in
                                lhs.albumTrackNumber < rhs.albumTrackNumber && lhs.discNumber < rhs.discNumber
                            }
                            
                            let queue = songs.map { $0.persistentID }
                            
                            player.playerQueue.append(contentsOf: queue)
                        } label: {
                            Label("Play Last", systemImage: "text.line.last.and.arrowtriangle.forward")
                        }
                    }
            }
        } else if let song = song {
            if #available(iOS 16.0, *) {
                content
                    .contextMenu {
                        Button("gm") {
                            
                        }
                    } preview: {
                        let size: CGFloat = 100
                        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
                        
                        HStack(alignment: .center) {
                            Image(uiImage: song.art)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: size)
                                .frame(maxWidth: size)
                                .clipShape(shape)
                                .background {
                                    shape
                                        .strokeBorder(.gray.opacity(0.2), lineWidth: 0.5, antialiased: true)
                                }
                            
                            VStack(alignment: .leading) {
                                Text(song.title ?? Placeholders.noItemTitle)
                                Text(song.albumArtist ?? Placeholders.noItemTitle)
                                    .foregroundColor(.init(UIColor.secondaryLabel))
                                    .font(Font.caption)
                                
                                if let date = song.value(forProperty: MPMediaItemPropertyReleaseDate) as? Date {
                                    let albumName = song.albumTitle ?? ""
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.year], from: date)
                                    let year = components.year == nil ? "" : String(components.year!)
                                    let separator = albumName.isEmpty || year.isEmpty ? "" : " • "
                                    Text(useAltLayout ? "\(albumName + separator + year)".uppercased() : "\(albumName + separator + year)".capitalized)
                                        .foregroundColor(.init(UIColor.tertiaryLabel))
                                        .font(.caption2)
                                } else {
                                    Text(song.albumTitle ?? Placeholders.noItemTitle)
                                        .foregroundColor(.init(UIColor.tertiaryLabel))
                                        .font(.caption2)
                                }
                            }
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .padding()
                    }
                
            } else {
                content.contextMenu {
                    Button("gm") {
                        
                    }
                    
                }
            }
        } else if let playlist = playlist {
            
        } else {
            content
        }
    }
}

extension View {
    func addContextMenu(album: MPMediaItemCollection) -> some View {
        self
            .modifier(LibraryItemContextMenuModifier(album: album))
    }
    func addContextMenu(song: MPMediaItem) -> some View {
        self
            .modifier(LibraryItemContextMenuModifier(song: song))
    }
    func addContextMenu(playlist: MPMediaItemCollection) -> some View {
        self
            .modifier(LibraryItemContextMenuModifier(playlist: playlist))
    }
}

// MARK: - Extension to Color that adds random pastel colors and some color additions
extension Color {
    static func random(withMixedColor mixColor: Color? = nil) -> Color {
        // Randomly generate number in closure
        let randomColorValueGenerator = { () -> CGColor in
            let r = CGFloat(arc4random() % 256 ) / 256
            let g = CGFloat(arc4random() % 256 ) / 256
            let b = CGFloat(arc4random() % 256 ) / 256
            return CGColor(red: r, green: g, blue: b, alpha: 1)
        }
        
        var niceColor = randomColorValueGenerator()
        
        // Mix the color
        if let mixColor = mixColor {
            var mixRed: CGFloat = 0, mixGreen: CGFloat = 0, mixBlue: CGFloat = 0;
            mixColor.uiColor.getRed(&mixRed, green: &mixGreen, blue: &mixBlue, alpha: nil)
            
            niceColor = CGColor(red: (niceColor.red + mixRed) / 2, green: niceColor.green, blue: niceColor.blue, alpha: niceColor.alpha)
            
            niceColor = CGColor(red: niceColor.red, green: (niceColor.green + mixGreen) / 2, blue: niceColor.blue, alpha: niceColor.alpha)
            
            niceColor = CGColor(red: niceColor.red, green: niceColor.green, blue: (niceColor.blue + mixBlue) / 2, alpha: niceColor.alpha)
        }
        
        return Color(cgColor: niceColor)
    }
}

extension CGColor {
    var red: CGFloat {
        CIColor(cgColor: self).red
    }
    var green: CGFloat {
        CIColor(cgColor: self).green
    }
    var blue: CGFloat {
        CIColor(cgColor: self).blue
    }
    var alpha: CGFloat {
        CIColor(cgColor: self).alpha
    }
}

// MARK: - Set system volume
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.async {
            slider?.value = volume
        }
    }
}

// MARK: - Timestamp from Double (in seconds)
extension Double {
    var asTimestamp: String {
        let seconds = Int(self)
        let (h, m, s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let hStr: String = h == 0 ? "" : "\(h):"
        let mStr: String = "\(m)"
        let sStr: String = {
            if s <= 9 { return "0\(s)" }
            else { return "\(s)" }
        }()
        
        return "\(hStr)\(mStr):\(sStr)"
    }
}

// MARK: - Add Bold and Italic UIFont chaining
extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
