//
//  MaincameraVC  extension.swift
//  FacePass
//
//  Created by Waseem Akram on 29/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

//TODO: make detection part to run only one time

import UIKit
import AVFoundation
import FirebaseDatabase
import SDWebImage

extension MainCamDetectionViewController : AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if  (metadataObjects.first as? AVMetadataFaceObject) != nil {
            if !isfaceSquareActive {
                box.isHidden = false
            }
            
            let bounds = (metadataObjects.first as! AVMetadataFaceObject).bounds
            let x = (self.view.frame.width * ( bounds.origin.x) )-50
            let height = (self.view.frame.height * bounds.height)
            let y =  ((bounds.origin.y) * self.view.frame.height)
            let width = view.frame.width * (bounds.width*2)
            box.frame =  CGRect(x:x, y: y, width: width, height:height )
            box.backgroundColor = FPColors.green
            box.alpha = 0.3
            box.layer.cornerRadius = 5
            
        }else {
            box.isHidden = true
            isfaceSquareActive = false
        }
        
        
        if isDetectionMode {
            self.pinAlert.isHidden = true
            print("detecting face")
            startFaceDetection()
            
           
            
        }else if isRecognitionMode {
           
            print("recognizing face")
            isRecognitionMode = false
            isPicCaptured = false
            outputImages = []
            capturePhoto()
            DispatchQueue.global().async {
                while true {
                    if self.isPicCaptured {
                        self.startRecognition()
                        break
                    }
                }

            }
        }
        
    }//metadataOutput
    
    func startFaceDetection(){
        if !isDetectionPicCaptured {
            if isPicCaptured{
                capturePhoto()
                isPicCaptured = false
            }
                
        }else {
            isDetectionMode = false
            presentNewface()
        }
        
    }
    

    
    func startRecognition(){
        let alert = UIAlertController(title: "Scanning your Face", message: "Please wait", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let url = URL(string: FPValues.urls.recognize)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("contentType", forHTTPHeaderField: "Content-Type")
        print(outputImages)
        request.httpBody = UIImageJPEGRepresentation(outputImages.first!, 1)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            alert.dismiss(animated: true, completion: nil)
            do {
                let dict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                print(dict)
                DispatchQueue.main.async {
                    if (dict["recognized"] as! Bool ) == false {
                            let vc = RecognizeErrorViewController()
                            vc.delegate = self
                            self.present(vc, animated: true, completion: {
                                return
                            })
                    }else{
                        print( dict["ID"] as! Int, dict["confidence"] as! Double)
                        self.presentConfirmFace(UID: (dict["ID"] as! Int))
                    }
                    
                   
                }
            }catch {
                print("cannot convert to json")
            }
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                self.outputImages = []
            })
            
            
        }).resume()
        
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error)
            return
        }
        
        if let sampleBuffer = photoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
            
            if let image = UIImage(data: dataImage) {
                outputImages.append(image)
                isPicCaptured = true
            }
            
            if isDetectionMode {
                if outputImages.count == 7 {
                    isDetectionMode = false
                    print("7",outputImages.count)
                    makeAlert(as: FPValues.alertMessages.second)
                }else if outputImages.count == 14 {
                    isDetectionMode = false
                    print("14",outputImages.count)
                    makeAlert(as: FPValues.alertMessages.third)
                }else if outputImages.count == 22 {
                    isDetectionMode = false
                    print("22",outputImages.count)
                    makeAlert(as: FPValues.alertMessages.four)
                }else if outputImages.count == 30{
                    print("30",outputImages.count)
                    isDetectionPicCaptured = true
                }
                
            }
            
        }
    }//photoOutput
    
    func presentNewface(){
        DispatchQueue.main.async {
            let vc = NewFaceViewController()
            vc.profilePic.image = self.outputImages.first!
            vc.delegate = self
            vc.outputImages = self.outputImages
            self.outputImages = []
            self.isDetectionPicCaptured = false
            self.present(vc as UIViewController, animated: true, completion: {
                
            })
        }
    }
    
    func presentConfirmFace(UID:Int){
        self.ref?.child("\(UID)").observeSingleEvent(of:DataEventType.value) { (datasnapshot) in
            let dict = datasnapshot.value as! [String:AnyObject]
            let vc = ConfirmFaceViewController()
            vc.UID = UID
            vc.profImgURl = dict["profileImgUrl"] as! String
            vc.usernameLabel.text = (dict["username"] as? String)!
            vc.usernameLabel.isHidden = !(dict["isUsernamePublic"] as? Bool)!
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}




