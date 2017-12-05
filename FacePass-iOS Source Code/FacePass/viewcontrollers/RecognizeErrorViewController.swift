//
//  RecognizeErrorViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 26/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//
import Foundation
import UIKit
import EasyPeasy

class RecognizeErrorViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let retryButton:FPButton = {
        let button = FPButton()
        button.setTitle("Retry", for: .normal)
        return button
    }()
    
    let addFaceButton:FPButton = {
        let button = FPButton(frame: CGRect.zero)
        button.setTitle("Save as a new face", for: .normal)
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
    
    var delegate:NewFaceDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews(views: [outCircle,TextsHolder,retryButton,addFaceButton])
        outCircle.addSubview(inCircle)
        TextsHolder.addSubviews(views: [titleLabel,subtitlelabel])
        inCircle.addSubview(image)
        image.image = #imageLiteral(resourceName: "error")
       retryButton.addTarget(self, action: #selector(self.retryButtonClicked(sender:)), for: .touchUpInside)
        addFaceButton.addTarget(self, action: #selector(self.addNewFace(sender:)), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = FPColors.blue
        inCircle.backgroundColor = UIColor.white
        outCircle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        titleLabel.text = "Couldn’t recognize your face"
        subtitlelabel.text = "Please retry by scanning the face on a highly lit or bright environment. "
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        outCircle.layer.cornerRadius = outCircle.frame.height/2
        inCircle.layer.cornerRadius = inCircle.frame.height/2
        retryButton.layer.cornerRadius = retryButton.frame.height/2
        addFaceButton.layer.cornerRadius = addFaceButton.frame.height/2
        
    }

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
            Size(*0.22).like(inCircle)
        ]
        
        retryButton <- [
            Bottom(10).to(addFaceButton),
            Left(65),
            Right(65),
            CenterX(),
            Height(55)
        ]
        
        addFaceButton <- [
             Bottom(25).to(view),
             Left().to(retryButton,.left),
             Right().to(retryButton,.right),
             CenterX(),
             Height().like(retryButton)
        ]
        
        TextsHolder <- [
        Left(),
        Right(),
        Bottom().to(retryButton,.top),
        Top().to(outCircle,.bottom)
        ]
        
        titleLabel <- [
            Center(),
            Top(-50).to(TextsHolder, ReferenceAttribute.centerY),
            Height(titleLabel.intrinsicContentSize.height)
        ]
        
        subtitlelabel <- [
            Top(10).to(titleLabel, .bottom),
            Bottom().to(TextsHolder, .bottom),
            Left(40),
            Right(40)
        ]
        
    }
    
    @objc func retryButtonClicked(sender:Any){
         delegate?.set(mode: .recognition)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addNewFace(sender:Any){

        delegate?.set(mode: .detection)
        let vc = NewFaceIntroViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

   

}
