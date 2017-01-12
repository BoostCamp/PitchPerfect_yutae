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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recordingLabel.text = "Tab to Record"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func recordAction(_ sender: Any) {
        let session = AVAudioSession.sharedInstance()
        // Permission 예외 처리
        session.requestRecordPermission({ (granted:Bool) in
            if granted {
                let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
                let recordingName = "recordedVoice.m4a"
                let pathArray = [dirPath, recordingName]
                let filePath = URL(string: pathArray.joined(separator: "/"))
                
                let recordSettings =
                    [AVFormatIDKey: kAudioFormatMPEG4AAC,
                     AVSampleRateKey: 16000.0,
                     AVNumberOfChannelsKey: 1] as [String : Any]
                
                /* High Quality
                let recordSettings =
                    [AVFormatIDKey: NSNumber(value:kAudioFormatAppleLossless),
                     AVEncoderAudioQualityKey : AVAudioQuality.low.rawValue,
                     AVEncoderBitRateKey : 320000,
                     AVNumberOfChannelsKey: 2,
                     AVSampleRateKey : 44100.0] as [String : Any]
                */
                self.recordingLabel.text = "Recording..."
                
                try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                try! session.setActive(true)
                try? self.audioRecorder = AVAudioRecorder(url: filePath!, settings: recordSettings)
                
                // Optional Binding
                if let audioRecorder = self.audioRecorder {
                    self.controller = IQAudioRecorderViewController.init()
                    self.controller.argAudioRecorder = audioRecorder
                    self.controller.delegate = self
                    self.controller.title = "VOVO 음성 녹음"
                    // Bar Color 설정
                    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.themeColor]
                    self.controller.normalTintColor = UIColor.themeColor
                    
                    self.controller.allowCropping = true
                    
                    self.presentBlurredAudioRecorderViewControllerAnimated(self.controller)
                }
                /*
                self.audioRecorder.delegate = self
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()
                */

            } else {
                // 접근 권한 없어서 설정으로 이동.
                let alert = UIAlertController(title: "마이크 접근 권한이 필요 합니다.", message: "설정 -> VOVO 마이크 접근 허용", preferredStyle: .alert)
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
//        print("Cancel Button Pressed")
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
            self.performSegue(withIdentifier: "recordingCompletion", sender: filePath)
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }
    
    /* // IQAudioRecorderViewController 에 구현
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
            let filePath = sender as! String
            let url = URL.init(fileURLWithPath: filePath)
            playSoundsVC.recordedAudioURL = url
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
}
