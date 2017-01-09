//
//  PlaySoundsVCExtension.swift
//  PitchPerfect
//
//  Created by 최유태 on 2017. 1. 4..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import AVFoundation

// Loading Library
import CircularSpinner

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsDialLayoutViewController: AVAudioPlayerDelegate {
    
    // MARK: Alerts
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState (raw values correspond to sender tags)
    
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    
    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func setupChangedAudio(){
        // MARK: Changed Audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "iOS_VOVO_app.aac"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let audioSettings =
            [AVFormatIDKey: kAudioFormatMPEG4AAC,
             AVSampleRateKey: 16000.0,
             AVNumberOfChannelsKey: 1] as [String : Any]
        
        /* High Quality
         let audioSettings =
         [AVFormatIDKey: NSNumber(value:kAudioFormatAppleLossless),
         AVEncoderAudioQualityKey : AVAudioQuality.low.rawValue,
         AVEncoderBitRateKey : 320000,
         AVNumberOfChannelsKey: 2,
         AVSampleRateKey : 44100.0, ] as [String : Any]
         */
        
        self.changedAudioFile = try! AVAudioFile(forWriting: filePath!, settings: audioSettings)
    }
    
    func setupMixedAudio(audioName : String){
        mixedPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(mixedPlayerNode)
        print(audioName)
        let filePath: String = Bundle.main.path(forResource: audioName, ofType: "m4a")!
        print("\(filePath)")
        let fileURL: NSURL = NSURL(fileURLWithPath: filePath)
        try! mixedAudioFile = AVAudioFile.init(forReading: fileURL as URL)
        self.mixedBuffer = AVAudioPCMBuffer.init(pcmFormat: mixedAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(mixedAudioFile.length))
        try! self.mixedAudioFile.read(into: self.mixedBuffer)
        //            self.audioPlayerNode.pan = 0.5
        //            self.audioPlayerNode.volume = 0.5
        self.mixedPlayerNode.volume = 0.2
        self.mixedPlayerNode.pan = 0.5
    }
    
    func playSound(share: Bool = false, rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false, mixed: String? = nil) {
        
        // For Share Show Loading Spinner
        if share == true {
            // UI main Queue 로 실행
            DispatchQueue.main.async {
                //            Pg 가 따라가는 선색, Bg 배경색
                //            CircularSpinner.trackBgColor = UIColor.red
                CircularSpinner.trackPgColor = UIColor.themeColor
                CircularSpinner.show("Loading...", animated: true, type: .indeterminate, showDismissButton: false)
            }
            // 새로운 녹음을 위해 nil로 초기화
            self.stopAudio()
            audioEngine = nil
            audioPlayerNode = nil
            mixedPlayerNode = nil
        }
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        
        // connect nodes Share
        if share == true {
            if echo == true && reverb == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.mainMixerNode, audioEngine.outputNode)
            } else if echo == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.mainMixerNode, audioEngine.outputNode)
            } else if reverb == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.mainMixerNode, audioEngine.outputNode)
            } else if mixed != nil{
                self.setupMixedAudio(audioName : mixed!)
                self.connectAudioNodes(audioPlayerNode, self.audioEngine.mainMixerNode, self.audioEngine.outputNode)
                self.audioEngine.connect(mixedPlayerNode, to: self.audioEngine.mainMixerNode, format: self.mixedAudioFile.processingFormat)
            } else {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.mainMixerNode, audioEngine.outputNode)
            }
        }
        // connect nodes For Play
        else {
            if echo == true && reverb == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
            } else if echo == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
            } else if reverb == true {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
            } else if mixed != nil{
                self.setupMixedAudio(audioName : mixed!)
                self.audioEngine.connect(audioPlayerNode, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
                self.audioEngine.connect(mixedPlayerNode, to: self.audioEngine.mainMixerNode, format: self.mixedAudioFile.processingFormat)
            } else {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
            }
        }
        
        
        self.audioPlayerNode.stop()
//        Editted
        
        self.audioPlayerNode.scheduleFile(self.audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            // schedule a stop timer for when audio finishes playing
            
            if share == true {
                self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsDialLayoutViewController.shareUIDocument), userInfo: nil, repeats: false)
            } else {
                self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsDialLayoutViewController.stopAudio), userInfo: nil, repeats: false)
            }
            
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        
        self.audioEngine.prepare()
        
        // schedule to play and start the engine!
        do {
            try self.audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        if share == true {
            // Background Thread로 변환된 음원 복제
            DispatchQueue.global(qos: .userInitiated).async {
                self.setupChangedAudio()
                // 8192 보다 높아 봣자 속도는 비슷하기때문.
                self.audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 8192, format: self.changedAudioFile.processingFormat, block: {
                    (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) in
                    do {
                        try self.changedAudioFile.write(from:buffer)
                        print("Copy...")
                        print("new Audio : \(self.changedAudioFile.length)")
                    } catch {
                        print(error)
                    }
                })
            }
        }
        
        if mixed != nil{
            self.mixedPlayerNode.stop()
            self.mixedPlayerNode.scheduleBuffer(self.mixedBuffer, at: nil, options: .loops, completionHandler: nil)
            self.mixedPlayerNode.play()
        }
        // play the recording!
        self.audioPlayerNode.play()
    }
    
    func shareUIDocument(){
        self.audioEngine.mainMixerNode.removeTap(onBus: 0)
        self.stopAudio()
        CircularSpinner.hide {
            let docController = UIDocumentInteractionController(url: NSURL(fileURLWithPath: self.changedAudioFile.url.absoluteString ) as URL)
            docController.delegate = self;
            docController.presentOpenInMenu(from: UIScreen.main.bounds, in: self.view, animated: true)
        }
    }
    
    func stopAudio() {
        if let audioPlayerNode = self.audioPlayerNode {
            audioPlayerNode.stop()
        }
        if let mixedPlayerNode = self.mixedPlayerNode {
            mixedPlayerNode.stop()
        }
        if let audioEngine = self.audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        if let stopTimer = self.stopTimer {
            stopTimer.invalidate()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
