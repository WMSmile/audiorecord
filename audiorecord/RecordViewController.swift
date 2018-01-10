//
//  RecordViewController.swift
//  audiorecord
//
//  Created by apple on 2017/10/22.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {
    
    let  kFakeTimerDuration     :Float  =   0.2
    let  kMaxRecordDuration    :Float   =     60     //最长录音时长
    let  kRemainCountingDuration    :Float = 10     //剩余多少秒开始倒计时
    
    
    var voiceRecordCtrl:BBVoiceRecordController?;
    var btnRecord:BBHoldToSpeakButton?;
    var currentRecordState:BBVoiceRecordState?;
    var fakeTimer:Timer?;
    var duration:Float = 0.0;
    var canceled:Bool = true;

    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white;
        self.btnRecord = BBHoldToSpeakButton.init(type: .custom);
        self.btnRecord?.frame = CGRect(x: 40, y: 80, width: 300, height: 40)
        self.view.addSubview(btnRecord!);
        
        btnRecord?.backgroundColor = UIColor.clear;
        
        btnRecord?.layer.borderWidth = 0.5;
//        btnRecord?.layer.borderColor = [UIColor colorWithHex:0xA3A5AB].CGColor;
        btnRecord?.layer.cornerRadius = 4;
        btnRecord?.layer.masksToBounds = true;
        btnRecord?.isEnabled = false;    //将事件往上传递
        btnRecord?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16);
        
        
//        [btnRecord? setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateNormal];
//        [btnRecord? setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateHighlighted];
        btnRecord?.setTitleColor(UIColor.lightGray, for: .normal);
        btnRecord?.setTitleColor(UIColor.lightGray, for: .highlighted);
        btnRecord?.setTitle("Hold to talk", for: .normal);
        //初始化
        self.voiceRecordCtrl = BBVoiceRecordController.init();
    }
    
    //MARK:-
    func startFakeTimer() -> Void {
        
        self.startRecord();

        self.stopFakeTimer();
        self.fakeTimer = Timer.init(timeInterval: TimeInterval(kFakeTimerDuration), target: self, selector: #selector(onFakeTimerTimeOut), userInfo: nil, repeats: true);
        RunLoop.current.add(fakeTimer!, forMode: .commonModes)
        fakeTimer?.fire();
        
    
    }
    //MARK:-
    func stopFakeTimer() -> Void {
        if fakeTimer != nil
        {
            fakeTimer?.invalidate();
            fakeTimer = nil;
        }
    }


    //MARK:- 
    func onFakeTimerTimeOut() -> Void {
        self.duration += kFakeTimerDuration;
        NSLog("+++duration+++ %f",self.duration);
        let remainTime:Float = kMaxRecordDuration - self.duration;
        if (Int(remainTime) == 0) {
            self.currentRecordState = BBVoiceRecordState.normal;
            self.dispatchVoiceState();
        }
        else if (self.shouldShowCounting()) {
            self.currentRecordState = BBVoiceRecordState.recordCounting;
            self.dispatchVoiceState()
            self.voiceRecordCtrl?.showRecordCounting(remainTime);
        }
        else
        {
//            let random:uint = 1 + arc4random()%99 ;
//            let fakePower:Float = Float(random)/100.0;
//            print("fakepower==\(fakePower) randow == \((1 + arc4random()%99))");
            let fakePower = RecordManager.getInstance.fetchDBLevel()
            self.voiceRecordCtrl?.updatePower(Float(fakePower));
        }
    }

    
    //MARK:-
    func shouldShowCounting() -> Bool {
        if (self.duration >= (kMaxRecordDuration-kRemainCountingDuration) && self.duration < kMaxRecordDuration && self.currentRecordState != BBVoiceRecordState.releaseToCancel) {
            return true;
        }
        return false;
    }

    //MARK:- <#Description#>
    func resetState() -> Void {
        self.stopFakeTimer();
        self.duration = 0;
        self.canceled = true;
    }

    //MARK:- <#Description#>
    func dispatchVoiceState() -> Void {
        if (currentRecordState == BBVoiceRecordState.recording) {
            self.canceled = false;
//            self.startFakeTimer();
        }
        else if (currentRecordState == BBVoiceRecordState.normal)
        {
            self.resetState();
        }
        btnRecord?.updateRecordStyle(currentRecordState!);
        self.voiceRecordCtrl?.updateUI(with: currentRecordState!);
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchPoint = touch.location(in: self.view)
            if (btnRecord?.frame.contains(touchPoint))!{
                self.currentRecordState = BBVoiceRecordState.recording;
                self.dispatchVoiceState();
                self.startFakeTimer();
            }
        }

    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (canceled) {
            return;
        }
        if let touch = touches.first {
            let touchPoint = touch.location(in: self.view)
            if (btnRecord?.frame.contains(touchPoint))!{
                self.currentRecordState = BBVoiceRecordState.recording;
            }
            else
            {
                self.currentRecordState = BBVoiceRecordState.releaseToCancel;
            }
            self.dispatchVoiceState();
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (canceled) {
            return;
        }
        if let touch = touches.first {
            let touchPoint = touch.location(in: self.view)
            if (btnRecord?.frame.contains(touchPoint))!{
                if (self.duration < 3) {
                    self.voiceRecordCtrl?.showToast("Message Too Short.");
                }
                else
                {
                    //upload voice
                    print("touchesEnded");
                    self.stopRecord();
                }
            }
            self.currentRecordState = BBVoiceRecordState.normal;
            self.dispatchVoiceState();
        }
      

    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (canceled) {
            return;
        }
        if let touch = touches.first {
            let touchPoint = touch.location(in: self.view)
            if (btnRecord?.frame.contains(touchPoint))!{
                if (self.duration < 3) {
                    self.voiceRecordCtrl?.showToast("Message Too Short.");
                }
                else
                {
                    //upload voice
                    print("touchesCancelled");
                    self.stopRecord();
                    
                }
            }
            self.currentRecordState = BBVoiceRecordState.normal;
            self.dispatchVoiceState();
        }
    }



    //MARK:- 录音
    func startRecord() {
        
        RecordManager.getInstance.startRecord();
        
    }
    func stopRecord() {
        RecordManager.getInstance.stopRecord();
    }
    func cancelRecord() -> Void {
        RecordManager.getInstance.cancelRecord();
    }

    
    func play() {
//        RecordManager.getInstance.playLocalAudio(URL.init(string: "")!, error:  { (error) in
//            print("播放啊失败");
//        })
        
        RecordManager.getInstance.play { (error) in
            print("播放失败");
        }
    }
    //MARK:- 录音

    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
