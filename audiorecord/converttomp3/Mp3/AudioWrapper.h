//
//  AudioWrapper.h
//  tomp3
//
//  Created by apple on 2017/8/8.
//  Copyright © 2017年 wumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioWrapper : NSObject
//自动获取采用率
+ (void)convertFromWavToMp3:(NSString *)filePath  mp3FilePath:(NSString *)mp3FilePath;
//采样率手动
+ (void)convertFromWavToMp3:(NSString *)filePath  mp3FilePath:(NSString *)mp3FilePath sampleRateKey:(int)sampleRate;
@end
