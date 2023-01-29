//
//  PlayerOverlay.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import SwiftUI

struct PlayerOverlay: View {
    var body: some View {
        Button("gm") {
            
        }
    }
    
    var screenheight: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else { fatalError("no window found") }
        return window.screen.bounds.height
    }
}

struct PlayerOverlay_Previews: PreviewProvider {
    static var previews: some View {
        PlayerOverlay()
    }
}
