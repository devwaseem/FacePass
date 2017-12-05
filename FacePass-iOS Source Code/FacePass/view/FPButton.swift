//
//  FPButton.swift
//  FacePass
//
//  Created by Waseem Akram on 01/10/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit

class FPButton:UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = FPColors.green
        titleLabel?.font = UIFont.systemFont(ofSize:UIFont.buttonFontSize)
        layer.shadowOpacity = 0.45
        layer.shadowOffset = CGSize.init(width: 0, height: 10)
        layer.shadowRadius = 9
        layer.shadowColor = FPColors.shadowColor
    }
}
