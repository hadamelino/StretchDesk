//
//  CameraService.swift
//  StretchDesk
//
//  Created by Hada Melino on 09/02/24.
//

import AVFoundation
import Vision
import Foundation
import UIKit
import os.log

enum ActionType: String {
    case wristShake
    case wristCirle
    case background
}

enum DetectionOutput {
    case actionDetected(ActionType)
    case handsNotInframe
    case detectingAction
}

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.main.orientation
        }
        return orientation
    }
    
    private let captureSession = AVCaptureSession()
    
    private var addToPreviewStream: ((CIImage) -> Void)?
    private var addToOutputStream: ((DetectionOutput) -> Void)?
        
    lazy var outputStream: AsyncStream<DetectionOutput> = {
        AsyncStream { continuation in
            addToOutputStream = { detectionOutput in
                continuation.yield(detectionOutput)
            }
        }
    }()
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                continuation.yield(ciImage)
            }
        }
    }()
    
    lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        return request
    }()
    
    private var needToDetectActions: Bool = true
    private var queue: [MLMultiArray] = []
    private let queueSize: Int = 150 // the same as detection window = 5s
    
    private func configureSession() {
        captureSession.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            fatalError("The device does not have a front camera")
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput)
        else {
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoOutputQueue"))
        
        guard captureSession.canAddOutput(videoOutput) else { return }
        
        captureSession.addOutput(videoOutput)
        
        captureSession.commitConfiguration()
        
    }
    
    func start() async {
        guard await isAuthorized else { return }
        configureSession()
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = true
        }
        
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }
        
        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        do {
            try imageRequestHandler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first else {
                needToDetectActions = true
                if !queue.isEmpty {
                    addToOutputStream?(.handsNotInframe)
                }
                
                queue.removeAll()
                return
            }
            
            if needToDetectActions {
                addToOutputStream?(.detectingAction)
            }
            
            // No need to skip one frame because the camera already in 30 FPS, and the model was trained in 30 FPS
            let poseMultiArray = try observation.keypointsMultiArray()
            
            queue.append(poseMultiArray)

            if queue.count == queueSize {
                let poses = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
                let input = WristStretchActionClassifierInput(poses: poses)
                let model = try WristStretchActionClassifier(configuration: .init())
                let prediction = try model.prediction(input: input)
                
                let label = prediction.label
                
                // Remove after the queueSize is fulfilled to reset the detection from 0s
                queue.removeAll()

                guard let confidence = prediction.labelProbabilities[label] else { return }
                
                if confidence > 0.8 {
                    addToOutputStream?(.actionDetected(transformPredictionLabel(outputLabel: label)))
                    needToDetectActions = false
                }
            }
        } catch {
            print("Cant perform hand pose request")
        }
        
        
    }
    
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }
    
    private func transformPredictionLabel(outputLabel: String) -> ActionType {
        if outputLabel == "DrawCirclesWrist" {
            return .wristCirle
        } else if outputLabel == "WristShake" {
            return .wristShake
        } else {
            return .background
        }
    }
    
}

fileprivate extension UIScreen {

    var orientation: UIDeviceOrientation {
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        if point == CGPoint.zero {
            return .portrait
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight //.landscapeLeft
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft //.landscapeRight
        } else {
            return .unknown
        }
    }
}


