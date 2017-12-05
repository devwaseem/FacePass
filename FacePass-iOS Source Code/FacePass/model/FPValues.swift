//
//  FPValues.swift
//  FacePass
//
//  Created by Waseem Akram on 30/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit

class FPValues {
    class urls {
        private static var host = "https://facepass2.herokuapp.com"  //"http://192.168.43.145:5000" //"https://facepass2.herokuapp.com/"   //"http://192.168.1.2:5000"
        static var storeFace = "\(host)/storeFace/img/id/"
        static var detectFace = "\(host)/detectFaces/id/"
        static var recognize = "\(host)/recognize/"
        static var train = "\(host)/train/"
        static var getUID = "\(host)/getUID/"
    }
    
    class alertMessages {
        static var first = "Hello, Wonderful! Please look at the camera. stay normal and don’t smile."
        static var second = "Remain looking at the camera but please smile this time."
        static var third = "Slowly tilt your face to the left"
        static var four = "Slowly tilt your face to the right."
    }
    
}
