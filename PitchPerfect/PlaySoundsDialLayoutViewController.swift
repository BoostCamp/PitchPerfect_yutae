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
    
    var radius: CGFloat!
    var angularSpacing: CGFloat!
    
    var dialLayout:AWCollectionViewDialLayout!
    var cell_height:CGFloat!
    var cell_width:CGFloat!
    
    let audioType = ["Stop", "Turtle", "Rabbit", "Chipmunk", "Vader", "Echo", "Reverb", "Organ", "Drum"]
    let audioTypeDescription = ["STOP", "SLOW", "FAST", "LIGHT", "HEAVY", "ECHO", "REVERB", "ORGAN", "DRUM"]
//    AVAudio
    var recordedAudioURL: URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
//    For Share
    var changedAudioFile:AVAudioFile!
    
//    To be mixed
    var mixedAudioFile: AVAudioFile!
    var mixedPlayerNode: AVAudioPlayerNode!
    var mixedBuffer: AVAudioPCMBuffer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check iPad, iPhone Set Layout
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                print("Current UI Device iPad - Dial Layout Resize")
                self.angularSpacing = 50.0
                self.radius = 440.0
                self.cell_width = 200
                self.cell_height = CGFloat((200*1.3)+10.0)
            default:
                if(self.view.frame.width < 370){
                    print("Current UI Device < iPhone 6- Dial Layout Resize")
                    self.angularSpacing = 40.0
                    self.radius = 220.0
                    self.cell_width = 120
                    self.cell_height = CGFloat((120*1.3)+10.0)
                }
                else {
                    print("Current UI Device > iPhone 6 - Dial Layout Resize")
                    self.angularSpacing = 40.0
                    self.radius = 220.0
                    self.cell_width = 150
                    self.cell_height = CGFloat((150*1.3)+10.0)
                }
        }
        
        setupAudio()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDialLayoutUI()
        // Sharing Button init
        self.sharingButton.isEnabled = false
        
        // Add Observer orientation Changed !!
        NotificationCenter.default.addObserver(self, selector: #selector(PlaySoundsDialLayoutViewController.orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func orientationDidChange(notification: NSNotification) {
        print("orientationDidChange")
        // orientation Changed 일때 UI Reset
        self.configureDialLayoutUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 종료될때 Observer remove!!
        NotificationCenter.default.removeObserver(self)
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
            self.playSound(share: true, rate:0.5)
        case 2:
            self.playSound(share: true, rate:1.5)
        case 3:
            self.playSound(share: true, pitch:1000)
        case 4:
            self.playSound(share: true, pitch: -1000)
        case 5:
            self.playSound(share: true, echo:true)
        case 6:
            self.playSound(share: true, reverb:true)
        default:
            self.playSound(share: true, mixed:self.audioType[self.dialLayout.selectedItem])
        }
    }
    
    // 공유하고 후 Call Back VC 
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    // DialLayout 초기화
    func configureDialLayoutUI(){
        print("Dial Layout Init")
        
        print(self.view.frame.width)
        
        self.dialLayout = AWCollectionViewDialLayout(raduis: self.radius , angularSpacing: self.angularSpacing, cellSize: CGSize.init(width: self.cell_width, height: self.cell_height), alignment: WheelAlignmentType.center, itemHeight: cell_height, xOffset: self.view.frame.width/2)
        
        
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
            self.playSound(mixed:self.audioType[self.dialLayout.selectedItem])
        }
        
        // UI라서 DispatQueue main 으로 관리 Sharing Button init
        DispatchQueue.main.async {
            if(self.dialLayout.selectedItem != 0) {
                self.sharingButton.isEnabled = true
                
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
                
                self.navigationItem.title = self.audioType[selectedItem!].uppercased()
            }
        }
    }
    
    // Scroll 시작 시 음악 정지.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.stopAudio()
        
        // UI라서 DispatQueue main 으로 관리 Sharing Button init
        DispatchQueue.main.async {
            self.sharingButton.isEnabled = false
            
            let cells = self.collectionView.visibleCells
            for cell in cells {
                let c = cell as! dialLayoutCell
                c.itemView.resetAnimationCircle()
            }
            self.navigationItem.title = "VOVO 음성 변환"
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
        cell.audioTypeDescription.text = audioTypeDescription[indexPath.item]
        return cell
    }
    
    
    //Orientations Change! Will -> Orientation 변하려 할때 실행이 되는 함수
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        /*
        print("Change")
         */
    }
}
