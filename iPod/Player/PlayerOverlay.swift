//
//  PlayerOverlay.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 29/01/2023.
//

import SwiftUI

struct PlayerOverlay: View {
    @ObservedObject var player = Player.shared
    @State var offset = CGSize.zero
    var body: some View {
        VStack {
            Spacer()
            content
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            Button("gn") {
                player.playerIsMini.toggle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .overlay(alignment: .top, content: {
            Image(systemName: "chevron.compact.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35)
                .foregroundColor(.secondary)
                .padding(.top)
                .opacity(0.8)
        })
        .padding(.top)
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

struct Transparency: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ViewIntercept: UIViewRepresentable {
    @Binding var view: UIView?
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            self.view = view.superview?.superview
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
