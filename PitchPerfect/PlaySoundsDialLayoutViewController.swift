//
//  PlaySoundsDialLayoutViewController.swift
//  PitchPerfect
//
//  Created by 최유태 on 2017. 1. 4..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class PlaySoundsDialLayoutViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var sharingButton: UIBarButtonItem!
    var deviceWidth = UIScreen.main.bounds.size.width
    var deviceHeight = UIScreen.main.bounds.size.height
    
    var currentDeviceWidth:CGFloat!
    var currentDeviceHeight:CGFloat!
    var radius: CGFloat!
    var angularSpacing: CGFloat!
    
    var dialLayout:AWCollectionViewDialLayout!
    var cell_height:CGFloat!
    var cell_width:CGFloat!
    
    let audioType = ["Stop", "Snail", "Rabbit", "Chipmunk", "Vader", "Echo", "Reverb"]
    
//    AVAudio
    var recordedAudioURL: URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var changedAudioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check iPad, iPhone Set Layout
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                print("Current UI Device iPad")
                angularSpacing = 50.0
                radius = 330.0
            default:
                angularSpacing = 30.0
                radius = 220.0
        }
        
        currentDeviceWidth = deviceWidth
        currentDeviceHeight = deviceHeight
        
        setupAudio()
//        if (currentDeviceWidth >
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDialLayoutUI()
        // Sharing Button init
        self.sharingButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 종료될때 현재 재생중인 음악 끄기.
        self.stopAudio()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 공유하기버튼 액션
    @IBAction func sharingButtonPressed(_ sender: Any) {
        switch (self.dialLayout.selectedItem) {
        case 0:
            self.stopAudio()
        case 1:
            self.sharePlaySound(rate:0.5)
        case 2:
            self.sharePlaySound(rate:1.5)
        case 3:
            self.sharePlaySound(pitch:1000)
        case 4:
            self.sharePlaySound(pitch:-1000)
        case 5:
            self.sharePlaySound(echo:true)
        case 6:
            self.sharePlaySound(reverb:true)
        default:
            self.stopAudio()
        }
        /*
        let docController = UIDocumentInteractionController(url: NSURL(fileURLWithPath: changedAudioFile.url.absoluteString ) as URL)
        docController.delegate = self;
        docController.presentOpenInMenu(from: UIScreen.main.bounds, in: self.view, animated: true)
         */
    }
    
    // 공유하고 후 Call Back VC 
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    // DialLayout 초기화
    func configureDialLayoutUI(){
        print("Dial Layout Init")
        self.dialLayout = nil
        
        self.cell_height = CGFloat(currentDeviceHeight/6)
        self.cell_width = CGFloat(currentDeviceHeight/6)
        
        print("UIDevice Witdh : \(currentDeviceWidth)")
        
        
        self.dialLayout = AWCollectionViewDialLayout(raduis: self.radius , angularSpacing: self.angularSpacing, cellSize: CGSize.init(width: cell_height, height: cell_width), alignment: WheelAlignmentType.center, itemHeight: cell_height, xOffset: currentDeviceWidth/2)
        
        
        self.dialLayout.shouldSnap = true
        self.dialLayout.shouldFlip = true
        // Scroll 가리기
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.collectionViewLayout = self.dialLayout
        self.dialLayout.scrollDirection = .horizontal
        
        self.collectionView.reloadData()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.audioType.count
    }
    
    // Scroll 끝났을 때 음악 재생.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //
        print("1 Selected : \(self.dialLayout.selectedItem)")
        
        switch (self.dialLayout.selectedItem) {
        case 0:
            self.stopAudio()
        case 1:
            self.playSound(rate:0.5)
        case 2:
            self.playSound(rate:1.5)
        case 3:
            self.playSound(pitch:1000)
        case 4:
            self.playSound(pitch: -1000)
        case 5:
            self.playSound(echo:true)
        case 6:
            self.playSound(reverb:true)
        default:
            self.playSound()
        }
        
        // UI라서 DispatQueue main 으로 관리 Sharing Button init
        DispatchQueue.main.async {
            if(self.dialLayout.selectedItem != 0) {
                self.sharingButton.isEnabled = true
                let image = UIImage(named: "Bg")
                let customView = UIImageView.init(image: image)
                self.collectionView.backgroundView = customView
                
                let selectedItem = self.dialLayout.selectedItem
                
                let tempIndexPath = IndexPath(item: selectedItem!, section: 0)
                
                let cell = self.collectionView.cellForItem(at: tempIndexPath) as! dialLayoutCell
                
                if(selectedItem == 0){
                    //            Stop
                } else if (selectedItem == 1){
                    cell.itemView.progress = Double(self.audioFile.length) / Double(self.audioFile.processingFormat.sampleRate) / 0.5
                } else if (selectedItem == 2){
                    cell.itemView.progress = Double(self.audioFile.length) / Double(self.audioFile.processingFormat.sampleRate) / 1.5
                } else {
                    cell.itemView.progress = Double(self.audioFile.length) / Double(self.audioFile.processingFormat.sampleRate)
                }
                cell.itemView.start()
                
                self.navigationItem.title = self.audioType[selectedItem!]
            }
        }
    }
    
    // Scroll 시작 시 음악 정지.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("Scroll Begin!!")
        self.stopAudio()
        
        // UI라서 DispatQueue main 으로 관리 Sharing Button init
        DispatchQueue.main.async {
            self.sharingButton.isEnabled = false
            
            let image = UIImage(named: "Stop")
            let customView = UIImageView.init(image: image)
            customView.alpha = 0.1
            
            /* Gradation
            let gradient = CAGradientLayer()
            gradient.frame = self.collectionView.frame
            gradient.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
            self.collectionView.layer.sublayers?.insert(gradient, at: 0)
            */
            let cells = self.collectionView.visibleCells
            for cell in cells {
                let c = cell as! dialLayoutCell
                c.itemView.resetAnimationCircle()

            }
            self.collectionView.backgroundView = customView
            self.navigationItem.title = "VOVO"
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("1 Clicked : \(self.audioType[indexPath.item])")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! dialLayoutCell
        // Image 삽입
        let audioType = self.audioType[indexPath.item]
        cell.itemView.coverImage = UIImage(named: audioType)
        return cell
    }
    
    //Orientations Change!
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("Change")
        if (UIDevice.current.orientation.isPortrait) {
            print("Portrait!")
            currentDeviceWidth = deviceWidth
            currentDeviceHeight = deviceHeight
        } else {
            currentDeviceWidth = deviceHeight
            currentDeviceHeight = deviceWidth
            
        }
        self.configureDialLayoutUI()
    }
}
