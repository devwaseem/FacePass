//
//  onBoardingViewController.swift
//  FacePass
//
//  Created by Waseem Akram on 24/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit

class onBoardingViewController: UIViewController {
   
    
    let NextButton:FPButton = {
        let button = FPButton()
        button.setTitle("Next", for: .normal)
        button.backgroundColor = FPColors.blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:UIFont.buttonFontSize)
        return button
    }()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    var onboardingIndex = 0
    
    let onboardingRes = [["Your face is your password","Scan the face of the people around you to view or post any comments"],
                         ["Know people around you","If the face doesn’t exist on our database already, kindly mention their name so we can remember your face"],
                         ["Scan a face to get started","When the camera opens upon tapping Get Started, tap on the scan button and you can see his/her feed or profile."]]
    
    let boards :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.register(onBoardingCell.self, forCellWithReuseIdentifier: "obcell")
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.isScrollEnabled = false
        return collection
    }()
    
    override func viewDidLoad() {
        boards.delegate = self
        boards.dataSource = self
        self.view.backgroundColor = UIColor.white
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubviews(views: [NextButton,boards])

        setupViewPositions()
        NextButton.addTarget(self, action: #selector(self.next(sender:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NextButton.layer.cornerRadius = NextButton.frame.height/2
       
    }
    

    
    func setupViewPositions(){

        NextButton.anchor( nil, left: nil, bottom: view.bottomAnchor, right:nil, topConstant: 0, leftConstant: 0, bottomConstant: 40, rightConstant: 0, widthConstant: self.view.frame.width - 120, heightConstant: 50)
        NextButton.anchorCenterXToSuperview()
        
        boards.anchor(view.topAnchor, left: view.leftAnchor, bottom: NextButton.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
       
    }
    

    @objc func next(sender:Any){
        let index = getCurrentPageIndex(boards)
        
        UIView.animate(withDuration: 0.5) {
            if index == 0 {
                self.boards.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .centeredHorizontally, animated: true)
                self.view.backgroundColor = FPColors.green
            }else if index == 1 {
                self.boards.scrollToItem(at: IndexPath.init(row: 2, section: 0), at: .centeredHorizontally, animated: true)
                self.view.backgroundColor = FPColors.blue
                self.NextButton.backgroundColor = FPColors.green
                self.NextButton.setTitle("Get Started", for: .normal)
            }else{
               let VC = MainCamDetectionViewController()
                VC.set(mode: .recognition)
                self.present(VC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func getCurrentPageIndex(_ collectionview: UICollectionView)->Int{
        let x = collectionview.contentOffset.x
        let w = collectionview.bounds.size.width
        let currentPage = Int(ceil(x/w))
        print(currentPage)
        return currentPage
    }
}

extension onBoardingViewController:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "obcell", for: indexPath) as! onBoardingCell
        var textColor = UIColor.black
        var image = UIImage()
        if indexPath.row == 0{
            cell.inCircle.backgroundColor = FPColors.green
            cell.outCircle.backgroundColor = FPColors.green.withAlphaComponent(0.2)
            image = #imageLiteral(resourceName: "Avatar")
        }else{
            cell.inCircle.backgroundColor = UIColor.white
            cell.outCircle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            textColor = UIColor.white
            image = #imageLiteral(resourceName: "Conversation")
        }
        if indexPath.row == 2 {
            image = #imageLiteral(resourceName: "Screens")
        }
        cell.setup(title: onboardingRes[indexPath.row][0], subtitle: onboardingRes[indexPath.row][1], textColor: textColor, image: image)
        cell.setupCorners()
        cell.layoutIfNeeded()
        if indexPath.row == 0 {
            cell.subtitle.textColor = UIColor.init(red: 92/255, green: 102/255, blue: 125/255, alpha: 1)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: boards.frame.width, height: boards.frame.height)
    }
    //92 102 125
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell  = cell as! onBoardingCell
        cell.setupCorners()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell  = cell as! onBoardingCell
        cell.setupCorners()
        
    }
    
    
    
}

