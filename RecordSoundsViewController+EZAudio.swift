////
////  RecordSoundsViewController+EZAudio.swift
////  PitchPerfect
////
////  Created by 최유태 on 2016. 12. 30..
////  Copyright © 2016년 YutaeChoi. All rights reserved.
////
import EZAudio
import UIKit
//
extension RecordSoundsViewController: EZMicrophoneDelegate{
    func EZAudioInit(){
        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)
        self.microphone.startFetchingAudio()
    }
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        DispatchQueue.main.async {
            self.currentTimeLabel.text = self.audioRecorder.currentTime.stringFromTimeInterval() as String
            self.recordingAudioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
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
