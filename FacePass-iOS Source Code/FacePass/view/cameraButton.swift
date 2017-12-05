//
//  cameraButton.swift
//  FacePass
//
//  Created by Waseem Akram on 29/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class cameraButton:UIView {
    
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        self.addSubview(button)
       
        button <- [
            Center(),
            Size(90).like(self)
        ]
        self.clipsToBounds = true
        setupDefaultMode()
    }
    
    func setupDefaultMode(){
        button.setImage(#imageLiteral(resourceName: "Circle"), for: .normal)
        button.backgroundColor = FPColors.blue
    }
    
    func setupOkMode(){
        button.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        button.backgroundColor = FPColors.green
    }
    
    
   
    
    
}
