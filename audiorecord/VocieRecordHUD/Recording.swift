//
//  Recording.swift
//  audiorecord
//
//  Created by apple on 2017/8/7.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
    @objc optional func audioMeterDidUpdate(_ dB: Float)
}

open class Recording : NSObject ,AVAudioPlayerDelegate{
    
    @objc public enum State: Int {
        case none, record, play
    }
    
    static var directory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    open weak var delegate: RecorderDelegate?
    open fileprivate(set) var url: URL
    open fileprivate(set) var state: State = .none
    
    open var bitRate = 192000
    open var sampleRate = 44100.0
    open var channels = 1
    
    fileprivate let session = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder?
    fileprivate var player: AVAudioPlayer?
    fileprivate var link: CADisplayLink?
    
    var metering: Bool {
        return delegate?.responds(to: #selector(RecorderDelegate.audioMeterDidUpdate(_:))) == true
    }
    
    // MARK: - InitializersError Domai
    
    public init(to: String) {
        url = URL(fileURLWithPath: Recording.directory).appendingPathComponent(to)
        super.init()
    }
    
    // MARK: - Record
    open func prepare() throws {
            let settings: [String: AnyObject] = [
                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM) as Int32),
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue as AnyObject,
                AVEncoderBitRateKey: bitRate as AnyObject,
                AVNumberOfChannelsKey: channels as AnyObject,
                AVSampleRateKey: sampleRate as AnyObject
            ]
//        let settings: [String: Any] = [AVSampleRateKey: NSNumber(value: 16000),//采样率
//            AVFormatIDKey: NSNumber(value: UInt32(kAudioFormatAMR)),//音频格式
//            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
//            AVNumberOfChannelsKey: NSNumber(value: 1),//通道数
//            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
//        ];
        


        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.prepareToRecord()
        recorder?.delegate = delegate
        recorder?.isMeteringEnabled = metering
    }
    
    open func record() throws {
        if recorder == nil {
            try prepare()
        }
        
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        
        recorder?.record()
        state = .record
        
        if metering {
            startMetering()
        }
    }
    
    // MARK: - Playback
    
    open func play() throws {
        try session.setCategory(AVAudioSessionCategoryPlayback)
        
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
        player?.delegate = self
        state = .play
    }
    
    open func stop() {
        switch state {
        case .play:
            player?.stop()
            player = nil
        case .record:
            recorder?.stop()
            recorder = nil
            stopMetering()
        default:
            break
        }
        
        state = .none
    }
    
    // MARK: - Metering
    
    func updateMeter() {
        guard let recorder = recorder else { return }
        
        recorder.updateMeters()
        
        let dB = recorder.averagePower(forChannel: 0)
        
        delegate?.audioMeterDidUpdate?(dB)
    }
    
    fileprivate func startMetering() {
        link = CADisplayLink(target: self, selector: #selector(Recording.updateMeter))
        link?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func stopMetering() {
        link?.invalidate()
        link = nil
    }
    
    
    
    //MARK:- 播放结束
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("播放结束");
    }
    
    
}
