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
    
 
////    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//////        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//////            plot?.updateBuffer(buffer[0], withBufferSize: bufferSize)
//////        });
////    }
    func EZAudioInit(){
        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)
//        self.microphone.microphoneOn = true
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
    /*
    func timeIntervalAsString(_ format : String = "dd days, hh hours, mm minutes, ss seconds, sss ms") -> String {
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
        let s = asInt % 60
        let m = (asInt / 60) % 60
        let h = ((asInt / 3600))%24
        let d = (asInt / 86400)
        
        var value = format
        value = value.replacingOccurrences(of: "hh", with: String(format: "%0.2d", h))
        value = value.replacingOccurrences(of: "mm",  with: String(format: "%0.2d", m))
        value = value.replacingOccurrences(of: "sss", with: String(format: "%0.3d", ms))
        value = value.replacingOccurrences(of: "ss",  with: String(format: "%0.2d", s))
        value = value.replacingOccurrences(of: "dd",  with: String(format: "%d", d))
        if (ago) {
            value += " ago"
        }
        return value
    }
     */
    
}
