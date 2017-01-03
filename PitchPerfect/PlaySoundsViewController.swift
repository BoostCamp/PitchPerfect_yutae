//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by 최유태 on 2016. 12. 29..
//  Copyright © 2016년 YutaeChoi. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    var recordedAudioURL: URL!

    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    var changedAudioFile:AVAudioFile!
    
    var selectedButton:Int!
    @IBOutlet weak var sharingButton: UIButton!
    
    let audioType = ["Slow", "fast", "chipmunk", "vader", "echo", "reverb"]
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
        
        selectedButton = -1
        sharingButton.isEnabled = false
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopAudio()
    }
    
    @IBAction func playSoundForButtons(_ sender: UIButton) {
        selectedButton = (sender.tag)
        switch (ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate:0.5)
        case .fast:
            playSound(rate:1.5)
        case .chipmunk:
            playSound(pitch:1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo:true)
        case .reverb:
            playSound(reverb:true)
        }
        configureUI(.playing)
    }

    @IBAction func shareButtonPressed(_ sender: Any) {
        if(selectedButton != -1){
//            self.audioEngine.mainMixerNode.removeTap(onBus: 0)
            
            let fileManager = FileManager.default

            
            if fileManager.fileExists(atPath: recordedAudioURL.absoluteString){
//                let docController = UIDocumentInteractionController(url: NSURL(fileURLWithPath: recordedAudioURL.absoluteString ) as URL)
                let docController = UIDocumentInteractionController(url: NSURL(fileURLWithPath: changedAudioFile.url.absoluteString ) as URL)
                docController.delegate = self;
                docController.presentOpenInMenu(from: UIScreen.main.bounds, in: self.view, animated: true)
            }
        }
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
