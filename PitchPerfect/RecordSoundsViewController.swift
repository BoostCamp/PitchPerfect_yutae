//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by 최유태 on 2016. 12. 29..
//  Copyright © 2016년 YutaeChoi. All rights reserved.
//

import UIKit
import AVFoundation
import EZAudio

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRecorder:AVAudioRecorder!

    @IBOutlet weak var currentTimeLabel: UILabel!

    
    @IBOutlet weak var recordingButton: UIButton!
    
    
    @IBOutlet weak var recordingAudioPlot: EZAudioPlotGL!
    var microphone: EZMicrophone!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
        
//        self.recordingAudioPlot.backgroundColor = [UIColor colorWithRed: 1.0 green: 0.2 blue: 0.365 alpha: 1];
//        self.recordingAudioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
//        self.recordingAudioPlot.plotType        = EZPlotTypeRolling;
//        plot?.shouldFill = true;
//        plot?.shouldMirror = true;
        
        self.recordingAudioPlot.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.2, blue: 0.365, alpha: 1.0)
        self.recordingAudioPlot.color = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.recordingAudioPlot.shouldFill = true
        self.recordingAudioPlot.shouldMirror = true
        self.recordingAudioPlot.plotType = .rolling
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
                let recordingName = "recordedVoice.m4a"
                let pathArray = [dirPath, recordingName]
                let filePath = URL(string: pathArray.joined(separator: "/"))
                
                let recordSettings =
                    [AVFormatIDKey: kAudioFormatMPEG4AAC,
                     AVSampleRateKey: 16000.0,
                     AVNumberOfChannelsKey: 1] as [String : Any]
                
                self.recordingLabel.text = "Recording"
                self.stopRecordingButton.isHidden = false
                self.recordingLabel.isHidden = false
                self.stopRecordingButton.isEnabled = true
                self.recordingButton.isEnabled = false
                
                try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                
//                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: recordSettings)
                self.audioRecorder.delegate = self
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()

                self.EZAudioInit()
                

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
        stopRecordingButton.isEnabled = false
        
        audioRecorder.stop()
        
        self.microphone.stopFetchingAudio()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
//            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder)
        } else {
            print("Recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudio = sender as! AVAudioRecorder
            playSoundsVC.recordedAudio = recordedAudio
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopRecordingButton.isHidden = true
        self.recordingLabel.isHidden = true
        
        self.recordingAudioPlot.clear()
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("View Did disappear!")
    }
    
}

