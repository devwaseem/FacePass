//
//  ConfirmFaceViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 27/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy
import SDWebImage

class ConfirmFaceViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var UID = 0
    var profImgURl = ""
    
    let NextButton:FPButton = {
        let button = FPButton()
        button.setTitle("Confirm", for: .normal)
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
        label.text = "Confirm Face"
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize + 5)
        label.textAlignment = .center
        //42 55 85
        label.textColor = UIColor.init(red: 42/255, green: 55/255, blue: 85/255, alpha: 1)
        return label
    }()
    
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 10)
        label.textColor = FPColors.blue
        label.textAlignment = .center
        return label
    }()
    
    
    let descriptionLabel:UITextView = {
        let label = UITextView()
        label.text = "Have we recognized the right person?"
        label.textColor = UIColor.init(red: 92/255, green: 102/255, blue: 125/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize:UIFont.labelFontSize - 2)
        label.isEditable = false
        label.isScrollEnabled = false
        label.textAlignment = .center
        return label
    }()
    
    
    
   
    override func viewDidLoad() {
        self.view.addSubviews(views: [NextButton,backButton,profilePic,titleLabel,descriptionLabel,usernameLabel])
        self.view.backgroundColor = UIColor.white
        NextButton.addTarget(self, action: #selector(self.next(sender:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.back(sender:)), for: .touchUpInside)
        
    }
    override func viewWillLayoutSubviews() {
        setupConstraints()
        profilePic.sd_setImage(with: URL(string: profImgURl), placeholderImage: #imageLiteral(resourceName: "prof-ph"), options: SDWebImageOptions.highPriority, completed: nil)
        profilePic.sd_setShowActivityIndicatorView(true)
        profilePic.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.white)
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        NextButton.layer.cornerRadius = NextButton.frame.height/2
        profilePic.layer.cornerRadius = max(profilePic.frame.height,profilePic.frame.width)/2
        self.view.bringSubview(toFront: backButton)
        
    }
    
    func setupConstraints(){
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
        
        usernameLabel <- [
        CenterX(),
        Top(50).to(profilePic,.bottom)
            
        ]
        
        NextButton <- [
            Bottom(40).to(view),
            Left(65),
            Right(65),
            CenterX(),
            Height(50)
        ]
    }
    
    @objc func back(sender:Any){
        print("back")
        dismiss(animated: true, completion: nil)
    }
    @objc func next(sender:Any){
       let vc = MessageViewController()
        vc.UID = self.UID
        vc.profImgUrl = self.profImgURl
        vc.delegate = self
        vc.usernameLabel.text = usernameLabel.text
        present(vc, animated: true, completion: nil)
    }
    
    func setProfile(name: String, image: UIImage) {
        usernameLabel.text = name
        profilePic.image = image
    }
    
} 
