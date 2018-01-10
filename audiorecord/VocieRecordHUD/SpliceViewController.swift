//
//  SpliceViewController.swift
//  audiorecord
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit

class SpliceViewController: UIViewController{
    
    var recording: Recording!
    var recordDuration = 0
    
    var tapToFinishBtn: UIButton!
    var durationLabel: UILabel!
    var voiceRecordHUD: VoiceRecordHUD!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clear;
        showViews();
//        createRecorder();
    }
    
    //MARK:- tap
    func tapclick(sender:Any) -> Void {
        self.dismiss(animated: true, completion: nil);
    }
    
    //MARK:- 显示view
    func showViews() -> Void {
        
        let fullView = UIView.init(frame: self.view.frame);
        fullView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.view.addSubview(fullView);
        
        //        self.initColleionView();
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapclick(sender:)));
        fullView.addGestureRecognizer(tap);
        
        
        self.voiceRecordHUD = VoiceRecordHUD.init(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        self.view.addSubview(voiceRecordHUD);
       
        
        self.tapToFinishBtn = UIButton.init(frame: CGRect.zero);
        self.durationLabel = UILabel.init();
        
        
        let _ = Timer.init(timeInterval: 0.1, repeats: true) { (timer) in
            self.audioMeterDidUpdate(Float(arc4random()%100/100))
        }
    }
    
    
    
//    open func createRecorder() {
//        recording = Recording(to: "recording.caf")
////        recording.delegate = self
//        
//        // Optionally, you can prepare the recording in the background to
//        // make it start recording faster when you hit `record()`.
//        
//        DispatchQueue.global().async {
//            // Background thread
//            do {
//                try self.recording.prepare()
//            } catch {
//                print(error)
//            }
//        }
//    }
//    
//    open func startRecording() {
//        recordDuration = 0
//        do {
//            try recording.record()
//        } catch {
//            print(error)
//        }
//    }
//    
//    func stop() {
//        
////        delegate?.didFinishRecording(self)
////        dismiss(animated: true, completion: nil)
//        
//        recordDuration = 0
//        recording.stop()
//        voiceRecordHUD.update(0.0)
//        
//    }
//    
//    func audioMeterDidUpdate(_ db: Float) {
//        print("db level: %f", db)
//        
//        self.recording.recorder?.updateMeters()
//        let ALPHA = 0.05
//        let peakPower = pow(10, (ALPHA * Double((self.recording.recorder?.peakPower(forChannel: 0))!)))
//        var rate: Double = 0.0
//        if (peakPower <= 0.2) {
//            rate = 0.2
//        } else if (peakPower > 0.9) {
//            rate = 1.0
//        } else {
//            rate = peakPower
//        }
//        
//        voiceRecordHUD.update(CGFloat(rate))
//        voiceRecordHUD.fillColor = UIColor.green
//        recordDuration += 1
//        durationLabel.text = String(recordDuration)
//    }
    
    func audioMeterDidUpdate(_ db: Float) {
        print("db level: %f", db)

//        self.recording.recorder?.updateMeters()
//        let ALPHA = 0.05
//        let peakPower = pow(10, (ALPHA * Double((self.recording.recorder?.peakPower(forChannel: 0))!)))
        let peakPower = db
        var rate: Double = 0.0;
        if (peakPower <= 0.2) {
            rate = 0.2
        } else if (peakPower > 0.9) {
            rate = 1.0
        } else {
            rate = Double(peakPower)
        }

        voiceRecordHUD.update(CGFloat(rate))
        voiceRecordHUD.fillColor = UIColor.green
        recordDuration += 1
        durationLabel.text = String(recordDuration)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        voiceRecordHUD.update(0.0)
        voiceRecordHUD.fillColor = UIColor.green
        durationLabel.text = ""
        
    }

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
