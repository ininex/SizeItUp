//
//  cameraFrameProcessor.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 10/8/16.

// MODIFIED TO SATISFY iOS 10 SYNTAX

import Foundation
import AVFoundation
import GameplayKit
import UIKit

protocol cameraFrameProcessorDelegate {
    func frameProcessorDidFinishRankingMatchingProducts(bestFit:String, otherKeys:[String])
}

class cameraFrameProcessor: UIViewController {
    
    var delegate: cameraFrameProcessorDelegate?
    
    var shouldUseSingleFrameProcessing:Bool
    
    var singleFrame: UIImage!
    
    init(singleFrameMode: Bool) {
        self.shouldUseSingleFrameProcessing = singleFrameMode
        super.init(nibName: nil, bundle: nil)
        self.initAllNotificationCenters()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.cameraSession.stopRunning()
    }
    
    func initAllNotificationCenters(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProduct(notification:)), name: NSNotification.Name(rawValue: "UIImageFeatureMatchingKeypointsUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProduct(notification:)), name: NSNotification.Name(rawValue:"UIImageFeatureMatchingKeypointsWaiting"), object: nil)
    }
    var productName = "Recognizing..."
    var keypoints = [
        "Monster": 0,
        "Tropicana Oriange Juice": 0,
        "Red Bull": 0
    ]
    var productsAndKeys = [
        "Monster":"",
        "Tropicana Oriange Juice":"",
        "Red Bull":""
    ]
    var length = 0.0
    var height = 0.0
    var width = 0.0
    
