//
//  BarCodeViewController.swift
//  Insapp
//
//  Created by Guillaume Courtet on 30/01/2017.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//


import UIKit
import AVFoundation

class CameraView: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        get {
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
}

class BarCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var parentView: UserViewController!
    
    @IBOutlet weak var cameraViewCanvas: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var cameraView: CameraView?
    var codeFrameView: UIView?
    
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraView = CameraView()
        self.cameraView?.frame = self.cameraViewCanvas.frame
        self.cameraViewCanvas.addSubview(cameraView!)
        
        
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        if (videoDevice != nil) {
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!)
            
            if (videoDeviceInput != nil) {
                if (session.canAddInput(videoDeviceInput!)) {
                    session.addInput(videoDeviceInput!)
                }
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                
                metadataOutput.metadataObjectTypes = [
                    AVMetadataObject.ObjectType.code128
                ]
                
                
                session.sessionPreset = AVCaptureSession.Preset.vga640x480
                let scanRectTransformed = CGRect(x: 0.4, y: 0.0, width: 0.2, height: 1.0)
                metadataOutput.rectOfInterest = scanRectTransformed
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
            
            if(videoDevice!.isFocusModeSupported(.continuousAutoFocus)) {
                try! videoDevice!.lockForConfiguration()
                videoDevice!.focusMode = .continuousAutoFocus
                videoDevice!.unlockForConfiguration()
            }
        }
        
        session.commitConfiguration()
        
        self.cameraView?.layer.session = session
        self.cameraView?.layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraView?.layer.connection?.videoOrientation = .portrait
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            self.session.startRunning()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cameraView?.layer.connection?.videoOrientation = .portrait
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if (metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject) {
            
            self.session.stopRunning()
            let scan = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            
            let alertController = UIAlertController(title: "Code barre scanné ✌🏼", message: scan.stringValue, preferredStyle: .alert)
            
            let cancelHandler = { (action:UIAlertAction!) -> Void in
                UserDefaults.standard.set(scan.stringValue, forKey: kBarCodeAmicalistCard)
                self.dismiss(animated: true, completion: nil)
                
                return
            }
            
            let rescanHandler = { (action:UIAlertAction!) -> Void in
                self.session.startRunning()
                return
            }
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: cancelHandler))
            alertController.addAction(UIAlertAction(title: "Re-Scanner", style: .cancel, handler: rescanHandler))
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

