//
//  MSGCell.swift
//  FacePass
//
//  Created by Waseem Akram on 29/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class messageCell:UICollectionViewCell {
    
    let messageLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    let time = UILabel()
    
    func setup(message:Messages){
        self.addSubviews(views: [messageLabel,time])
        setupConstraints()
        messageLabel.text = message.messageBody
        time.text = Date.timeAgoSinceDate((message.time.toDate(format: "yyyy-MM-dd HH:mm:ss"))!, currentDate: Date.init(timeIntervalSinceNow: 0), numericDates: true)
        time.textColor = FPColors.gray.withAlphaComponent(0.5)
        
        
    }
    
    func setupConstraints() {
        messageLabel <- [
        Top(15),
        Left(25),
        Right(15),
        Bottom(30)
        ]
        
        time <- [
            Top(0).to(messageLabel,.bottom),
            Left(25),
            Right(15),
            Bottom(10)
        ]
        
    }
}
