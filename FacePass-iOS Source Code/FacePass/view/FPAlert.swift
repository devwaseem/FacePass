//
//  FPAlert.swift
//  FacePass
//
//  Created by Waseem Akram on 30/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class FPAlert:UIView {
    
    private let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    private var blurEffectView:UIVisualEffectView?
    
    private let AlertLabel:UILabel = {
        let label = UILabel()
        label.text = "Alert message goes here.."
        label.textAlignment = .center
        label.numberOfLines=0
        label.textColor = UIColor.white
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.addSubviews(views: [blurEffectView!,AlertLabel])
        self.bringSubview(toFront: AlertLabel)
        setupConstraints()
        self.clipsToBounds = true
    }
    
    private func setupConstraints(){
        blurEffectView! <- Edges(0)
        AlertLabel <- [
        Left(20),
        Right(20),
        Top(5),
        Bottom(5)
        ]
    }
    
    public func setAlertMessage(As text:String){
        AlertLabel.text = text
    }
    
    
}
