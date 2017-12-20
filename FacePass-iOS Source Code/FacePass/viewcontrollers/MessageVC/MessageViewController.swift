//
//  MessageViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 27/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy
import ISEmojiView
import SDWebImage
import FirebaseDatabase

class MessageViewController: UIViewController,UITextFieldDelegate{

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var delegate:ConfirmFaceViewController?
    var UID = ""
    var profImgUrl = ""
    
    var msgs = [Messages]()
    
    var isEmojiMode = false
    
    let TopBar:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 59/255, alpha: 1)
        return view
    }()
    
    let backButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Wback"), for: .normal)
        return button
    }()

    let profilePic = UIImageView()
    
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 10)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    let msgBox = FPMsgBox()
     let emojiview = ISEmojiView()
    
    
    let msgsCollection:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionview.register(messageCell.self, forCellWithReuseIdentifier: "MSG")
        collectionview.allowsSelection = false
        collectionview.backgroundColor = UIColor.white
        return collectionview
    }()
    
    
    
    override func viewDidLoad() {
        self.view.addSubviews(views: [TopBar,msgBox,msgsCollection])
        TopBar.addSubviews(views: [backButton,profilePic,usernameLabel])
        setupConstraints()
        msgsCollection.delegate = self
        msgsCollection.dataSource = self
        msgBox.emojiButton.addTarget(self, action: #selector(self.openEmojiKeyboard(sender:)), for: .touchUpInside)
        emojiview.delegate = self
        emojiview.isShowPopPreview = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        msgBox.msgField.delegate = self
        
        backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        profilePic.image = #imageLiteral(resourceName: "prof-ph")
        profilePic.clipsToBounds = true
        msgBox.layer.borderColor = FPColors.gray.withAlphaComponent(0.2).cgColor
        msgBox.layer.borderWidth = 2
        msgBox.msgField.returnKeyType = .send
        profilePic.contentMode = UIViewContentMode.scaleAspectFill
        profilePic.sd_setImage(with: URL(string: profImgUrl), placeholderImage: #imageLiteral(resourceName: "prof-ph"), options: SDWebImageOptions.highPriority, completed: nil)
        profilePic.sd_setShowActivityIndicatorView(true)
        profilePic.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.white)
        profilePic.layer.cornerRadius = profilePic.frame.height/2
    }
    
    let alert = UIAlertController(title: "Fetching Messages..", message: "please wait", preferredStyle: .alert)
    var ref:DatabaseReference?
    
    var tempDict:[Int:Messages] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        present(alert, animated: true, completion: nil)
        ref = Database.database().reference().child("users").child("\(UID)").child("messages")
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as! [String:AnyObject]
            for (key,_) in dict {
                if key != "count" {
                    let messagesDict = dict[key] as! [String:AnyObject]
                    self.tempDict[Int(key)!] = Messages(messageBody: messagesDict["message"] as! String, time: messagesDict["time"] as! String)
                }
            }
            let sortedKeys = Array(self.tempDict.keys).sorted()
            for i in sortedKeys {
                self.msgs.append(self.tempDict[i]!)
            }
            self.alert.dismiss(animated: true, completion: {
                self.msgsCollection.reloadData()
            })
        })
        
    }
    
    
    func setupConstraints(){
        
        TopBar <- [
            Top(),
            Left(),
            Right(),
            Height(80)
        ]
        
        backButton <- [
            Left(10),
            Top(20),
            Size(50)
        ]
        
        usernameLabel <- [
            Left(),
            Right(),
            Top(30),
            Height(25)
        ]
        
        profilePic <- [
            Right(10),
            Top().to(usernameLabel,.top),
            Size(40)
        ]
        
       setupMsgBoxPosition()
        
        msgsCollection <- [
            Top().to(TopBar),
            Left(),
            Right(),
            Bottom().to(msgBox,.top)
        
        ]
        
    }
    
    @objc func openEmojiKeyboard(sender:Any){
        if isEmojiMode {
             msgBox.msgField.inputView = nil
        }else{
             msgBox.msgField.inputView = emojiview
        }
        isEmojiMode = !isEmojiMode
        msgBox.msgField.becomeFirstResponder()
    }
    
    func setupMsgBoxPosition(pushUpBy:CGFloat = -2){
        msgBox.easy_clear()
        msgBox <- [
            Left(-2),
            Right(-2),
            Bottom(pushUpBy),
            Height(60)
        ]
    }
    
    
    @objc func sendMsg(sender: Any?){
        if let message = msgBox.msgField.text {
            if !(message.isEmpty || message == "" || message == " ") {
                let time = Date(timeIntervalSinceNow: 0).toString(format: "yyyy-MM-dd HH:mm:ss")!
                msgs.append(Messages(messageBody: message, time: time ))
                ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                    let dict = snapshot.value as! [String:AnyObject]
                    let count = dict["count"] as! Int
                    self.ref?.child("\(count)").setValue(["message":message,"time":time])
                    self.ref?.child("count").setValue(count+1)
                })
                msgsCollection.reloadData()
                scrolltobottom()
                self.view.endEditing(true)
                msgBox.msgField.text = ""
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        msgBox.msgField.inputView = nil
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMsg(sender: self)
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func backButtonPressed(sender:Any){
        dismiss(animated: true) {
             self.delegate?.dismiss(animated: true, completion: nil)
        }
    }
  
    
}











