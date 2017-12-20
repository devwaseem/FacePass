//
//  NewFaceViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 27/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy
import FirebaseDatabase
import FirebaseStorage
import Alamofire
import Lottie

class NewFaceViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var ref:DatabaseReference = Database.database().reference().child("users")
    
    var storageRef = Storage.storage().reference().child("userProfilesImgs")
    
    var delegate:NewFaceDelegate? = nil
    var fillAnimation = LOTAnimationView(name: "waterFill")
    var completedAnimation  = LOTAnimationView(name: "check1")
    
    let NextButton:FPButton = {
        let button = FPButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = FPColors.blue
        return button
    }()
    
    
    let backButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        return button
    }()
    
    let profilePic:UIImageView = {
        let imageview = UIImageView()
        imageview.image = #imageLiteral(resourceName: "prof-ph")
        imageview.clipsToBounds=true
        imageview.contentMode = UIViewContentMode.scaleAspectFill
        return imageview
    }()
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.text = "Save a new Face!"
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize + 5)
        label.textAlignment = .center
        //42 55 85
        label.textColor = UIColor.init(red: 42/255, green: 55/255, blue: 85/255, alpha: 1)
        return label
    }()
    
    let descriptionLabel:UITextView = {
        let label = UITextView()
        label.text = "We've detected a new face! \nWhat is the name of this person?"
        label.textColor = UIColor.init(red: 92/255, green: 102/255, blue: 125/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize:UIFont.labelFontSize - 2)
        label.isEditable = false
        label.isScrollEnabled = false
        label.textAlignment = .center
        return label
    }()
    
    let publicNameSwitch:UISwitch = {
        let Switch = UISwitch()
        Switch.thumbTintColor = FPColors.green
        Switch.tintColor = FPColors.blue
        Switch.onTintColor = FPColors.blue
        Switch.isEnabled = true
        Switch.isOn = true
        return Switch
    }()
    
    
    let fpTextField  = FPTextField(frame: CGRect.zero)
    var fpAlert = FPAlert(frame: CGRect.zero)
    
    let permissionLabel:UILabel = {
        let label = UILabel()
        label.text = "Allow your name to be seen for the public?"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.init(red: 42/255, green: 55/255, blue: 85/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize:UIFont.labelFontSize - 2)
        return label
    }()
    
    let permissionViewHolder = UIView()
    
    var outputImages = [UIImage]()
    
    let manager = Alamofire.SessionManager.default

    
    override func viewDidLoad() {
        print(outputImages.count)
        self.view.backgroundColor = UIColor.white
        self.view.addSubviews(views: [NextButton,backButton,profilePic,titleLabel,descriptionLabel,fpTextField,permissionViewHolder,fillAnimation,completedAnimation,fpAlert])
        permissionViewHolder.addSubviews(views: [permissionLabel,publicNameSwitch])
        NextButton.addTarget(self, action: #selector(self.next(sender:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.back(sender:)), for: .touchUpInside)
        hideHintBox()
        manager.session.configuration.timeoutIntervalForRequest = 120
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillAnimation.loopAnimation = true
        fillAnimation.isHidden = true
        completedAnimation.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        setupConstriants()
        self.view.layoutIfNeeded()
        NextButton.layer.cornerRadius = NextButton.frame.height/2
        profilePic.layer.cornerRadius = max(profilePic.frame.height,profilePic.frame.width)/2
        fpAlert.layer.cornerRadius = 10
    
        self.view.bringSubview(toFront: backButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupConstriants(){
        
        backButton <- [
            Left(20),
            Top(40),
            Size(30)
        ]
        
        titleLabel <- [
            Left().to(view,.left),
            Top().to(backButton,.top),
            Right().to(view,.right),
            Height(25)
        ]
        
        descriptionLabel <- [
            Top().to(titleLabel,.bottom),
            Left(50),
            Right(50),
            Height(descriptionLabel.intrinsicContentSize.height)
        ]
        
        profilePic <- [
            CenterX(),
            Top(20).to(descriptionLabel,.bottom),
            Size(self.view.frame.width/2)
            
        ]
        profilePic.layoutIfNeeded()
        
        fpTextField <- [
            Top(20).to(profilePic),
            Right(40),
            Left(40),
            Height(40)
        ]
        fpTextField.layoutIfNeeded()
        
        NextButton <- [
            Bottom(40).to(view),
            Left(65),
            Right(65),
            CenterX(),
            Height(50)
        ]
        NextButton.layoutIfNeeded()
        
        permissionViewHolder <- [
            Top().to(fpTextField),
            Bottom().to(NextButton),
            Left(),
            Right(),
        ]
        
        publicNameSwitch <- [
            CenterY(),
            Right(20),
            Size(50)
        ]
        
        
        permissionLabel <- [
            Top().to(publicNameSwitch,.top),
            Right().to(publicNameSwitch),
            Left(40),
            Height(50)
        ]
        
        
        fillAnimation <- [
            CenterX(),
            CenterY(),
            Width(500),
            Height(370)
        ]
        
        fpAlert <- [
            Left(20),
            Right(10),
            Bottom(10).to(fillAnimation,.top),
            Height(80)
        ]
        
        completedAnimation <- [
            CenterX(),
            CenterY(),
            Width(400),
            Height(400)
        ]
        
    }
    
    @objc func back(sender:Any){
        print("back")
        delegate?.set(mode: .detection)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func next(sender:Any){
        print("next")
        if ((self.fpTextField.textfield.text)?.isEmpty)! || (self.fpTextField.textfield.text) == "" || (self.fpTextField.textfield.text) == " " {
            fpTextField.shake()
        }else{
            startUpload()
        }
        
        
    }
    
    func startUpload(){
         self.toggleVisiblityOfUIElements(isDefault: false)
        DispatchQueue.main.async {
            self.fillAnimation.play()
            self.showHint(as: "Uploading your face to the cloud")
        }
        print("count",outputImages.count)
        var data:Parameters = [String:String]()
        data["name"] = self.fpTextField.textfield.text!
        for i in 0 ..< outputImages.count {
            data["img\(i)"] = (UIImageJPEGRepresentation(outputImages[i], 0.80)?.base64EncodedString())!
        }
        manager.request(TrueFaceAPI.url.enrollURL, method: .post, parameters: data, encoding: JSONEncoding.default, headers: TrueFaceAPI.header).responseJSON { (responseObj) in
            let json = responseObj.result.value as! [String:AnyObject]
            if  let data = json["data"] as? [String:AnyObject] {
            self.AddEnrollmentsToFacePassCollection(UID: data["enrollment_id"] as! String, completionHandler: {
                self.saveProfileImgToFireBase(withUID: data["enrollment_id"] as! String)
            })
            }else{
                self.self.showHint(as: "Something error occured..please try saving again!")
                self.fillAnimation.stop()
                self.toggleVisiblityOfUIElements(isDefault: true)
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                    self.hideHintBox()
                })
            }
            
        }
        
    }
    
    
    
    func saveProfileImgToFireBase(withUID UID:String){
        let ImgData:NSData = NSData(data:UIImageJPEGRepresentation(self.profilePic.image!, 0.90)!)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let uploadTask = self.storageRef.child("\(UID)/profileImg.jpg").putData(ImgData as Data, metadata: metaData)
        
        uploadTask.observe(StorageTaskStatus.failure, handler: { (snapshot) in
            guard let _ = snapshot.metadata else {
                self.showHint(as: "Error occured")
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (_) in
                        self.hideHintBox()
                    })
                }
                return
            }
        })//checking for failure
        
        uploadTask.observe(.progress, handler: { (snapshot) in
            //            self.changeAlertTexts(title: "Setting your Profile image", message: "\(Int((snapshot.progress?.fractionCompleted)! * 100.0))%")
            self.showHint(as: "Setting your Profile image")
        })
        
        uploadTask.observe(.success, handler: { (snapshot) in
            self.saveDataToFirebase(UID: UID, imgUrl: (snapshot.metadata?.downloadURL()?.absoluteString)!)
        })
    }
    
    func saveDataToFirebase(UID:String,imgUrl:String){
        showHint(as: "Uploading your data to cloud")
        let root = ref.child("\(UID)")
        DispatchQueue.main.async {
            root.child("username").setValue(self.fpTextField.textfield.text)
            root.child("isUsernamePublic").setValue(self.publicNameSwitch.isOn)
            root.child("profileImgUrl").setValue(imgUrl)
            root.child("messages").setValue(["count":0])
        }
        hideHintBox()
        fillAnimation.stop()
        fillAnimation.isHidden = true
        completedAnimation.isHidden = false
        completedAnimation.play { (_) in
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (_) in
                self.completedAnimation.isHidden = true
                self.delegate?.set(mode: .recognition)
                self.outputImages = []
                self.dismiss(animated: true, completion: nil)
            })
        }
       
        
        
        
    }
    
    func AddEnrollmentsToFacePassCollection(UID:String,completionHandler: @escaping () -> Void){
        manager.request(URL(string: "https://api.trueface.ai/v1/collection")!, method: .put, parameters: ["enrollment_id":UID,"collection_id":TrueFaceAPI.facePassCollectionID], encoding: JSONEncoding.default, headers: TrueFaceAPI.header).responseJSON { (responseObj) in
            print("enrollment",responseObj)
            let json = responseObj.result.value as! [String:AnyObject]
            if json["success"] as! Int == 1 {
                self.startTraining()
                completionHandler()
            }else{
                //error on adding enrollments to collection
                print("error")
                self.showHint(as: "Error on uploading your face")

            }
            
        }
    }
    
    func startTraining(){
        manager.request(URL(string: TrueFaceAPI.url.trainURL)!, method: .post, parameters: ["collection_id":TrueFaceAPI.facePassCollectionID], encoding: JSONEncoding.default, headers: TrueFaceAPI.header).responseJSON { (response) in
            print(response)
        }
    }
    
