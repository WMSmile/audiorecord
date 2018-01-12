//
//  AVPlayerManger.swift
//  audiorecord
//
//  Created by apple on 2018/1/10.
//  Copyright © 2018年 wumeng. All rights reserved.
//

import UIKit
import AVFoundation

@objc enum AVplayerMangerPlayStatus:NSInteger {
    case begin //开始播放
    case fail  //播放失败
    case pause  //播放暂停
    case end   //播放结束
}

@objc protocol AVPlayerMangerDelegate:NSObjectProtocol {
    //MARK:- 状态的改变
    @objc optional func AVPlayerMangerPlayStatusChange(_ status:AVplayerMangerPlayStatus) -> Void;

}

class AVPlayerManger: NSObject {
    ///单例类
    static let getInstance:AVPlayerManger = AVPlayerManger();
    //播放器
    var player:AVPlayer?
    //播放的内容
    var songItem:AVPlayerItem?
    //时间的监控
    var timeObserver:Any?
    
    //代理
    weak var delegate:AVPlayerMangerDelegate?
    //block回调
    var changeCallBack:((_ status:AVplayerMangerPlayStatus) -> Void)? = nil;

    
    func play(urlStr:String){
        self.removeObservers();
        self.songItem = AVPlayerItem.init(url: URL.init(string: urlStr)!)
        if self.player == nil {
            self.player = AVPlayer.init(playerItem: songItem);
            self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)), queue: DispatchQueue.main, using: { (time) in
                //当前的时间
                let currentTime = CMTimeGetSeconds(time);
                let totalTime = CMTimeGetSeconds((self.songItem?.duration)!);
                self.timeCallBack(currentTime: Float(currentTime), totalTime: Float(totalTime));
            });
        }else {
            self.player?.replaceCurrentItem(with: songItem);
        }
        self.addObservers();
        self.addNotifications();
    }
    //监控网络和初始化的状态
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            switch (self.player?.status)! {
            case .unknown:
                print("unknown")
                break
            case .failed:
                print("failed")
                self.handleDelegate(.fail);
                break
            case .readyToPlay:
                print("readyToPlay")
                player?.play();
                self.handleDelegate(.begin);
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
        self.handleDelegate(.pause);
    }
    //MARK:- 添加观察者
    func addObservers() -> Void {
        //添加观察者
        songItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil);
    }
    //MARK:- 移除观察者
    func removeObservers() -> Void {
        if (songItem != nil) {
            self.songItem?.removeObserver(self, forKeyPath: "status");
        }
    }


    
    //MARK:- 添加通知
    func addNotifications() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinish(notify:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil);
    }
    //MARK:- 移除通知
    func removeNorifications() -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.timeObserver = nil;
    }


    //MARK:- 进度条
    func timeCallBack(currentTime:Float,totalTime:Float) -> Void {
        //计算 progress
        print("progress = \(currentTime/totalTime)  current == \(currentTime) total == \(totalTime)");
        
    }

    //MARK:- 播放结束
    func playbackFinish(notify:Notification) -> Void {
        print("播放结束");
        self.removeNorifications();
        self.handleDelegate(.end);
        
    }
    //MARK:- 获取播放的状态
    func fetchIsPlayingStatus() -> Bool {
        guard (self.player != nil) else {
            return false;
        }
        if ((self.player?.rate)! >= Float(1)) {
            return false
        }
        else {
            return true;
        }
    }
    
    
    //MARK:- playStatus
    func observerPlayStatusChange(_ callback:@escaping (_ status:AVplayerMangerPlayStatus) -> Void) -> Void {
        self.changeCallBack = callback;
    }
    
    //MARK:- 执行代理
    func handleDelegate(_ status:AVplayerMangerPlayStatus) -> Void {
        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(AVPlayerMangerDelegate.AVPlayerMangerPlayStatusChange(_:))))! {
            self.delegate?.AVPlayerMangerPlayStatusChange!(status);
        }
        if (changeCallBack != nil) {
            self.changeCallBack!(status);
        }
    }

    
    
    

}
