 //
//  MainCamDetectionViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 25/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import AVFoundation
import EasyPeasy
import FirebaseDatabase

 class MainCamDetectionViewController: UIViewController,NewFaceDelegate {

    var facecount = 0
    var captureSession:AVCaptureSession?
    var videoPreviewayer:AVCaptureVideoPreviewLayer?
    var photoOutput = AVCapturePhotoOutput()
//    var output: AVCaptureStillImageOutput!
    let metaDataOutput = AVCaptureMetadataOutput()
    var outputImages:[UIImage] = []
    var uploaded = false
    var vCount = 0
    var faceMode:faceCaptureMode = .none
    var currentCameraPosition = cameraMode.front
    let box = UIView()
    var isfaceSquareActive = true
//    var isImageCapturedForRecognition = false
    var isRecognitionMode = false
    var isDetectionMode = false
    var inputDevice:AVCaptureDeviceInput?
    let camerabutton = cameraButton.init(frame: CGRect.zero)
    var cameraPreview = UIView()
    
    var alert = FPAlert(frame: CGRect.zero)
    let rotateCameraButton = cameraRotateButton(frame: CGRect.zero)
    var usingFrontCamera = false
    let pinAlert:UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "pinAlert")
        return image
    }()
    
    var capMode:captureMode = captureMode.recognition
    
    var isPicCaptured = false
    
    var isDetectionPicCaptured = false
    
    var isFirstAlertShown = false
    
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        ref = Database.database().reference().child("users")
        set(mode: .recognition)
        self.view.backgroundColor = UIColor.black
        self.view.addSubviews(views: [cameraPreview,box,camerabutton,alert,rotateCameraButton,pinAlert])
        camerabutton.button.addTarget(self, action: #selector(cameraButtonClicked(sender:)), for: .touchUpInside)
        rotateCameraButton.button.addTarget(self, action: #selector(self.changeCamera(sender:)), for: .touchUpInside)
//        alert.setAlertMessage(As: "check")
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideAlert()
        setupConstraints()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                self.loadCamera()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        camerabutton.layer.cornerRadius = camerabutton.frame.height/2
        rotateCameraButton.layer.cornerRadius = rotateCameraButton.frame.height/2
        alert.layer.cornerRadius = 10
        if capMode == .detection {
            self.makeAlert(as: FPValues.alertMessages.first)
        }
       
        
        
    }
    
    
    
    func setupConstraints(){
        cameraPreview <- Edges()
        
        camerabutton <- [
        CenterX(),
        Bottom(50),
        Size(80)
        ]
        
        alert <- [
            Left(20),
            Right(10),
            Top(10).to(topLayoutGuide),
            Height(80)
        ]
        
        rotateCameraButton <- [
            CenterY().to(camerabutton,ReferenceAttribute.centerY),
            Size(*0.5).like(camerabutton),
            Left(15).to(camerabutton,.right)
            
        ]
        
        pinAlert <- [
//            Left(40),
//            Right(40),
            CenterX().to(camerabutton,ReferenceAttribute.centerX),
            Bottom().to(camerabutton,.top),
            Height(70),
            Width(self.view.frame.width - 50)
            
        ]
    }

    
    
    func captureFace(){
        facecount += 1
        capturePhoto()
    }
    
    func capturePhoto(){
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.__availablePreviewPhotoPixelFormatTypes.first
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        settings.isHighResolutionPhotoEnabled = false
        photoOutput.capturePhoto(with: settings, delegate: self )
    }
    
    func getFrontCamera() -> AVCaptureDevice?{
     return AVCaptureDevice.default(.builtInWideAngleCamera, for:AVMediaType.video, position: AVCaptureDevice.Position.front)!
    }
    
    func getBackCamera() -> AVCaptureDevice{
        return AVCaptureDevice.default(.builtInWideAngleCamera, for:AVMediaType.video, position: AVCaptureDevice.Position.back)!
    }
    func loadCamera() {
        var isFirst = false
        
        DispatchQueue.global().async {
            if(self.captureSession == nil){
                isFirst = true
                self.captureSession = AVCaptureSession()
                self.captureSession!.sessionPreset = AVCaptureSession.Preset.iFrame960x540
            }
            var error: NSError?
            var input: AVCaptureDeviceInput!
            

            let currentCaptureDevice = (self.usingFrontCamera ? self.getFrontCamera() : self.getBackCamera())
            
            do {
                input = try AVCaptureDeviceInput(device: currentCaptureDevice!)
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
            
            for i : AVCaptureDeviceInput in (self.captureSession?.inputs as! [AVCaptureDeviceInput]){
                self.captureSession?.removeInput(i)
            }
            
            for i : AVCaptureOutput in (self.captureSession?.outputs as! [AVCaptureOutput]){
                self.captureSession?.removeOutput(i)
            }

            if error == nil && self.captureSession!.canAddInput(input) {
                self.captureSession!.addInput(input)
            }
            self.metaDataOutput.connections.first?.videoOrientation = .portrait
            
            if (self.captureSession?.canAddOutput(self.metaDataOutput))! {
                self.captureSession?.addOutput(self.metaDataOutput)
                self.metaDataOutput.setMetadataObjectsDelegate(self , queue: DispatchQueue.main)
                self.metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            }else {
                print("Error: Couldn't add meta data output")
                
            }
            
            
            if (self.captureSession?.canAddOutput(self.photoOutput))! {
                self.captureSession?.addOutput(self.photoOutput)
            }else {
                print("Error: Couldn't add meta data output")
                return
            }
            
            DispatchQueue.main.async {
                if isFirst { //run this code only one time
                    self.videoPreviewayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                    self.videoPreviewayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.videoPreviewayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    self.videoPreviewayer?.frame = self.cameraPreview.layer.bounds
                    self.cameraPreview.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    self.cameraPreview.layer.addSublayer(self.videoPreviewayer!)
                     self.captureSession!.startRunning()
                }
            }
        }
   
    }
    
    
    @objc func changeCamera(sender:Any){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.bringSubview(toFront: camerabutton)
        self.usingFrontCamera = !self.usingFrontCamera
        self.loadCamera()
        self.box.frame.origin.x = -1000 //just to hide the box off screen
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                UIView.animate(withDuration: 0.5, animations: {
                    blurEffectView.alpha = 0
                }, completion: { (finished) in
                    blurEffectView.removeFromSuperview()
                })
                
            })
        }
    }
    

    
    @objc func cameraButtonClicked(sender:Any){
        if Reachability.isConnectedToNetwork() {
            isRecognitionMode = true
            if capMode == .recognition {
                
                isDetectionMode = false
                return
            }
            isDetectionMode = true
            isRecognitionMode = false
            hideAlert()
        }else{
            let alert = UIAlertController(title: "Internet connection not available ☹️", message: "Please enable internet connection to continue", preferredStyle: .alert)
            let okaction = UIAlertAction(title: "ok", style: .default, handler: { (_) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okaction)
            present(alert, animated: true, completion: nil)
        }
       
    }
    
    func set(mode: captureMode) {
        DispatchQueue.main.async {
            self.capMode = mode
            self.outputImages = []
            if self.capMode == .recognition {
                self.pinAlert.isHidden = true
                self.camerabutton.setupDefaultMode()
                
            }else{
                self.pinAlert.isHidden = false
                self.camerabutton.setupOkMode()
                self.isDetectionPicCaptured = false
            }
            
        }
    }
   
    func makeAlert(as message:String){
        alert.setAlertMessage(As: message)
        UIView.animate(withDuration: 1) {
            self.alert.transform = CGAffineTransform.identity
        }
    }
    
    func hideAlert(){
        UIView.animate(withDuration: 0.4) {
            self.alert.transform = CGAffineTransform(translationX: 0, y: -150)
        }
    }
 
   
    
}
