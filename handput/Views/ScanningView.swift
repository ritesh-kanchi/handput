//
//  ScanningView.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI

func getJointColor(_ point: FingerJointPointCG) -> Color {
    switch point.type {
    case .tip:
        return .blue
    case .dip:
        return .green
    case .pip:
        return .yellow
    case .mcp:
        return .orange
    case .ip:
        return .green
    case .mp:
        return .yellow
    case .cmc:
        return .orange
    default:
        return .white
    }
}

enum GestureType {
    case open
    case closed
    case one
    case two
    case three
    case undefined
}

func getGesture(_ points: [FingerJointPointCG]) -> GestureType {
    
    let tips = points.filter({ $0.type == .tip }).count
    let pips = points.filter({ $0.type == .pip }).count
    let dips = points.filter({ $0.type == .dip }).count
    let mcps = points.filter({ $0.type == .mcp }).count
    
    let ips = points.filter({ $0.type == .ip }).count
    let mps = points.filter({ $0.type == .mp }).count
    let cmcs = points.filter({ $0.type == .cmc }).count
    
    let maxTips = 5
    let maxPips = 4
    let maxDips = 4
    let maxMcps = 4
    
    let maxIps = 1
    let maxMps = 1
    let maxCmcs = 1
    
    let fullTips = maxTips == tips
    let fullPips = maxPips == pips
    let fullDips = maxDips == dips
    let fullMcps = maxMcps == mcps
    
    let fullIps = maxIps == ips
    let fullMps = maxMps == mps
    let fullCmcs = maxCmcs == cmcs
    
    
    if(fullTips && fullDips && fullPips && fullIps) {
        return .open
    } else {
        return .undefined
    }
}

func getGestureIdentification(_ gesture: GestureType) -> String {
    switch gesture {
    case .open:
        return "Open"
    case .closed:
        return "Closed"
    case .one:
        return "One Finger"
    case .two:
        return "Two Fingers"
    case .three:
        return "Three Fingers"
    default:
        return "Undefined"
    }
}

struct ScanningView: View {
    
    @State private var overlayPoints: [FingerJointPointCG] = []
    
    @StateObject var camera = CameraModel()
    
    @State private var visible = true
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                CameraPreview(camera: camera) {
                    overlayPoints = $0
                }
                .overlay {
                    //                                  FingersOverlay(with: overlayPoints)
                    //                                    .foregroundColor(.orange)
                    ZStack {
                        ForEach(overlayPoints) { point in
                            Circle()
                                .fill(getJointColor(point))
                                .frame(width: 5, height: 5)
                                .position(x: point.location.x, y: point.location.y)
                                .tag(point.id)
                            
                        }
                        
                        Path() { path in
                            if(!overlayPoints.isEmpty) {
                                path.move(to: overlayPoints[0].location)
                                for point in overlayPoints {
                                    path.addLine(to: point.location)
                                }
                            }
                        }
                        .stroke(Color.green)
                    }
                }
                
                
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
            
            
            VStack(alignment: .center) {
                Text("Position your hand within the frame.")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
                HStack(alignment: .center, spacing: 10) {
                    Text("\(overlayPoints.count) joints detected".uppercased())
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 20)
                        .padding(.vertical,10)
                        .background(.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .onTapGesture {
                            print(overlayPoints)
                        }
                    Text("\(getGestureIdentification(getGesture(overlayPoints)))".uppercased())
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .padding(.horizontal, 20)
                        .padding(.vertical,10)
                        .background(.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
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
    let points: [FingerJointPointCG]
    private let pointsPath = UIBezierPath()
    
    init(with points: [FingerJointPointCG]) {
        self.points = points
    }
    
    func path(in rect: CGRect) -> Path {
        for point in points {
            pointsPath.move(to: point.location)
            pointsPath.addArc(withCenter: point.location, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        return Path(pointsPath.cgPath)
    }
}
