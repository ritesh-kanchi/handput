//
//  HomeView.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI

struct HomeView: View {
    
    @State private var aboutSheet = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink(destination: ScanningInfoView()) {
                    Text("Scan your hand")
                }
            }
            .navigationTitle("handput")
            .toolbar {
                Button(action: {
                    aboutSheet.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .imageScale(.large)
                }
                .sheet(isPresented: $aboutSheet) {
                    AboutView(aboutSheet: $aboutSheet)
                }
            }
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
       HomeView()
    }
}

