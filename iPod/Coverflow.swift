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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(1..<20) { num in
                    VStack {
                        GeometryReader { geo in
                            let screenframe = UIScreen.main.bounds
                            let distanceToCentre = geo.frame(in: .global).midY.distance(to: screenframe.midY)
                            
                            Text("Hi")
                                .font(.largeTitle)
                                .padding()
                                .background(.red)
                                .frame(width: 200, height: 200)
                                .scaleEffect(
                                    (-100...100).contains(distanceToCentre) ? distanceToCentre : 1
                                )
                        }
                        .frame(width: 200, height: 200)
                    }
                }
            }
        }
    }
}

struct Coverflow_Previews: PreviewProvider {
    static var previews: some View {
        Coverflow()
    }
}
