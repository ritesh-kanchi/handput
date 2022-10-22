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
        
        var fingerTips: [CGPoint] = []
        
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
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbTIP, type: .tip))
                }
                if let thumbIP = points[.thumbIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbIP, type: .ip))
                }
                if let thumbMP = points[.thumbMP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbMP, type: .mp))
                }
                if let thumbCMC = points[.thumbCMC] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: thumbCMC, type: .cmc))
                }
                
                if let indexTIP = points[.indexTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexTIP, type: .tip))
                }
                if let indexDIP = points[.indexDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexDIP, type: .dip))
                }
                if let indexPIP = points[.indexPIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexPIP, type: .pip))
                }
                if let indexMCP = points[.indexMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: indexMCP, type: .mcp))
                }
                
                if let middleTIP = points[.middleTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middleTIP, type: .tip))
                }
                if let middleDIP = points[.middleDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middleDIP, type: .dip))
                }
                if let middlePIP = points[.middlePIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middlePIP, type: .pip))
                }
                if let middleMCP = points[.middleMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: middleMCP, type: .mcp))
                }
                
                if let ringTIP = points[.ringTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringTIP, type: .tip))
                }
                if let ringDIP = points[.ringDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringDIP, type: .dip))
                }
                if let ringPIP = points[.ringPIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringPIP, type: .pip))
                }
                if let ringMCP = points[.ringMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: ringMCP, type: .mcp))
                }
                
                if let littleTIP = points[.littleTip] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littleTIP, type: .tip))
                }
                if let littleDIP = points[.littleDIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littleDIP, type: .dip))
                }
                if let littlePIP = points[.littlePIP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littlePIP, type: .pip))
                }
                if let littleMCP = points[.littleMCP] {
                    recognizedPoints.append(FingerJointPoint(recognizedPoint: littleMCP, type: .mcp))
                }
                
                
            }
            
            // 3
            fingerTips = recognizedPoints.filter {
                // Ignore low confidence points.
                $0.recognizedPoint.confidence > 0.9
            }
            .map {
                // 4
                CGPoint(x: $0.recognizedPoint.location.x, y: 1 - $0.recognizedPoint.location.y)
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
        request.maximumHandCount = 2
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
    
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    func processPoints(_ fingerTips: [CGPoint]) {
        // 2
        let convertedPoints = fingerTips.map {
            self.preview.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        
        // 3
        pointsProcessorHandler?(convertedPoints)
    }
    
    
    
}


struct FingerJointPoint {
    var recognizedPoint: VNRecognizedPoint
    var type: JointType
}

enum JointType {
    case tip
    case dip
    case pip
    case mcp
    case ip
    case cmc
    case mp
}
