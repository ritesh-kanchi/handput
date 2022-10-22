//
//  ScanningView.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI

struct ScanningView: View {
    
    @State private var overlayPoints: [CGPoint] = []
    
    @StateObject var camera = CameraModel()
    
    @State private var visible = true
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                                CameraPreview(camera: camera) {
                                  overlayPoints = $0
                                }
                                .overlay(
                                  FingersOverlay(with: overlayPoints)
                                    .foregroundColor(.orange)
                                )
                
                
//                Rectangle()
//                    .fill(.blue)
                    .frame(width: 360, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay{
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.black.opacity(0.25), style: StrokeStyle(lineWidth: 10))
                    }
            }
            .frame(width: 380, height: 380)
            .overlay{
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(.white.opacity(0.1), style: StrokeStyle(lineWidth: 10))
                    .opacity(visible ? 0 : 1)
            }
            
            
            VStack {
                Text("Position your hand within the frame.")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
                Text("\(overlayPoints.count) joints detected".uppercased())
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .padding(.horizontal, 20)
                    .padding(.vertical,10)
                    .background(.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            Spacer()
            
        }
        .onAppear(perform: {
            camera.Check()
            pulsateText()
        })
    }
    
    private func pulsateText() {
        withAnimation(Animation.easeIn(duration: 1).repeatForever(autoreverses: true)) {
            visible.toggle()
        }
    }
}

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}

struct FingersOverlay: Shape {
    let points: [CGPoint]
    private let pointsPath = UIBezierPath()
    
    init(with points: [CGPoint]) {
        self.points = points
    }
    
    func path(in rect: CGRect) -> Path {
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        return Path(pointsPath.cgPath)
    }
}
