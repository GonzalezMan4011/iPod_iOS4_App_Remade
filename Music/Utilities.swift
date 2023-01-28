//
//  Utilities.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 27/01/2023.
//

import Foundation
import SwiftUI

struct Placeholders {
    static let noItemTitle = "Unknown"
    static let noArtwork = UIImage(named: "MissingArtwork")!
}


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
                                            .font(.system(size: 12))
                                            .padding(.trailing, 7)
                                            .bold()
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

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
