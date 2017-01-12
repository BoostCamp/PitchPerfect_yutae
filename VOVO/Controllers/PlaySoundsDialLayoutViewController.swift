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
    var fixedXOffset:CGFloat!
    
    let audioType = ["Stop", "Turtle", "Rabbit", "Chipmunk", "Vader", "Echo", "Reverb", "Organ", "Drum", "Car", "Clap"]
    let audioTypeDescription = ["STOP", "SLOW", "FAST", "LIGHT", "HEAVY", "ECHO", "REVERB", "ORGAN", "DRUM", "HORN", "APPLAUSE"]
//    AVAudio
    var recordedAudioURL: URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var duration: Double!
//    For Share
    var changedAudioFile:AVAudioFile!
    
//    To be mixed
    var mixedAudioFile: AVAudioFile!
    var mixedPlayerNode: AVAudioPlayerNode!
    var mixedBuffer: AVAudioPCMBuffer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scroll 가리기
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        // Check iPad, iPhone Set Layout
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
//                print("Current UI Device iPad - Dial Layout")
                self.radius = 440.0
                self.cell_width = 200
                self.cell_height = CGFloat((200*1.3)+10.0)
                let currentWidth = self.view.frame.width
                let currentHeight = self.view.frame.height
                
                if ((currentWidth == 768 && currentHeight == 1024) || (currentWidth == 1024 && currentHeight == 768)) {
                    // iPad 9.7
                    self.angularSpacing = 40.0
                    self.fixedXOffset = 400
                } else {
                    // iPad 12.9
                    self.angularSpacing = 50.0
                    self.fixedXOffset = 540
                }
            default:
                if(self.view.frame.width < 370){
//                    print("Current UI Device < iPhone 6- Dial Layout")
                    self.angularSpacing = 40.0
                    self.radius = 220.0
                    self.cell_width = 120
                    self.cell_height = CGFloat((120*1.3)+10.0)
                }
                else {
//                    print("Current UI Device > iPhone 6 - Dial Layout")
                    self.angularSpacing = 40.0
                    self.radius = 220.0
                    self.cell_width = 150
                    self.cell_height = CGFloat((150*1.3)+10.0)
                }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDialLayoutUI()
        // Sharing Button init
        self.sharingButton.isEnabled = false
        
        // 추후에 DB 추가 한다면 URL 주소가 바뀔 수 있어서 WillAppear
        self.setupAudio()
        
        // Add Observer orientation Changed !!
        NotificationCenter.default.addObserver(self, selector: #selector(PlaySoundsDialLayoutViewController.orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func orientationDidChange(notification: NSNotification) {
//        print("orientationDidChange")
        // orientation Changed 일때 UI Reset
        self.configureDialLayoutUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // View 사라지고 난 후 Observer remove!!
        NotificationCenter.default.removeObserver(self)
        // View 사라지고 난 후 현재 재생중인 음악 끄기.
        self.stopAudio()
        // Audio nodes nil 로 초기화
        self.audioEngine = nil
        self.audioPlayerNode = nil
        self.mixedPlayerNode = nil
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
        // 공유 하고 난 뒤 음성 변조 복제된 파일 삭제.
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.changedAudioFile.url.absoluteString){
            // file 존재 여부를 확인해서 무조건 삭제 가능.
            try! fileManager.removeItem(atPath: self.changedAudioFile.url.absoluteString)
        }
        return self
    }
    
    // DialLayout 초기화
    func configureDialLayoutUI(){
        let xOffset:CGFloat!
        if let x = self.fixedXOffset {
            xOffset = x
        } else {
            xOffset = self.view.frame.width/2
        }
        
        self.dialLayout = AWCollectionViewDialLayout(raduis: self.radius , angularSpacing: self.angularSpacing, cellSize: CGSize.init(width: self.cell_width, height: self.cell_height), alignment: WheelAlignmentType.center, itemHeight: cell_height, xOffset: xOffset)
        
        // Snap : true - Right, false - Left
        self.dialLayout.shouldSnap = true
        self.dialLayout.shouldFlip = true
        
        self.collectionView.collectionViewLayout = self.dialLayout
        self.dialLayout.scrollDirection = .horizontal
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.audioType.count
    }
    
    func stopAllAudioResetCircle(){
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
    
    func selectedPlayAudio(selectedItem:Int){
        switch (selectedItem) {
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
            self.playSound(mixed:self.audioType[selectedItem])
        }
        
        // UI라서 DispatQueue main 으로 관리 Sharing Button init
        DispatchQueue.main.async {
            if(selectedItem != 0) {
                self.sharingButton.isEnabled = true
                
                let tempIndexPath = IndexPath(item: selectedItem, section: 0)
                
                let cell = self.collectionView.cellForItem(at: tempIndexPath) as! dialLayoutCell
                
                var maxDuration: Double!
                switch (selectedItem) {
                case 1:
                    maxDuration = self.duration / 0.5
                case 2:
                    maxDuration = self.duration / 1.5
                default:
                    maxDuration = self.duration
                }
                cell.itemView.progress = maxDuration
                cell.itemView.start()
                // navigationItem title 를 현재 재생 중인 효과음으로 바꿔준다.
                self.navigationItem.title = self.audioType[selectedItem].uppercased()
            }
        }
    }
    // Scroll 끝났을 때 음악 재생.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("Selected : \(self.dialLayout.selectedItem)")
        selectedPlayAudio(selectedItem: self.dialLayout.selectedItem)
    }
    
    // Scroll 시작 시 음악 정지.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        stopAllAudioResetCircle()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Clicked IndexPath: \(self.audioType[indexPath.item])")
        stopAllAudioResetCircle()
        selectedPlayAudio(selectedItem: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! dialLayoutCell
        let audioType = self.audioType[indexPath.item]
        // Image 삽입
        cell.itemView.coverImage = UIImage(named: audioType)
        cell.itemView.delegate = self
        cell.audioTypeDescription.text = audioTypeDescription[indexPath.item]
        return cell
    }
}
