//
//  CameraPreview.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModel
    
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 360, height: 360))
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        //  custom properties
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        camera.pointsProcessorHandler = pointsProcessorHandler
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }


}
