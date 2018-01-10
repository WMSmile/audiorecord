//
//  ViewController.swift
//  audiorecord
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController
,RecorderViewDelegate,WMHoldToSpeakButtonDelegate
{
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var speakBtn: WMHoldToSpeakButton!
    var recorderView: RecorderViewController!
    
    var player:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.speakBtn.delegate = self;
    }
    
    //MARK:- delegate
    func buttonStatusChanged(_ buttonState: WMVoiceRecordState) {
        print("vc === \(buttonState.rawValue)");
        //可以根据状态来显示不同的文字，做出相应的操作
    }
    //MARK:-
    func buttonEventStatusChanged(_ buttonEventState: WMVoiceRecordEventState) {
        print("vc === \(buttonEventState.rawValue)");
        switch buttonEventState {
        case WMVoiceRecordEventState.start:
            print("voiceRecord start");
            self.start();
        case WMVoiceRecordEventState.cancelEnd:
            print("voiceRecord cancelEnd");
            RecordManager.getInstance.cancelRecord();
        case WMVoiceRecordEventState.normalEnd:
            print("voiceRecord normalEnd");
            RecordManager.getInstance.stopRecord();
//        default:
//            break
        }

    }
    
    

    
    
    
    
    @IBAction func start() {
//        self.present(recorderView, animated: true, completion: nil)
//        recorderView.startRecording()
        
        RecordManager.getInstance.startRecord();
        RecordManager.getInstance.sampleRate = Int32(Int(self.slider.value * 32000));
        
    }
    @IBAction func stop(_ sender: Any) {
        RecordManager.getInstance.stopRecord();

    }
    
    @IBAction func play() {
//        do {
//            try recorderView.recording.play()
//        } catch {
//            print(error)
//        }
        
        
//        RecordManager.getInstance.play { (error) in
//            print("播放失败");
//        }
//        RecordManager.getInstance.play(URL.init(string: "http://nidongde8.info/audios/record.mp3")!, error:  { (error) in
//            print("播放啊失败");
//        })
        
        
//        RecordManager.getInstance.playNetworkSong(url:"http://fs.w.kugou.com/201801061552/254b23f29bb50f862bbe4c905ca19b6e/G018/M00/0A/04/Ug0DAFVw-LCAYoUkAD_FoLiLEPc990.mp3") { (error) in
//            print("播放啊失败");
//        }
        
        
//        let item = AVPlayerItem.init(url: URL.init(string: "http://fs.w.kugou.com/201801061552/254b23f29bb50f862bbe4c905ca19b6e/G018/M00/0A/04/Ug0DAFVw-LCAYoUkAD_FoLiLEPc990.mp3")!)
//        self.player = AVPlayer.init(playerItem: item);
//        player?.play();
//        item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil);
        AVPlayerManger.getInstance.play(urlStr: "http://localhost/audio/test.mp3");
        
    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        if keyPath == "status" {
//            switch (self.player?.status)! {
//            case .unknown:
//                print("unknown")
//                break
//            case .failed:
//                print("failed")
//                break
//            case .readyToPlay:
//                print("readyToPlay")
//                break
//            }
//
//        }
//
//    }
    
    
    @IBAction func splice(_ sender: Any) {
        
//        let spliceView = SpliceViewController.init();
//        
//        spliceView.modalTransitionStyle = .crossDissolve;
//        spliceView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
//        self.present(spliceView, animated: true) { 
//            //动画结束
//            print("动画结束");
//        };
        
        let spliceView = RecordViewController.init();
        
//        self.present(spliceView, animated: true) {
//            //动画结束
//            print("动画结束");
//        };
        
        self.navigationController?.pushViewController(spliceView, animated: true);

        
    }
    @IBAction func wechat(_ sender: Any) {
        let vc = WeChatGoToViewController();
        
        self.navigationController?.pushViewController(vc, animated: true);
        
    }
    internal func didFinishRecording(_ recorderViewController: RecorderViewController) {
        print(recorderView.recording.url)

    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}

