//
//  AppDelegate.swift
//  FacePass
//
//  Created by Waseem Akram on 24/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import Foundation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if !UserDefaults.standard.bool(forKey: "isFirstTime") {
            UserDefaults.standard.set(true, forKey: "isFirstTime")
            self.window?.rootViewController = onBoardingViewController()
        }else{
            self.window?.rootViewController = MainCamDetectionViewController()
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    

   
}

