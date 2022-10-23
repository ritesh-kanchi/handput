//
//  AboutView.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI


private struct AboutItem: Identifiable {
    var id = UUID()
    var icon: String
    var heading: String
    var text: String
}

private let aboutItems: [AboutItem] = [
AboutItem(icon: "camera.viewfinder", heading: "Camera Usage", text: "handput uses your device's front camera to detect your hand."),AboutItem(icon: "brain.head.profile", heading: "Machine Learning", text: "Using ML, handput only detects your hand, ignoring anything else."),AboutItem(icon: "hand.raised.circle", heading: "Privacy", text: "All data is interpreted in realtime, with no data being stored or sent.")]


struct AboutView: View {
    
    @Binding var aboutSheet: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button("Done") {
                    aboutSheet.toggle()
                }
            }
            .padding()
            VStack(spacing: 40) {
                VStack(spacing: 10) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text("How handput works")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("**handput** works due to a few different technologies. Here are descriptions on how it works.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 20) {
                    ForEach(aboutItems) { item in
                        HStack(alignment: .center, spacing: 20) {
                            Image(systemName: item.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(item.heading)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Text(item.text)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(40)
            Spacer()
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(aboutSheet: .constant(true))
    }
}
