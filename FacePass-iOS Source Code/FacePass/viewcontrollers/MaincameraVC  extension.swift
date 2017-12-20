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
import Alamofire

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
        
        
        if isTrainingModeActive {
            
            self.pinAlert.isHidden = true
            startFaceTraining()
            
        }else if isRecognitionMode {
            print("recognizing face")
            isRecognitionMode = false
            isPhotoCapturedAndSaved = false
            outputImages = []
            capturePhoto()
            DispatchQueue.global().async {
                //while is used because the photo capturing is aynchournous.. i.e, after sometime the photo was taken and saved(line 51).. at that time this block may be gone already. so (while) is used to stop or hold this block  until the photo is captured and saved correctly
                while true {
                    if self.isPhotoCapturedAndSaved {
                        self.startRecognition()
                        break
                    }
                }
                
            }
        }
        
    }//metadataOutput
    
    func startFaceTraining(){
        if isAllTrainingPicturesCaptured {
            isTrainingModeActive = false
            presentNewface()
        }else {
            if isPhotoCapturedAndSaved{
                capturePhoto()
                isPhotoCapturedAndSaved = false
            }
        }
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
                isPhotoCapturedAndSaved = true
            }
            
            if isTrainingModeActive {
                if outputImages.count == Int(maximumNumberOfPhotosToBeCaptured/4)+1 {
                    makeTrainingModeInactiveAndShowAlert(as: FPValues.alertMessages.second)
                }else if outputImages.count == Int(maximumNumberOfPhotosToBeCaptured/4) * 2 + 1 {
                    makeTrainingModeInactiveAndShowAlert(as: FPValues.alertMessages.third)
                }else if outputImages.count == Int(maximumNumberOfPhotosToBeCaptured/4) * 3 + 1 {
                    makeTrainingModeInactiveAndShowAlert(as: FPValues.alertMessages.four)
                }else if outputImages.count == maximumNumberOfPhotosToBeCaptured{
                    isAllTrainingPicturesCaptured = true
                }
                
            }
            
        }
    }//photoOutput
    
    private func makeTrainingModeInactiveAndShowAlert(as alertString:String){
        isTrainingModeActive = false
        showHint(as: alertString)
        print(outputImages.count)
    }
    
    func presentNewface(){
        DispatchQueue.main.async {
            let vc = NewFaceViewController()
            vc.profilePic.image = self.outputImages.first!
            vc.delegate = self
            vc.outputImages = self.outputImages
            self.outputImages = []
            self.isAllTrainingPicturesCaptured = false
            self.present(vc as UIViewController, animated: true, completion: {
            })
        }
    }
    
    func presentConfirmFace(UID:String){
        self.ref?.child("\(UID)").observeSingleEvent(of:DataEventType.value) { (datasnapshot) in
            guard let dict = datasnapshot.value as? [String:AnyObject] else { return }
            let vc = ConfirmFaceViewController()
            vc.UID = UID
            vc.profImgURl = dict["profileImgUrl"] as! String
            vc.usernameLabel.text = (dict["username"] as? String)!
            vc.usernameLabel.isHidden = !(dict["isUsernamePublic"] as? Bool)!
            self.faceAnimation.stop()
            self.faceAnimation.loopAnimation = false
            self.hideHintBox()
            self.faceAnimation.play(fromProgress: 0.5, toProgress: 0.9, withCompletion: { (_) in
                self.present(vc, animated: true, completion: {
                    self.camerabutton.isHidden = false
                    self.rotateCameraButton.isHidden = false
                    self.faceAnimation.stop()
                })
            })
            
        }
        
    }
    
 
    
    func startRecognition(){
        DispatchQueue.main.async {
            self.camerabutton.isHidden = true
            self.rotateCameraButton.isHidden = true
            self.faceAnimation.play(fromProgress: 0, toProgress: 0.5, withCompletion: nil)
            self.hideHintBox()
            self.showHint(as: "Scanning your Face 👀")
        }

        let url = URL(string: TrueFaceAPI.url.identifierURL)
        let params = ["img":UIImageJPEGRepresentation(outputImages.first!, 1)?.base64EncodedString() ?? "",
                      "collection_id":TrueFaceAPI.facePassCollectionID]
        AlamofireManager.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: TrueFaceAPI.header).responseJSON { (response) in
            print(response)
            let json = response.result.value as! [String:AnyObject]
            if (json["message"] as! String ) == "no face detected." {
                self.presentErrorScreen()
            }else{
                if let data = json["data"] as? NSArray {
                    let dict = data[0] as! [String:AnyObject]
                    if let UID = dict["key"] as? String {
                        print( UID, dict["confidence"] as! Double,dict["name"] as! String )
                        if dict["confidence"] as! Double > 0.90 {
                            print("detected")
                            DispatchQueue.main.async {
                                 self.presentConfirmFace(UID: UID)
                            }
                        }else{
                            self.presentErrorScreen()
                        }
                    }else{
                        //no entry,people or key available
                        print("no key available")
                        self.presentErrorScreen()
                    }
                    
                }else{
                    //no data available
                    print("no data available")
                    self.presentErrorScreen()
                }
                
            }
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                self.outputImages = []
                
            })
            
        }
    }
    
    func presentErrorScreen(){
        let vc = RecognizeErrorViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: {
            return
        })
    }
    
    func showAlertWithOkButton(withTitle title:String,message:String){
     let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okbutton = UIAlertAction(title: "ok", style: .default) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        self.present(alert, animated: true, completion: nil)
    }
}



