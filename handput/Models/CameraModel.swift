//
//  CameraModel.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import Foundation
import AVFoundation
import Vision

extension
CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        
        var fingerTips: [FingerJointPointCG] = []
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(fingerTips)
            }
        }
        
        
        
        // 1
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .up,
            options: [:]
        )
        
        do {
            // 2
            try handler.perform([handPoseRequest])
            
            // 3
            guard
                let results = handPoseRequest.results?.prefix(2),
                !results.isEmpty
            else {
                return
            }
            
            var recognizedPoints: [FingerJointPoint] = []
            
            try results.forEach { observation in
                // 1
                let points = try observation.recognizedPoints(.all)
                
                
                if let thumbTIP = points[.thumbTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbTIP, type: .tip, finger: .thumb))
                }
                if let thumbIP = points[.thumbIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbIP, type: .ip, finger: .thumb))
                }
                if let thumbMP = points[.thumbMP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbMP, type: .mp, finger: .thumb))
                }
                if let thumbCMC = points[.thumbCMC] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbCMC, type: .cmc, finger: .thumb))
                }
                
                if let indexTIP = points[.indexTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexTIP, type: .tip, finger: .index))
                }
                if let indexDIP = points[.indexDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexDIP, type: .dip, finger: .index))
                }
                if let indexPIP = points[.indexPIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexPIP, type: .pip, finger: .index))
                }
                if let indexMCP = points[.indexMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexMCP, type: .mcp, finger: .index))
                }
                
                if let middleTIP = points[.middleTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middleTIP, type: .tip, finger: .middle))
                }
                if let middleDIP = points[.middleDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middleDIP, type: .dip, finger: .middle))
                }
                if let middlePIP = points[.middlePIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middlePIP, type: .pip, finger: .middle))
                }
                if let middleMCP = points[.middleMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middleMCP, type: .mcp, finger: .middle))
                }
                
                if let ringTIP = points[.ringTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringTIP, type: .tip, finger: .ring))
                }
                if let ringDIP = points[.ringDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringDIP, type: .dip, finger: .ring))
                }
                if let ringPIP = points[.ringPIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringPIP, type: .pip, finger: .ring))
                }
                if let ringMCP = points[.ringMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringMCP, type: .mcp, finger: .ring))
                }
                
                if let littleTIP = points[.littleTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littleTIP, type: .tip, finger: .little))
                }
                if let littleDIP = points[.littleDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littleDIP, type: .dip, finger: .little))
                }
                if let littlePIP = points[.littlePIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littlePIP, type: .pip, finger: .little))
                }
                if let littleMCP = points[.littleMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littleMCP, type: .mcp, finger: .little))
                }
                
                if let wristPoint = points[.wrist] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: wristPoint, type: .wrist, finger: .wrist))
                }
                
                
            }
            
            // 3
            fingerTips = recognizedPoints.filter {
                // Ignore low confidence points.
                $0.recognizedPoint.confidence > 0.80
            }
            .map {
                // 4
                FingerJointPointCG(location:  CGPoint(x: $0.recognizedPoint.location.x, y: 1 - $0.recognizedPoint.location.y), type: $0.type, finger: $0.finger)
               
            }
            
            
            
        } catch {
            // 4
            self.session.stopRunning()
        }
    }
    
}




class CameraModel: NSObject, ObservableObject {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    @Published var output = AVCaptureVideoDataOutput()
    
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedOutput",
        qos: .userInteractive
    )
    
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        // 1
        let request = VNDetectHumanHandPoseRequest()
        
        // 2
        request.maximumHandCount = 1
        return request
    }()
    
    
    func Check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                
                if(status) {
                    self.setUp()
                }
                
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        
        do {
            
            self.session.beginConfiguration()
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            
            
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            if self.session.canAddOutput(self.output) {
                
                self.output.alwaysDiscardsLateVideoFrames = true
                self.output.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    var pointsProcessorHandler: (([FingerJointPointCG]) -> Void)?
    
    func processPoints(_ fingerTips: [FingerJointPointCG]) {
        // 2
        let convertedPoints = fingerTips.map {
            FingerJointPointCG(location:  self.preview.layerPointConverted(fromCaptureDevicePoint: $0.location), type: $0.type, finger: $0.finger)
        }
        
        // 3
        pointsProcessorHandler?(convertedPoints)
    }
    
    
    
}


struct FingerJointPoint {
    var recognizedPoint: VNRecognizedPoint
    var type: JointType
    var finger: FingerType
}

struct FingerJointPointCG: Identifiable {
    var id = UUID()
    var location: CGPoint
    var type: JointType
    var finger: FingerType
}


enum JointType {
    case tip
    case dip
    case pip
    case mcp
    case ip
    case cmc
    case mp
    case wrist
}

enum FingerType: String, CaseIterable {
    case thumb
    case index
    case middle
    case ring
    case little
    case wrist
}
