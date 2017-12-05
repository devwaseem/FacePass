//
//  FPMsgBox.swift
//  FacePass
//
//  Created by Waseem Akram on 28/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class FPMsgBox: UIView {

    let emojiButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "smiley"), for: .normal)
        return button
    }()
    
    let msgField:UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.placeholder = "Type your message here.."
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    func commonInit(){
        self.addSubviews(views: [emojiButton,msgField])
        msgField.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        msgField.clearButtonMode = .unlessEditing
        emojiButton <- [
        Top(),
        Left(),
        Bottom(),
        Width(60)
        ]
        msgField <- [
            Left().to(emojiButton,.right),
            Right(),
            Top(),
            Bottom()
        ]
       
    }
    
    
    
    
}