//    func changeAlertTexts(title:String,message:String){
//        DispatchQueue.main.async {
//            self.alert.title = title
//            self.alert.message = message
//        }
//    }
    
    func showHint(as message:String){
        fpAlert.setAlertMessage(As: message)
        UIView.animate(withDuration: 1) {
            self.fpAlert.transform = CGAffineTransform.identity
        }
    }
    
    func hideHintBox(){
        UIView.animate(withDuration: 0.4) {
            self.fpAlert.transform = CGAffineTransform(translationX: 0, y: -1500)
        }
    }
    
    func toggleVisiblityOfUIElements(isDefault bool:Bool){
        fillAnimation.isHidden = bool
        profilePic.isHidden = !bool
        backButton.isHidden = !bool
        titleLabel.isHidden = !bool
        descriptionLabel.isHidden = !bool
        publicNameSwitch.isHidden = !bool
        permissionLabel.isHidden = !bool
        fpTextField.isHidden = !bool
        NextButton.isHidden = !bool
    }
    
}


//    func obs(){
//
//
//        let task = URLSession.shared.dataTask(with: URL(string:FPValues.urls.getUID)!, completionHandler: { data,response,error in
//            guard error == nil else {
//                print(error!)
//                return
//            }
//            do {
//                let dict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
//                let UID = dict["newID"] as! Int
//
//                DispatchQueue.main.sync {
//                    let ImgData:NSData = NSData(data:UIImageJPEGRepresentation(self.profilePic.image!, 0.90)!)
//                    let metaData = StorageMetadata()
//                    metaData.contentType = "image/jpg"
//                    let uploadTask = self.storageRef.child("\(UID)/profileImg.jpg").putData(ImgData as Data, metadata: metaData)
//
//                    uploadTask.observe(StorageTaskStatus.failure, handler: { (snapshot) in
//                        guard let metadata = snapshot.metadata else {
//                            self.changeAlertTexts(title: "Error occured", message: "please try to save again")
//                            DispatchQueue.main.async {
//                                Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (_) in
//                                    self.alert.dismiss(animated: true, completion: nil)
//                                })
//                            }
//                            return
//                        }
//                    })//failure
//
//                    uploadTask.observe(.progress, handler: { (snapshot) in
//                        self.changeAlertTexts(title: "Uploading your information", message: "\(Int((snapshot.progress?.fractionCompleted)! * 100.0))%")
//                    })
//
//                    uploadTask.observe(.success, handler: { (snapshot) in
//                        self.saveDataToFirebase(UID: UID, imgUrl: (snapshot.metadata?.downloadURL()?.absoluteString)!)
//                    })
//
//
//                }
//
//                print(String.init(data: data!, encoding: String.Encoding.utf8)!)
//            }catch {
//
//            }
//
//        })
//        task.resume()
//
//
//    }



