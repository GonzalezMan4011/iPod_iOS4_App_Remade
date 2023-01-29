//
//  Coverflow.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 28/01/2023.
//

import SwiftUI

struct Coverflow: View {
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            main
        }
        
    }
    
    @ViewBuilder var main: some View {
        Text("coverflow!")
    }
}

struct Coverflow_Previews: PreviewProvider {
    static var previews: some View {
        Coverflow()
    }
}
