//
//  cameraRotateButton.swift
//  FacePass
//
//  Created by Waseem Akram on 30/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import EasyPeasy

class cameraRotateButton:UIView {
    
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
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.setImage(#imageLiteral(resourceName: "Rcamera"), for: .normal)
        button <- Edges()
    }
    
    
   
    
    
}
