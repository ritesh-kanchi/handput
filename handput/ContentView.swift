//
//  ContentView.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      OldHomeView()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
