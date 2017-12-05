//
//  MessageVC + messageCollection.swift
//  FacePass
//
//  Created by Waseem Akram on 29/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit

extension MessageViewController:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return msgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MSG", for: indexPath) as! messageCell
        cell.setup(message:msgs[indexPath.row])
        cell.layer.cornerRadius = 5
        cell.backgroundColor = FPColors.messageViewColor
        
//        "yyyy-MM-dd HH:mm:ss"
    
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
    }
    func scrolltobottom(){
        let item = collectionView(msgsCollection, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath(item: item, section: 0)
        self.msgsCollection.scrollToItem(at: lastItemIndex as IndexPath, at: UICollectionViewScrollPosition.top, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: collectionView.frame.height / 4)
    }
    
    func getDate(from:String)->Date{
        return DateFormatter(format: "yyyy-MM-dd HH:mm:ss").date(from: from)!
    }
    
    
    
}











