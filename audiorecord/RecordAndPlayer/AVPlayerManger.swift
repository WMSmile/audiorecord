//
//  AVPlayerManger.swift
//  audiorecord
//
//  Created by apple on 2018/1/10.
//  Copyright © 2018年 wumeng. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerManger: NSObject {
    static let getInstance:AVPlayerManger = AVPlayerManger();
    var player:AVPlayer?
    var songItem:AVPlayerItem?
    
    func play(urlStr:String){
        self.songItem?.removeObserver(self, forKeyPath: "status");
        self.songItem = AVPlayerItem.init(url: URL.init(string: urlStr)!)
        if self.player == nil {
            self.player = AVPlayer.init(playerItem: songItem);
        }
        self.player?.replaceCurrentItem(with: songItem);
        player?.play();
        songItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil);
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            switch (self.player?.status)! {
            case .unknown:
                print("unknown")
                break
            case .failed:
                print("failed")
                break
            case .readyToPlay:
                print("readyToPlay")
                break
            }
            
        }
        
    }
    //MARK:- 暂停，清除 代理方法
    func stop()
    {
        if self.player != nil {
            self.player?.pause();
            self.songItem?.removeObserver(self, forKeyPath: "status");
        }
    }
    //MARK:- 暂停
    func pause() -> Void {
        self.player?.pause();
    }

    
    
    
    

}