    func updateProduct(notification: NSNotification) {
        
        guard notification.name._rawValue != "UIImageFeatureMatchingKeypointsWaiting" else{
            DispatchQueue.main.async {
                self.productNameLoader.text = "Length: ...,\r\nWidth: ..., \r\nHeight: ..."
            }
            return
        }
        
        if (notification.object as! UIImage).accessibilityIdentifier == "Monster" {
            self.keypoints["Monster"] = (notification.userInfo as! [String: Int])["keypoints"]!
        }
        
        if (notification.object as! UIImage).accessibilityIdentifier == "Tropicana Oriange Juice" {
            self.keypoints["Tropicana Oriange Juice"] = (notification.userInfo as! [String: Int])["keypoints"]!
        }
        
        if (notification.object as! UIImage).accessibilityIdentifier == "Red Bull" {
            self.keypoints["Red Bull"] = (notification.userInfo as! [String: Int])["keypoints"]!
        }
        
        print("sender is: \((notification.object as! UIImage).accessibilityIdentifier)")
        print("notification name is: \(notification.name._rawValue)")        
        
        var maxKeypointsCount = 0
        
        let allkeys = Array(self.keypoints.keys)
        
        for i in 0..<allkeys.count {
            if self.keypoints[allkeys[i]]! > maxKeypointsCount {
                maxKeypointsCount = self.keypoints[allkeys[i]]!
            }
        }
        
        let targetKey = (self.keypoints as NSDictionary).allKeys(for: maxKeypointsCount).first as! String
        let bestFit = self.keypoints[targetKey]
        self.productName = targetKey
        
        var otherKeys: [String] = []
        
        for eachKey in self.keypoints.keys {
            if eachKey != targetKey {
                otherKeys.append(eachKey)
            }
        }
        var otherKeysRandom: [String] = []
        
        if #available(iOS 9.0, *) {
            otherKeysRandom = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: otherKeys) as! [String]
        } else {
            // Fallback on earlier versions
            otherKeysRandom = otherKeys
        }
        
        self.delegate?.frameProcessorDidFinishRankingMatchingProducts(bestFit: targetKey, otherKeys: otherKeysRandom)
        
        DispatchQueue.main.async {
            //Product Name: \(self.productName),
            self.productNameLoader.text = "Length: \(self.length), \r\nWidth: \(self.width), \r\nHeight: \(self.height)"
        }
    }
    
    lazy var cameraSession: AVCaptureSession  = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium
        return session
    }()
    
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
    
    var proceededVideoViewer: UIImageView!
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResizeAspect
        return preview!
    }()
    
    lazy var debugMonitor: UITextView = {
       let textView = UITextView(frame: self.view.frame)
        textView.textColor = .yellow
        textView.font = UIFont.boldSystemFont(ofSize: 20.0)
        textView.backgroundColor = .clear
        textView.text = "Initializing..."
        textView.textAlignment = .center
        return textView
    }()
    
    lazy var productNameLoader: UITextView = {
        let textView = UITextView(frame: CGRect(x: 20.0, y: 30.0, width: self.view.frame.width - 40.0, height: 64.0))
        textView.textColor = UIColor(red: 90/255, green: 228/255, blue: 232/255, alpha: 1.0)
        textView.font = UIFont.boldSystemFont(ofSize: 16.0)
        textView.backgroundColor = .clear
        textView.text = "Initializing..."
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    override func viewDidLoad() {
        self.configInputAndOutput()
        self.view.backgroundColor = UIColor.black
        self.proceededVideoViewer = UIImageView(frame: self.view.frame)
        self.proceededVideoViewer.alpha = 0.5
        self.proceededVideoViewer.contentMode = .scaleAspectFit
        self.view.addSubview(self.proceededVideoViewer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layer.addSublayer(previewLayer)
        if self.shouldUseSingleFrameProcessing == false {
            cameraSession.startRunning()
            self.view.bringSubview(toFront: self.proceededVideoViewer)
            self.view.addSubview(self.productNameLoader)
        }else{
            let imageView = UIImageView(frame: self.view.frame)
            imageView.image = self.singleFrame
            OpenCVWrapper.feature2DRecognition(for: UIImage(named: "reference_product"), andOriginalImage: self.singleFrame)
            imageView.contentMode = .scaleAspectFit
            self.view.addSubview(imageView)
            self.view.addSubview(self.productNameLoader)
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldUseSingleFrameProcessing == false {
            self.toggleFlash()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if shouldUseSingleFrameProcessing == false {
            self.toggleFlash()
        }
    }
    
    func configInputAndOutput(){
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration() // 1
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput() // 2
            
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)] // 3
            
            dataOutput.alwaysDiscardsLateVideoFrames = true // 4
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration() //5
            
            let queue = DispatchQueue(label: "demo")
            dataOutput.setSampleBufferDelegate(self, queue: queue) // 7
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    func toggleFlash() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
}

extension cameraFrameProcessor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        guard sampleBuffer != nil else {
            return
        }
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer
        let image_CI = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer)
        let context = CIContext(options: nil)
        let image_CG = context.createCGImage(
            image_CI,
            from: CGRect(x: 0, y: 0, width:
                CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
                         height: CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        )
        
        let referenceImage_1 = UIImage(named: "reference_product")
        referenceImage_1?.accessibilityIdentifier = "Monster"
        OpenCVWrapper.feature2DRecognition(for: referenceImage_1, andOriginalImage: UIImage(cgImage: image_CG!))
        
        let referenceImage_2 = UIImage(named: "juice")
        referenceImage_2?.accessibilityIdentifier = "Tropicana Oriange Juice"
        OpenCVWrapper.feature2DRecognition(for: referenceImage_2, andOriginalImage: UIImage(cgImage: image_CG!))
        
        let referenceImage_3 = UIImage(named: "red_bull")
        referenceImage_3?.accessibilityIdentifier = "Red Bull"
        OpenCVWrapper.feature2DRecognition(for: referenceImage_3, andOriginalImage: UIImage(cgImage: image_CG!))
        
//        DispatchQueue.main.async {
//            self.proceededVideoViewer.image = image
//        }
        
//        print("did receive video frames... -> \(image)")
    }
}
