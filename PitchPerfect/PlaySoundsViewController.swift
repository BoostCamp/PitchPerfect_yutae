//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by 최유태 on 2016. 12. 29..
//  Copyright © 2016년 YutaeChoi. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var recordedAudioURL: URL!
    
    var recordedAudio: AVAudioRecorder!
    
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
        print("Stop")
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
            var sharingItems = [AnyObject]()
//            sharingItems.append(recordedAudio)
//            print(recordedAudio)
//            sharingItems.append(audioFile.fileFormat)
//            print(audioFile.fileFormat)
//            sharingItems.append(audioPlayerNode)
//            print(audioPlayerNode)
            let data = NSData(contentsOf: recordedAudio.url)
            
//            sharingItems.append(data! as AnyObject)
//            print(data)
//            audioPlayerNode.
            sharingItems.append(audioType[selectedButton] as AnyObject)
            
            
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
            activityViewController.accessibilityLanguage = "ko-KR"

            if(activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController?.sourceView = self.view;
                let frame = UIScreen.main.bounds
                activityViewController.popoverPresentationController?.sourceRect = frame;
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
