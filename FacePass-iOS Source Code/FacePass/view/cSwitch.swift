//
//  cSwitch.swift
//  FacePass
//
//  Created by Waseem Akram on 27/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class customSwitch:UIView {
    
    let selectedView = UIView()
    private let buttonLayer = UIView()
    let PositiveButton = UIButton()
    let NegativeButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit(){
        self.addSubviews(views: [buttonLayer,selectedView])
        buttonLayer.addSubviews(views: [PositiveButton,NegativeButton])
        selectedView.backgroundColor = FPColors.green
        self.backgroundColor = FPColors.blue
        selectedView.frame = CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize(width: self.frame.width/2, height: self.frame.height))
        self.bringSubview(toFront: buttonLayer)
        
        buttonLayer.backgroundColor = UIColor.clear
        PositiveButton.backgroundColor = UIColor.clear
        NegativeButton.backgroundColor = UIColor.clear
        PositiveButton.setTitleColor(UIColor.white, for: .normal)
        NegativeButton.setTitleColor(UIColor.white, for: .normal)
        
        buttonLayer <- [Edges()]
        
        PositiveButton <- [
            Left().to(buttonLayer),
            CenterY(),
            Top().to(buttonLayer),
            Width(*0.5).like(self)
        ]
        
        NegativeButton <- [
            Right().to(buttonLayer),
            CenterY(),
            Top().to(buttonLayer),
            Width(*0.5).like(self)
        ]
    }
    
    
}
