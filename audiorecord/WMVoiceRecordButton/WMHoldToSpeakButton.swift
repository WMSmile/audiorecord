//
//  BBHoldToSpeakButton.swift
//  audiorecord
//
//  Created by apple on 2017/10/25.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit
//按钮的状态
@objc enum WMVoiceRecordState:Int {
    case normal          //初始状态
    case recording       //正在录音
    case willToCancel    //上滑取消（也在录音状态，UI显示有区别）
    case recordCounting  //最后10s倒计时（也在录音状态，UI显示有区别）
    case recordTooShort  //录音时间太短（录音结束了）
}
//事件的状态
@objc enum WMVoiceRecordEventState:Int {
    case start          //初始状态
    case normalEnd      //正常结束
    case cancelEnd      //取消结束
}
///delegate
@objc protocol WMHoldToSpeakButtonDelegate :NSObjectProtocol{
    //MARK:- buttonState callback
    @objc optional func buttonStatusChanged(_ buttonState:WMVoiceRecordState) -> Void
    //MARK:- buttonEventState callback
    @objc optional func buttonEventStatusChanged(_ buttonEventState:WMVoiceRecordEventState) -> Void
}

///
class WMHoldToSpeakButton: UIButton {
    /// 定时器
    var timer:Timer?
    /// 录音时间
    var totalTime:Int = 0;
    /// 最大的时间
    var maxTime:Int = 60;
    /// 最短的时间
    var minTime:Int = 2;
    
    weak var delegate:WMHoldToSpeakButtonDelegate?

    /// 按钮的状态
    var buttonState:WMVoiceRecordState?
    {
        didSet{
            self.buttonStateChange()
        }
    }
    
    /// 按钮事件的状态
    var buttonEventState:WMVoiceRecordEventState?
    {
        didSet{
            self.buttonEventStateChange()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        initViews();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews();
    }
    
    //MARK:- 初始化数据
    func initViews() -> Void {
        //添加长按手势
        let longpress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGesture(sender:)));
        longpress.minimumPressDuration = 0.5;//长按的开始的最小间隔
        longpress.numberOfTouchesRequired = 1;
        self.addGestureRecognizer(longpress);
        //正常模式
        self.updateRecordStyle(.normal);
        
    }

    //MARK:- 更改按钮的状态
    func updateRecordStyle(_ state:WMVoiceRecordState) -> Void {
        
        var titleStr = "长按录音";
        var image = UIImage.imageWithColor(color: UIColor.white, size: CGSize(width: 1, height: 1));

        if state == .recording{
            titleStr = "正在录音...";
            image = UIImage.imageWithColor(color: UIColor.colorWithHex(hexValue: 0xC6C7CA), size: CGSize(width: 1, height: 1));
        }
        else if (state == .willToCancel){
            titleStr = "取消录音";
            image = UIImage.imageWithColor(color: UIColor.colorWithHex(hexValue: 0xC6C7CA), size: CGSize(width: 1, height: 1));
        }
        else if (state == .recordCounting)
        {
            titleStr = "正在录音...";
            image = UIImage.imageWithColor(color: UIColor.colorWithHex(hexValue: 0xC6C7CA), size: CGSize(width: 1, height: 1));
        }
        self.setTitle(titleStr, for: .normal);
        self.setBackgroundImage(image, for: .normal);
        
    }
    
    //MARK:-
    func longPressGesture(sender:UIGestureRecognizer) -> Void {
        let point:CGPoint = sender.location(in: self);
        print("\(point)");
        if self.totalTime >= maxTime {
            return;
        }
        switch sender.state {
        case .began:
            print(">>>>start");
            self.buttonState = WMVoiceRecordState.recording
            self.buttonEventState = WMVoiceRecordEventState.start;
            self.startTimer();//开始计时
        case .ended:
            print(">>>>>>ended");
            self.buttonState = WMVoiceRecordState.normal
            self.endTimer();//结束定时
            if point.y < 0 || point.y > self.frame.size.height{
                print("cancelStatus");
                self.buttonEventState = WMVoiceRecordEventState.cancelEnd;
            }else {
                print("normalStatus");
                if self.totalTime < self.minTime
                {
                    self.buttonEventState = WMVoiceRecordEventState.cancelEnd;
                }
                else {
                    self.buttonEventState = WMVoiceRecordEventState.normalEnd;
                }
                
            }
        case .changed:
            print(">>>>>>changed");
            if point.y < 0 {
                print("up>>>>>");
                self.buttonState = WMVoiceRecordState.willToCancel
            }
            else if point.y > self.frame.size.height{
                print("down>>>>>>>")
                self.buttonState = WMVoiceRecordState.willToCancel
            }
            else {
                self.buttonState = WMVoiceRecordState.recording
            }
        default:
            break
        }
    }
    //MARK:- 按钮状态的改变
    func buttonStateChange() -> Void {
        self.updateRecordStyle(self.buttonState!);
        if self.delegate != nil && (self.delegate?.responds(to: #selector(WMHoldToSpeakButtonDelegate.buttonStatusChanged(_:))))! {
            self.delegate?.buttonStatusChanged!(self.buttonState!);
        }

    }
    //MARK:- 按钮事件的改变
    func buttonEventStateChange() -> Void {
        
        if self.delegate != nil && (self.delegate?.responds(to: #selector(WMHoldToSpeakButtonDelegate.buttonEventStatusChanged(_:))))! {
            self.delegate?.buttonEventStatusChanged!(self.buttonEventState!);
        }
    }

    
    //MARK:- 启动定时器
    func startTimer() -> Void {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTime), userInfo: nil, repeats: true);
            self.totalTime = 0;
        }
    }
    
    //MARK:- 结束定时器
    func endTimer() -> Void {
        if self.timer != nil {
            self.timer?.invalidate();
            self.timer = nil;
        }
    }
    
    //MARK:- 定时器累计
    func calculateTime() -> Void {
        self.totalTime += 1;
        print("time.......");
        if totalTime >= self.maxTime {
            print("time out end");
            self.buttonEventState = WMVoiceRecordEventState.normalEnd;
            self.buttonState = WMVoiceRecordState.normal;
        }
    }





    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}




