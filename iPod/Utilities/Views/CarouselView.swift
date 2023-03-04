//
//  CarouselView.swift
//  Kawari
//
//  Created by Lakhan Lothiyi on 23/02/2023.
//

import SwiftUI
import ViewExtractor

public struct CarouselView<Content: View>: View {
    
    @ViewBuilder let content: Content
    
    var delay: Double
    
    /// Creates an instance that goes through content in order.
    init(delay: Double = 5, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.delay = delay
    }
    
    /// The content and behavior of the view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that SwiftUI provides, plus other
    /// composite views that you've already defined:
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             Text("Hello, World!")
    ///         }
    ///     }
    ///
    /// For more information about composing views and a view hierarchy,
    /// see <doc:Declaring-a-Custom-View>.
    
    @State var shownIndex: Int = 0
    
    @State var timer: Timer? = nil
    
    public var body: some View {
        Extract(content) { views in
            TabView(selection: $shownIndex) {
                ForEach(0..<views.count, id: \.self) { i in
                    views[i]
                        .tag(i)
                }
            }
            .tabViewStyle(.page)
            .animation(.default, value: shownIndex)
            .onAppear {
                regenTimer(count: views.count)
            }
            .onChange(of: shownIndex) { _ in
                self.timer?.invalidate()
                regenTimer(count: views.count)
            }
        }
    }
    
    func regenTimer(count: Int) {
        self.timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { timer in
            if shownIndex == (count - 1) {
                // go back to start
                shownIndex = 0
            } else {
                // increment
                shownIndex += 1
            }
            timer.invalidate()
        }
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(delay: 3) {
            ForEach(0..<6, id: \.self) { i in
                Text("\(i)")
                    .foregroundColor(.white)
                    .padding(100)
                    .background(.pink)
                    .cornerRadius(15)
            }
        }
    }
}
