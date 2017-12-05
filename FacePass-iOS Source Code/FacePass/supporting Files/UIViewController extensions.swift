//
//  UIViewController extensions.swift
//  FacePass
//
//  Created by Waseem Akram on 08/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func getViewController(withIdentifier:String)->UIViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        return  storyboard.instantiateViewController(withIdentifier: withIdentifier)
    }
    
    //    func listFilesFromDocumentsFolder() -> [URL]?
    //    {
    //        let fileMngr = FileManager.default;
    //
    //        // Full path to documents directory
    //        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    //
    //        // List all contents of directory and return as [String] OR nil if failed
    //        return try? fileMngr.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
    //    }
    
}
