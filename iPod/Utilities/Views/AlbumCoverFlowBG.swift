//
//  AlbumCoverFlowBG.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 02/03/2023.
//

import SwiftUI
import MediaPlayer
import Combine

fileprivate var cancellable = Set<AnyCancellable>()
var bgCarouselItems = 30

struct AlbumCoverFlowBG: View {
    @ObservedObject var lib = MusicLibrary.shared
    var duration: Double {
        Double(bgCarouselItems + 1) * 10
    }
    @State var atEnd = false
    
    public var body: some View {
        let calc = (bounds.height / 2) * CGFloat(bgCarouselItems)
        VStack(spacing: 0) {
            if let randomAlbums = lib.carousel {
                HStack(spacing: 0) {
                    ForEach(0..<randomAlbums.count, id: \.self) { i in
                        let uiImg = randomAlbums[i]
                        Image(uiImage: uiImg)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: bounds.height, height: bounds.height)
                    }
                    let uiImg = randomAlbums[0]
                    Image(uiImage: uiImg)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: bounds.height, height: bounds.height)
                }
                .offset(x: atEnd ? calc.negated() : calc)
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .task {
            withAnimation(.linear(duration: duration).repeatForever()) {
                atEnd.toggle()
            }
        }
    }
        
    
    var bounds = UIScreen.main.bounds
}


struct AlbumCoverFlowBG_Previews: PreviewProvider {
    static var previews: some View {
        AlbumCoverFlowBG()
    }
}