//    var requests = [URLRequest]()

//    func startUpload(UID:String){
//        createRequests(withUID: UID)
//        upload(request: requests[0], index: 0, UID: UID)
//    }



//    func createRequests(withUID UID:Int){
//        for image in outputImages {
//            let url = URL(string: "\(FPValues.urls.storeFace)\(UID)/")
//            var request = URLRequest(url: url!)
//            request.httpMethod = "POST"
//            request.setValue("contentType", forHTTPHeaderField: "Content-Type")
//            request.httpBody = UIImageJPEGRepresentation(image, 1)
//            requests.append(request)
//        }
//    }
//
//    private func upload( request:URLRequest,index:Int,UID:Int){
//        if index == outputImages.count - 1 {
//            self.changeAlertTexts(title: "Processing your face", message: "")
//            self.detectFaces(url: "\(FPValues.urls.detectFace)\(UID)/")
//            return
//        }
//        URLSession.shared.dataTask(with: request) { (data, _, error) in
//            guard error == nil else {
//            print(error!)
//            return
//            }
//            self.changeAlertTexts(title: "Uploading your face to cloud", message: "\(Int((index+1)*(100/30)))%")
//            print(String.init(data: data!, encoding: String.Encoding.utf8)!)
//            self.upload(request: self.requests[index+1], index: index+1, UID: UID)
//        }.resume()
//    }
//


//    private func detectFaces(url:String){
//        let url = URL(string: url)
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            guard error == nil else {
//                print(error!)
//                return
//            }
//            self.alert.dismiss(animated: true, completion: nil)
//            URLSession.shared.dataTask(with: URL(string: FPValues.urls.train)!).resume()
//            print(String.init(data: data!, encoding: String.Encoding.utf8)!)
//            self.delegate?.set(mode: .recognition)
//            self.dismiss(animated: true, completion: {self.outputImages = []})
//        }
//        task.resume()
//    }
