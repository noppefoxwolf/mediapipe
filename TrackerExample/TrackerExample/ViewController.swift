//
//  ViewController.swift
//  Y2R
//
//  Created by Tomoya Hirano on 2020/01/09.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MyFramework

class ViewController: UIViewController, ARSessionDelegate, TrackerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let tracker: Tracker = Tracker()!
    
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
    
    func didReceived(_ landmarks: [Landmark]!) {
        print(landmarks)
    }
}

