//
//  Coverflow.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI

struct Coverflow: View {
    @Binding var rotation: UIDeviceOrientation
    var rotateModifierAmount: Double {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch rotation {
            case .landscapeLeft:
                return 90
            case .landscapeRight:
                return -90
            default:
                return 0
            }
        } else { return 0 }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            main
                .rotationEffect(.degrees(rotateModifierAmount))
        }
    }
    
    @ViewBuilder var main: some View {
        Text("coverflow!")
    }
}

struct Coverflow_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowPreviews()
    }
}

struct CoverFlowPreviews: View {
    @State var gm: UIDeviceOrientation = .unknown
    var body: some View {
        Coverflow(rotation: $gm)
            .onRotate { newValue in
                self.gm = newValue
            }
    }
}
