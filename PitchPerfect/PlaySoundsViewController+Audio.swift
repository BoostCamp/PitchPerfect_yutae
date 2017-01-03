//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Created by 최유태 on 2016. 12. 29..
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
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
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
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
   
        // connect nodes (Original)
        /*
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
         */
        
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.mainMixerNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.mainMixerNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.mainMixerNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.mainMixerNode,audioEngine.outputNode)
        }
        
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
            self.audioEngine.prepare()
        
        // schedule to play and start the engine!
         do {
            try self.audioEngine.start()
         } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
         }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 8192, format: self.changedAudioFile.processingFormat, block: {
                (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) in
                do {
                    try self.changedAudioFile.write(from:buffer)
                    print("Copy...")
                    print("new Audio : \(self.changedAudioFile.length)")
                } catch {
                    print(error)
                }
                /*
                let dataptrptr = buffer.floatChannelData!
                let dataptr = dataptrptr.pointee
                let datum = dataptr[Int(buffer.frameLength) - 1]
                
                if (done && abs(datum) < 0.000001 ){
                    print("-----------------")
                    print("Copy Completion")
                    print("-----------------")
                    self.stopAudio()
                    self.audioEngine.mainMixerNode.removeTap(onBus: 0)
                    return
                }
                 */
                
            })
        }
        
        self.audioPlayerNode.stop()
        
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
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        
        // play the recording!
        self.audioPlayerNode.play()
        self.audioEngine.mainMixerNode.removeTap(onBus: 0)
    }
    
    func stopAudio() {
        sharingButton.isEnabled = true
        
        if (self.audioPlayerNode) != nil {
//            self.audioPlayerNode.stop()
            self.audioPlayerNode = nil
        }
        if (self.audioEngine) != nil {
//            audioEngine.stop()
//            audioEngine.reset()
            self.audioEngine = nil
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions
    
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
            
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
