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
//        self.recordingAudioPlot.backgroundColor = [UIColor colorWithRed: 1.0 green: 0.2 blue: 0.365 alpha: 1];
//        self.recordingAudioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
//        self.recordingAudioPlot.plotType        = EZPlotTypeRolling;
//        plot?.shouldFill = true;
//        plot?.shouldMirror = true;
//
//        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                /*
                let recordSettings =
                    [AVFormatIDKey: NSNumber(value:kAudioFormatAppleLossless),
                     AVEncoderAudioQualityKey : AVAudioQuality.low.rawValue,
                     AVEncoderBitRateKey : 320000,
                     AVNumberOfChannelsKey: 2,
                     AVSampleRateKey : 44100.0] as [String : Any]
                */
                self.recordingLabel.text = "Recording"
//                self.recordingLabel.isHidden = false
//                self.recordingButton.isEnabled = false
                
                try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: recordSettings)
                
                self.controller = IQAudioRecorderViewController.init()
                self.controller.argAudioRecorder = self.audioRecorder
                self.controller.delegate = self
                self.controller.title = "VOVO 음성 메모"
                
                self.controller.normalTintColor = UIColor.brown
                self.controller.highlightedTintColor = UIColor.red
                
                self.controller.allowCropping = true
                
                self.presentBlurredAudioRecorderViewControllerAnimated(self.controller)
                
                /*
                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                
                self.audioRecorder.delegate = self
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()

                self.EZAudioInit()
                */

            } else {
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
    @IBAction func stopRecording(_ sender: Any) {
//        recordingLabel.text = "Tap to Record"
        recordingButton.isEnabled = true
        
        audioRecorder.stop()
        
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
        
    }
    // MARK : IQAudio
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        self.controller.dismiss(animated: true, completion: nil)
    }
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        self.controller.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "stopRecording", sender: self.audioRecorder.url)
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudio = sender
            playSoundsVC.recordedAudioURL = recordedAudio as! URL!
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recordingLabel.isHidden = true
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("View Did disappear!")
    }
    
}

extension TimeInterval {
    func stringFromTimeInterval() -> NSString {
        
        let ti = NSInteger(self)
        let ms = Int((self.truncatingRemainder(dividingBy: 1.0) * 100))
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        //        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d.%0.2d",minutes,seconds, ms)
    }
}
