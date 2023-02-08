//
//  PlayerPopover.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 08/02/2023.
//

import SwiftUI

struct PlayerPopover: View {
    @ObservedObject var player = Player.shared
    var body: some View {
        VStack {
            Button("gn") {
                player.playerFullscreen = false
            }
        }
        .popupImage(player.coverImage, resizable: true)
        .popupTitle(player.trackTitle)
    }
}

struct PlayerPopover_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPopover()
    }
}
