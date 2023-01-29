//
//  Utilities.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import SwiftUI

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
