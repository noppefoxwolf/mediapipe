//
//  ViewController.swift
//
//  Created by Tomoya Hirano on 2020/01/09.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController2: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, TrackerDelegate {
    let camera = Camera()
    let displayLayer: AVSampleBufferDisplayLayer = .init()
    let tracker: HandTracker = HandTracker()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(displayLayer)
        camera.setSampleBufferDelegate(self)
        camera.start()
        tracker.startGraph()
        tracker.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayLayer.frame = view.bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        displayLayer.enqueue(sampleBuffer)
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        tracker.processVideoFrame(pixelBuffer)
    }
    
    func handTracker(_ handTracker: HandTracker!, didOutputLandmarks landmarks: [Landmark]!) {
        print(landmarks)
    }
    
    func handTracker(_ handTracker: HandTracker!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {
        var timing = CMSampleTimingInfo.invalid
        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: pixelBuffer,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: try! .init(imageBuffer: pixelBuffer),
                                           sampleTiming: &timing,
                                           sampleBufferOut: &sampleBuffer)
        displayLayer.enqueue(sampleBuffer!)
    }
}

class ViewController: UIViewController, ARSessionDelegate, TrackerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let tracker: HandTracker = HandTracker()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        tracker.startGraph()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let bgra = try! frame.capturedImage.toBGRA()
//        print(bgra)
        tracker.processVideoFrame(bgra)
    }
    
    func handTracker(_ handTracker: HandTracker!, didOutputLandmarks landmarks: [Landmark]!) {
        
    }
    
    func handTracker(_ handTracker: HandTracker!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {
        
    }
}


class Camera: NSObject {
    lazy var session: AVCaptureSession = .init()
    lazy var input: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device)
    lazy var device: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
    lazy var output: AVCaptureVideoDataOutput = .init()
    
    override init() {
        super.init()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        session.addInput(input)
        session.addOutput(output)
    }
    
    func setSampleBufferDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        output.setSampleBufferDelegate(delegate, queue: .main)
    }
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
}
