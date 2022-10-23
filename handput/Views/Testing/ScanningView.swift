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
    
    let totalJoints = points.count
    
    let tips = points.filter({ $0.type == .tip }).count
    let pips = points.filter({ $0.type == .pip }).count
    let dips = points.filter({ $0.type == .dip }).count
    let mcps = points.filter({ $0.type == .mcp }).count
    
    let ips = points.filter({ $0.type == .ip }).count
    let mps = points.filter({ $0.type == .mp }).count
    let cmcs = points.filter({ $0.type == .cmc }).count
    
    let wrist = points.filter({ $0.type == .wrist }).count
    
    let maxTips = 5
    let maxPips = 4
    let maxDips = 4
    let maxMcps = 4
    
    let maxIps = 1
    let maxMps = 1
    let maxCmcs = 1
    
    let maxWrist = 1
    
    let fullTips = maxTips == tips
    let fullPips = maxPips == pips
    let fullDips = maxDips == dips
    let fullMcps = maxMcps == mcps
    
    let fullIps = maxIps == ips
    let fullMps = maxMps == mps
    let fullCmcs = maxCmcs == cmcs
    
    let fullWrist = wrist == maxWrist
    
    if tips >= 5 && fullDips && fullPips && fullIps  {
        return .open
    }
    
    
    if totalJoints <= 20 && totalJoints >= 11 && tips >= 1 && tips < 5 {
        return .two
    }
    
    if totalJoints <= 9 && totalJoints >= 3 {
        return .closed
    }
    
    return .undefined
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
                    CameraOverlay(overlayPoints: overlayPoints)
                }
                .frame(width: 360, height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay{
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.black.opacity(0.25), style: StrokeStyle(lineWidth: 10))
                }
                .fixedSize()
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
                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("\(overlayPoints.filter{$0.type != .wrist}.count) joints detected".uppercased())
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
                    HStack(alignment: .center, spacing: 10) {
                        Text("\(overlayPoints.filter{$0.type == .wrist}.count > 0 ? "" : "no ")wrist detected".uppercased())
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .padding(.horizontal, 20)
                            .padding(.vertical,10)
                            .background(.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Text(getDistanceResponse(determineDistanceFromScreen(points: overlayPoints)).uppercased())
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .padding(.horizontal, 20)
                            .padding(.vertical,10)
                            .background(.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
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

enum HandDistances {
    case near
    case ideal
    case far
    case undefined
}

func getDistanceResponse(_ handDist: HandDistances) -> String {
    switch handDist {
    case .near:
        return "too close"
    case .ideal:
        return "ideal distance"
    case .far:
        return "too far"
    default:
        return "undefined"
    }
}

func getCGDistance(point1: CGPoint, point2: CGPoint) -> Double {
    
    let distance = sqrt(pow((point1.x - point2.x), 2)+pow((point1.y - point2.y), 2))
    
    print(distance)
    
    return distance
    
}



func determineDistanceFromScreen(points: [FingerJointPointCG]) -> HandDistances {
    
    if !points.isEmpty && points.count > 2 {
        let point1 = points.contains {$0.finger == .wrist} ? points.filter {$0.finger == .wrist}[0].location : points[0].location
        
        let point2 = points.contains {$0.finger == .index && $0.type == .tip} ? points.filter {$0.finger == .index && $0.type == .tip}[0].location : points[1].location
        
        let distance = getCGDistance(point1: point1, point2: point2)
        
        if points.count >= 20 {
           return .ideal
       } else if distance > 280 || (points.count < 17 && distance < 200) {
            return .near
        } else if distance < 100 {
            return .far
        }
    }
    
    return .undefined
    
}

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}

struct CameraOverlay: View {
    
    var overlayPoints: [FingerJointPointCG]
    
    var body: some View {
        ZStack {
            ZStack {
                ForEach(overlayPoints) { point in
                    Circle()
                        .fill(.white)
                        .frame(width: 5, height: 5)
                        .position(x: point.location.x, y: point.location.y)
                        .tag(point.id)
                    
                }
                
                if(overlayPoints.contains{$0.finger == .wrist}) {
                    Circle()
                        .fill(.white.opacity(0.5))
                        .frame(width: 5, height: 5)
                        .position(x: overlayPoints.filter{$0.finger == .wrist}[0].location.x, y: overlayPoints.filter{$0.finger == .wrist}[0].location.y)
                }
            }
            ZStack {
                if(!overlayPoints.isEmpty) {
                    
                    ForEach(FingerType.allCases.filter { $0.rawValue != "wrist"}, id:\.self) { type in
                        Path { path in
                            
                            let points = overlayPoints.filter { $0.finger == type }
                            
                            let wristPoint = overlayPoints.filter{$0.finger == .wrist}
                            
                            if(!points.isEmpty) {
                                path.move(to: wristPoint.isEmpty  ?  points[0].location : wristPoint[0].location)
                                
                                for point in points.reversed() {
                                    path.addLine(to: point.location)
                                }
                                
                                
                            }
                            
                        }
                       
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.25)]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 2, dash: [5]))
                        
                    }
                }
                
            }
            
        }
    }
}

