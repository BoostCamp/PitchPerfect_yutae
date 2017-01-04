//
//  PlaySoundsDialLayoutViewController.swift
//  PitchPerfect
//
//  Created by 최유태 on 2017. 1. 4..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class PlaySoundsDialLayoutViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dialLayout:AWCollectionViewDialLayout!
    var cell_height:CGFloat!
    var cell_width:CGFloat!
    
    let audioTypes = ["Snail", "Rabbit", "Chipmunk", "Vader", "Echo", "Reverb"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDialLayoutUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configureDialLayoutUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // DialLayout 초기화
    func configureDialLayoutUI(){
        print("Dial Layout Init")

        let currentDeviceWidth = UIScreen.main.bounds.size.width
        let currentDeviceHeight = UIScreen.main.bounds.size.height
        
        print("UIDevice Witdh : \(currentDeviceWidth)")
        
        self.cell_height = CGFloat(currentDeviceHeight/6)
        self.cell_width = CGFloat(currentDeviceHeight/6)
        
        self.dialLayout = AWCollectionViewDialLayout(raduis: 220.0, angularSpacing: 25.0, cellSize: CGSize.init(width: cell_height, height: cell_width), alignment: WheelAlignmentType.center, itemHeight: cell_height, xOffset: currentDeviceWidth/2)
        
        
        self.dialLayout.shouldSnap = true
        self.dialLayout.shouldFlip = true
        // Scroll 가리기
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.collectionViewLayout = self.dialLayout
        self.dialLayout.scrollDirection = .horizontal
        
        self.collectionView.reloadData()
//        DispatchQueue.main.async {
//            print("Reload")
//            
//        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.audioTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! dialLayoutCell
        // Image 삽입
        let audioType = self.audioTypes[indexPath.item]
        cell.iconImage.image = UIImage(named: audioType)
        return cell
    }
}
