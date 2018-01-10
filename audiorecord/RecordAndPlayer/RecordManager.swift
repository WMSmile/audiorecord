//
//  RecordManager.swift
//  audiorecord
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit
import AVFoundation
import CoreFoundation

class RecordManager: NSObject ,AVAudioPlayerDelegate{
    
    static let getInstance = RecordManager();
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    
    let file_path:String = NSTemporaryDirectory().appending("record.caf")
    var mp3_filePath:String = NSTemporaryDirectory().appending("record.mp3")

    var sampleRate:Int32 = 16000;//转码的样率
    //开始录音
    func startRecord() {
        let session = AVAudioSession.sharedInstance()
        //设置session类型
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
        //录音设置，注意，后面需要转换成NSNumber，如果不转换，你会发现，无法录制音频文件，我猜测是因为底层还是用OC写的原因
        let recordSetting: [String: Any] = [AVSampleRateKey: NSNumber(value: sampleRate),//采样率
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
            AVNumberOfChannelsKey: NSNumber(value: 2),//通道数
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
        ];
        //开始录音
        do {
            let url = URL(fileURLWithPath: file_path)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            recorder!.record()
            print("开始录音")
        } catch let err {
            print("录音失败:\(err.localizedDescription)")
        }
    }
    
    
    //结束录音
    func stopRecord() {
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("正在录音，马上结束它，文件保存到了：\(file_path)")
                AudioWrapper.convertFromWav(toMp3: file_path, mp3FilePath: mp3_filePath, sampleRateKey: sampleRate);
                
            }else {
                print("没有录音，但是依然结束它")
            }
            recorder.stop()
            self.recorder = nil
        }else {
            print("没有初始化")
        }
    }
    //MARK:- 取消录音
    func cancelRecord() -> Void {
        if let recorder = self.recorder {
            recorder.stop()
            recorder.deleteRecording();
            self.recorder = nil
        }
    }

    //MARK: - 获取分贝
    func fetchDBLevel() -> Double {
        self.recorder?.updateMeters()
        let ALPHA = 0.05
        let peakPower = pow(10, (ALPHA * Double((self.recorder?.peakPower(forChannel: 0))!)))
        var rate: Double = 0.0
        if (peakPower <= 0.2) {
            rate = 0.2
        } else if (peakPower > 0.9) {
            rate = 1.0
        } else {
            rate = peakPower
        }
        return rate
    }

    
    
    
    
    
    
    
    //播放
    func play(error:((_ error:Error)->())) {
        self.playLocalAudio(URL(fileURLWithPath: mp3_filePath), error: error);
    }
    //播放
    func playLocalAudio(_ audioUrl:URL,error:((_ error:Error)->())) {
        let session = AVAudioSession()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback, with: [])
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: audioUrl)
            print("歌曲长度：\(player!.duration)")
            player?.delegate = self;
            player!.play()
        } catch let err {
//            print("播放失败:\(err.localizedDescription)")
            error(err);
        }
    }

    //MARK:- 播放结束
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("播放结束");
    }

    //MARK:- 停止播放
    func stopPlay() -> Void {
        player?.stop();
    }

    //MARK:- 播放网络音乐
    func playNetworkSong(url:String,error:@escaping ((_ error:Error)->()))    {
        
        let nsUrl:URL = URL(string:url)!
        let urlRequest:URLRequest = URLRequest.init(url: nsUrl)
        let downTask:URLSessionDownloadTask =  URLSession.shared.downloadTask(with: urlRequest) { (locationurl, urlRequest, urlError) in
//            print("url == \(url) url == \(urlRequest) error = \(urlError)");
//
//            //下载结束
//            print("下载结束")
//            //输出下载文件原来的存放目录
//            print("location:\(locationurl!)")
            //location位置转换
            let locationPath:String = (locationurl?.path)!
            //拷贝到用户目录
            let tmpAudio:String = NSTemporaryDirectory() + "/audio/"
            let audioLocationUrl:String = tmpAudio + "\(nsUrl.lastPathComponent)";
            //创建文件管理器
            let fileManager:FileManager = FileManager.default
            if !fileManager.fileExists(atPath: tmpAudio)
            {
                do
                {
                     try fileManager.createDirectory(atPath: tmpAudio, withIntermediateDirectories: true, attributes: nil);
                }catch let err{
                    print(err.localizedDescription);
                }
              
            }
            do {
                try fileManager.moveItem(atPath: locationPath, toPath: audioLocationUrl)

            }catch let err{
                print(err.localizedDescription);
            }
            print("new location:\(audioLocationUrl)")
            self.playLocalAudio(URL(fileURLWithPath: audioLocationUrl), error: error);
        }
        downTask.resume();
    }
    
    
    
    
    
    
    
    //MARK:- 生成随机文件名
    func getRandomMP3FileName() -> String {
        var str = "record";
        let random = arc4random()%1000000
        let date = Date();
        let dateFormater = DateFormatter.init();
        dateFormater.dateFormat = "yyyyMMDDHHmmss"
        str = str + "-" + dateFormater.string(from: date) + "-" + String(random) + ".mp3";
        return str
        
    }

}
