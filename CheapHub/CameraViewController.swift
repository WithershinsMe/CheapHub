//
//  CameraViewController.swift
//  CheapHub
//
//  Created by GK on 2018/8/16.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: class {
    func cameraController(_ controller: CameraViewController, didCapture buffer: CMSampleBuffer)
}

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSession = AVCaptureSession()
    private lazy var cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    let overlayLayer = CALayer()
    
    weak var delegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAVSession()
        
        // begin the session
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        cameraLayer.frame = view.bounds
        overlayLayer.frame = view.bounds
    }
    
    private func setupAVSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        defer {
            captureSession.commitConfiguration()
        }
        
        // input
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera),
            captureSession.canAddInput(input)
            else {
                return
        }
        
        captureSession.addInput(input)
        
        // output
        let output = AVCaptureVideoDataOutput()
        
        guard captureSession.canAddOutput(output) else {
            return
        }
        
        captureSession.addOutput(output)
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        output.alwaysDiscardsLateVideoFrames = true
        
        // connection
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        // preview layer
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(cameraLayer)
        view.layer.addSublayer(overlayLayer)
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        sample = sampleBuffer
    }
    
    // FIXME: Test
    
    var sample: CMSampleBuffer?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let sample = sample {
            delegate?.cameraController(self, didCapture: sample)
        }
    }
}

