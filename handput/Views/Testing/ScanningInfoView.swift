//
//  ScanningInfoView.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI

struct ScanningInfoView: View {
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                Image(systemName: "hand.raised")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
                    .foregroundColor(.secondary)
            }
            .frame(width: 240, height: 240)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 4, dash: [10]))
            }
            VStack(alignment: .center, spacing: 10) {
                Text("How to scan your hand")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("First, position your hand in the camera frame. Then wait for your hand to be found.")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
            }
            Spacer()
            
            NavigationLink(destination: ScanningView()) {
                DefaultButton(text: "Get Started")
            }
        }
        .padding()
    }
}

struct ScanningInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningInfoView()
    }
}
