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

class NewFaceViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var ref:DatabaseReference = Database.database().reference().child("users")
    
    var storageRef = Storage.storage().reference().child("userProfilesImgs")
    
    
    var delegate:NewFaceDelegate? = nil
    
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
    
    override func viewDidLoad() {
        print(outputImages.count)
        self.view.backgroundColor = UIColor.white
        self.view.addSubviews(views: [NextButton,backButton,profilePic,titleLabel,descriptionLabel,fpTextField,permissionViewHolder])
        permissionViewHolder.addSubviews(views: [permissionLabel,publicNameSwitch])
        NextButton.addTarget(self, action: #selector(self.next(sender:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.back(sender:)), for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        setupConstriants()
    }
    override func viewDidAppear(_ animated: Bool) {
        NextButton.layer.cornerRadius = NextButton.frame.height/2
        
        profilePic.layer.cornerRadius = max(profilePic.frame.height,profilePic.frame.width)/2
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
        
        fpTextField <- [
        Top(20).to(profilePic),
        Right(40),
        Left(40),
        Height(40)
        ]
        
        
        
       
        
      
        NextButton <- [
            Bottom(40).to(view),
            Left(65),
            Right(65),
            CenterX(),
            Height(50)
        ]
        
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
        
        
    }
    
    @objc func back(sender:Any){
        print("back")
        delegate?.set(mode: .detection)
        dismiss(animated: true, completion: nil)
    }
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    
    @objc func next(sender:Any){
        print("next")
        
        if ((self.fpTextField.textfield.text)?.isEmpty)! || (self.fpTextField.textfield.text) == "" || (self.fpTextField.textfield.text) == " " {
//            let alert = UIAlertController(title: "Please provide a name", message: "", preferredStyle: )
            fpTextField.shake()
        }else{
            present(alert, animated: true, completion: nil)
            
             startUpload()
        }
//        dismiss(animated: true, completion: nil)
       
    }
    
   
    
    func startUpload(){
        
        
        let task = URLSession.shared.dataTask(with: URL(string:FPValues.urls.getUID)!, completionHandler: { data,response,error in
            guard error == nil else {
                print(error!)
                return
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                let UID = dict["newID"] as! Int
//                var ImgData:Data?
                DispatchQueue.main.sync {
                    let ImgData:NSData = NSData(data:UIImageJPEGRepresentation(self.profilePic.image!, 0.75)!)
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpg"
                    let uploadTask = self.storageRef.child("\(UID)/profileImg.jpg").putData(ImgData as Data, metadata: metaData)
                    
                    uploadTask.observe(StorageTaskStatus.failure, handler: { (snapshot) in
                        guard let metadata = snapshot.metadata else {
                            self.changeAlertTexts(title: "Error occured", message: "please try to save again")
                            DispatchQueue.main.async {
                                Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (_) in
                                    self.alert.dismiss(animated: true, completion: nil)
                                })
                            }
                            return
                        }
                    })//failure
                    
                    uploadTask.observe(.progress, handler: { (snapshot) in
                        self.changeAlertTexts(title: "Uploading your information", message: "\(Int((snapshot.progress?.fractionCompleted)! * 100.0))%")
                    })
                    
                    uploadTask.observe(.success, handler: { (snapshot) in
                        self.startUploadingFace(UID: UID, imgUrl: (snapshot.metadata?.downloadURL()?.absoluteString)!)
                    })
                    
                    
                }
                
                print(String.init(data: data!, encoding: String.Encoding.utf8)!)
            }catch {
                
            }
            
        })
        task.resume()
        
       
    }
    
    

    
    func startUploadingFace(UID:Int,imgUrl:String){
        changeAlertTexts(title: "Uploading your face to cloud", message: "")
        let root = ref.child("\(UID)")
        DispatchQueue.main.async {
            root.child("username").setValue(self.fpTextField.textfield.text)
            root.child("isUsernamePublic").setValue(self.publicNameSwitch.isOn)
            root.child("profileImgUrl").setValue(imgUrl)
            root.child("messages").setValue(["count":0])
        }
        
        startUpload(UID:UID)
        
    }
    
    var requests = [URLRequest]()
    
    func startUpload(UID:Int){
        createRequests(withUID: UID)
        upload(request: requests[0], index: 0, UID: UID)
    }
    
    
    
    func createRequests(withUID UID:Int){
        for image in outputImages {
            let url = URL(string: "\(FPValues.urls.storeFace)\(UID)/")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("contentType", forHTTPHeaderField: "Content-Type")
            request.httpBody = UIImageJPEGRepresentation(image, 1)
            requests.append(request)
        }
    }
    
    private func upload( request:URLRequest,index:Int,UID:Int){
        if index == outputImages.count - 1 {
            self.changeAlertTexts(title: "Processing your face", message: "")
            self.detectFaces(url: "\(FPValues.urls.detectFace)\(UID)/")
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
            print(error!)
            return
            }
            self.changeAlertTexts(title: "Uploading your face to cloud", message: "\(Int((index+1)*(100/30)))%")
            print(String.init(data: data!, encoding: String.Encoding.utf8)!)
            self.upload(request: self.requests[index+1], index: index+1, UID: UID)
        }.resume()
    }
    

    
    private func detectFaces(url:String){
        let url = URL(string: url)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            self.alert.dismiss(animated: true, completion: nil)
            URLSession.shared.dataTask(with: URL(string: FPValues.urls.train)!).resume()
            print(String.init(data: data!, encoding: String.Encoding.utf8)!)
            self.delegate?.set(mode: .recognition)
            self.dismiss(animated: true, completion: {self.outputImages = []})
        }
        task.resume()
    }
    
    func changeAlertTexts(title:String,message:String){
        DispatchQueue.main.async {
            self.alert.title = title
            self.alert.message = message
        }
    }
    
    
}



