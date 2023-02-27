//
//  LibraryTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 26/02/2023.
//

import SwiftUI

struct LibraryTabView: View {
    @ObservedObject var lib = LibraryData.shared
    var body: some View {
        NavigationView {
            ScrollView {
                
            }
        }
        .navigationViewStyle(.stack)
    }
}

class LibraryData: ObservableObject {
    static let shared = LibraryData()
    
    init() {
        print("gorn")
    }
}

struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView()
    }
}
