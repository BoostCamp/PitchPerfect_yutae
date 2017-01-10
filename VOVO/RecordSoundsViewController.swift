//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by 최유태 on 2016. 12. 29..
//  Copyright © 2016년 YutaeChoi. All rights reserved.
//

import UIKit
import AVFoundation
import IQAudioRecorderController

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate, IQAudioRecorderViewControllerDelegate {

    var audioRecorder:AVAudioRecorder!

    @IBOutlet weak var recordingButton: UIButton!
    
    
    var controller:IQAudioRecorderViewController!
    
    @IBOutlet weak var recordingLabel: UILabel!
//    iPad Label size 33
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // 배경 색 그라데이션 효과
//        self.view.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: self.view.frame, andColors: UIColor.themeColors)
//        self.navigationController?.navigationBar.titleTextAttributes =
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        self.recordingLabel.text = "Tab to Record"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureUI(){
        self.recordingButton.setTitleColor(UIColor.themeColor, for: .selected)
        // 기기별 text Size 조절
//        self.recordingLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    @IBAction func recordAction(_ sender: Any) {
        let session = AVAudioSession.sharedInstance()
        // Permission 예외 처리
        session.requestRecordPermission({ (granted:Bool) in
            if granted {
                let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
                let recordingName = "recordedVoice.aac"
                let pathArray = [dirPath, recordingName]
                let filePath = URL(string: pathArray.joined(separator: "/"))
                
                let recordSettings =
                    [AVFormatIDKey: kAudioFormatMPEG4AAC,
                     AVSampleRateKey: 16000.0,
                     AVNumberOfChannelsKey: 1] as [String : Any]
//                High Quality
                /*
                let recordSettings =
                    [AVFormatIDKey: NSNumber(value:kAudioFormatAppleLossless),
                     AVEncoderAudioQualityKey : AVAudioQuality.low.rawValue,
                     AVEncoderBitRateKey : 320000,
                     AVNumberOfChannelsKey: 2,
                     AVSampleRateKey : 44100.0] as [String : Any]
                */
                self.recordingLabel.text = "Recording..."
//                self.recordingLabel.isHidden = false
//                self.recordingButton.isEnabled = false
                
                try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: recordSettings)
                
                self.controller = IQAudioRecorderViewController.init()
                self.controller.argAudioRecorder = self.audioRecorder
                self.controller.delegate = self
                self.controller.title = "VOVO 음성 녹음"
                
                // Bar Color 설정
                UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.themeColor]
                self.controller.normalTintColor = UIColor.themeColor
                
                self.controller.allowCropping = true
                
                self.presentBlurredAudioRecorderViewControllerAnimated(self.controller)
                
                /*
                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                
                self.audioRecorder.delegate = self
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()
                */

            } else {
                // 접근 권한 없어서 설정으로 이동.
                let alert = UIAlertController(title: "마이크 접근 권한이 필요 합니다.", message: "설정 -> PitchPerfect 마이크 접근 허용", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (action:UIAlertAction) -> Void in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsUrl!)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    // MARK : IQAudio
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        print("Cancel Button Pressed")
        DispatchQueue.main.async {
            self.recordingLabel.text = "Tab to Record"
        }
        self.controller.dismiss(animated: true) {
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        DispatchQueue.main.async {
            self.recordingLabel.text = "Tab to Record"
        }
        self.controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: "recordingCompletion", sender: self.audioRecorder.url)
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }
    
    /*
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording was not successful")
        }
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordingCompletion"{
            let playSoundsVC = segue.destination as! PlaySoundsDialLayoutViewController
            let recordedAudio = sender
            playSoundsVC.recordedAudioURL = recordedAudio as! URL!
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
}
