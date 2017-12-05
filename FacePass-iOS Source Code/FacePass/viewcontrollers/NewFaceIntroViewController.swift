//
//  NewFaceIntoViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 03/10/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class NewFaceIntroViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var delegate:RecognizeErrorViewController? 
    
    let startButton:FPButton = {
        let button = FPButton()
        button.setTitle("Get Started", for: .normal)
        return button
    }()
    
    let knowButton:FPButton = {
        let button = FPButton(frame: CGRect.zero)
        button.setTitle("Know more", for: .normal)
        button.backgroundColor = UIColor(white: 1, alpha: 0.3)
        button.layer.shadowOpacity = 1
        return button
    }()
    
    let inCircle:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    let outCircle:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize + 5)
        label.textColor = UIColor.white
        return label
    }()
    
    let subtitlelabel:UITextView = {
        let label = UITextView()
        label.textContainer.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.isScrollEnabled = false
        label.backgroundColor = UIColor.clear
        label.isEditable = false
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize - 2)
        return label
    }()
    
    let TextsHolder = UIView()
    
    let image = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews(views: [outCircle,TextsHolder,knowButton,startButton])
        outCircle.addSubview(inCircle)
        TextsHolder.addSubviews(views: [titleLabel,subtitlelabel])
        inCircle.addSubview(image)
        image.image = #imageLiteral(resourceName: "newface")
        knowButton.addTarget(self, action: #selector(self.knowMoreCLicked(sender:)), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(self.startCLicked(sender:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = FPColors.blue
        inCircle.backgroundColor = UIColor.white
        outCircle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        titleLabel.text = "We’ve detected a new face!"
        subtitlelabel.text = "We shall now begin the process of training & saving your face. This shouldn’t be too long."
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        outCircle.layer.cornerRadius = outCircle.frame.height/2
        inCircle.layer.cornerRadius = inCircle.frame.height/2
        knowButton.layer.cornerRadius = knowButton.frame.height/2
        startButton.layer.cornerRadius = startButton.frame.height/2
    }
  var isDefault = true
    
    func setupConstraints(){
        outCircle <- [
            CenterX(),
            Top(40).to(view, .top),
            Size(self.view.frame.height/2.3)
        ]
        
        inCircle <- [
            Center(),
            Size(*0.65).like(outCircle)
        ]
        
        image <- [
            Center(),
            Width(*0.55).like(inCircle),
            Height(*0.25).like(inCircle)
        ]
        
       knowButton <- [
            Bottom(10).to(startButton),
            Left(65),
            Right(65),
            CenterX(),
            Height(55)
        ]
        
        startButton <- [
            Left(65),
            Right(65),
            CenterX(),
            Height(55)
        ]
        
        subtitlelabel <- [
            Top(9).to(titleLabel, .bottom),
            Bottom().to(TextsHolder, .bottom),
            Left(20),
            Right(20)
        ]
        
        if isDefault {
            
            startButton <- Bottom(25).to(view)
            
            TextsHolder <- [
                Left(),
                Right(),
                Bottom().to(knowButton,.top),
                Top().to(outCircle,.bottom)
            ]
            
            titleLabel <- [
                Center(),
                Top(-50).to(TextsHolder, ReferenceAttribute.centerY),
                Height(titleLabel.intrinsicContentSize.height)
            ]
        }else {
             startButton <- Bottom(20).to(view)
            TextsHolder <- [
                Left(),
                Right(),
                Bottom().to(startButton,.top),
                Top().to(outCircle,.bottom)
            ]
            
            titleLabel <- [
                Center(),
                Top(5).to(TextsHolder, .top),
                Height(titleLabel.intrinsicContentSize.height - 4)
            ]
            subtitlelabel <- Top(3).to(titleLabel, .bottom)
        }
        
        
        
        
    }
    
    @objc func knowMoreCLicked(sender:Any){
//        knowButton.easy_clear()
        knowButton.isHidden = true
        view.subviews.forEach { (view) in
            view.removeConstraints(view.constraints)
        }
        isDefault=false
        viewDidLayoutSubviews()
        subtitlelabel.text = "We shall now begin the process of training & saving your face. This shouldn’t be too long.\nPlease capture your face in a well lit environment.\nYou will be showing your face in all angles & emotions- facing straight, smiling, normal, left-tilted and right-tilted so we could remember you better. "
        
      
    }
    
    @objc func startCLicked(sender:Any){
        
        dismiss(animated: true, completion: {
            self.delegate?.dismiss(animated: false, completion: nil)
        })
    }
    
}
