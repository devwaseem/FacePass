//
//  FPTextField.swift
//  FacePass
//
//  Created by Waseem Akram on 27/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class FPTextField:UIView {

    let textfield = UITextField()
    let line = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.addSubviews(views: [textfield,line])
        line.backgroundColor = FPColors.blue
        textfield.borderStyle = .none
        textfield.placeholder = "Your name"
        textfield.textAlignment = .center
        textfield.textColor = FPColors.blue
        
        textfield <- [
        Top(),
        Left(),
        Right(),
        Bottom(-5)
        ]
        
        line <- [
        Top().to(textfield,.bottom),
        Left(),
        Right(),
        Height(2),
        ]
    }

}
