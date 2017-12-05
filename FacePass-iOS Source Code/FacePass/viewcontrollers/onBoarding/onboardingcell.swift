//
//  onboardingcell.swift
//  FacePass
//
//  Created by Waseem Akram on 25/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import Foundation
import UIKit
import EasyPeasy
class onBoardingCell:UICollectionViewCell {
    
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
    
    let title:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize + 5)
        label.textColor = UIColor.white
        return label
    }()
    
    let subtitle:UITextView = {
        let label = UITextView()
        label.textContainer.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.isScrollEnabled = false
        label.backgroundColor = UIColor.clear
        label.isEditable = false
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize - 2)
        return label
    }()
    
    let TextsHolder = UIView()
    
    let image = UIImageView()
    
    func setup(title:String,subtitle:String,textColor:UIColor,image:UIImage){
        contentView.addSubviews(views: [outCircle,TextsHolder])
        outCircle.addSubview(inCircle)
        self.image.image = image
        inCircle.addSubview(self.image)
        
        outCircle.anchor( contentView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 70, leftConstant:0, bottomConstant: 0, rightConstant: 0, widthConstant: 220, heightConstant: 220)
        outCircle.anchorCenterXToSuperview()
        
        inCircle.anchor( nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 140, heightConstant: 140)
        inCircle.anchorCenterSuperview()
        self.image.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 35, heightConstant: 35)
        self.image.anchorCenterSuperview()

        
        TextsHolder.addSubviews(views: [self.title,self.subtitle])
        
        self.title.text = title
        self.title.textColor = textColor
        self.subtitle.text = subtitle
        self.subtitle.textColor = textColor
        

        
        
        self.TextsHolder <- [
        Top().to(outCircle, ReferenceAttribute.bottom),
        Bottom().to(contentView, .bottom),
        Left().to(contentView, .left),
        Right().to(contentView, .right)
        ]
        self.title <- [
            Center(),
            Top(-50).to(TextsHolder, ReferenceAttribute.centerY),
            Height(self.title.intrinsicContentSize.height)
        ]
        
        self.subtitle <- [
            Top(10).to(self.title, .bottom),
            Bottom().to(TextsHolder, .bottom),
            Left(40),
            Right(40)
        ]

    }
    
    func setupCorners(){
        inCircle.layer.cornerRadius = inCircle.frame.width/2
        outCircle.layer.cornerRadius = outCircle.frame.width/2
    }
 
    override func prepareForReuse() {
         contentView.subviews.forEach({$0.removeFromSuperview()})
    }
  
}
