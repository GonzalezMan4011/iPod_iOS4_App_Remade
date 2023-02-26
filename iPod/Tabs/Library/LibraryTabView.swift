//
//  LibraryTabView.swift
//  iPod
//
//  Created by Lakhan Lothiyi on 26/02/2023.
//

import SwiftUI

struct LibraryTabView: View {
    @State var egg = false
    var body: some View {
        Text("Under Contruction!")
            .padding()
            .background(.red)
            .offset(y: egg ? -20 : 0)
    }
}

struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView()
    }
}
