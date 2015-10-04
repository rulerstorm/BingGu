//
//  HMAudioTool.m
//  01-音效播放
//
//  Created by apple on 14/11/7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation HMAudioTool

static NSMutableDictionary *_soundIDs;
/*
+ (void)initialize
{
    _soundIDs = [NSMutableDictionary dictionary];
}
 */

+ (NSMutableDictionary *)soundIDs
{
    if (!_soundIDs) {
        _soundIDs = [NSMutableDictionary dictionary];
    }
    return _soundIDs;
}

+ (void)playAudioWithFilename:(NSString *)filename
{
    /*
    // -1.创建URL
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    
    // 0.创建音效ID
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
    
    // 1.播放音效(本地音效)
#warning ios8的模拟器不支持播放音效(真机可以)
    AudioServicesPlaySystemSound(soundID);
     */
    // 0.判断文件名是否为nil
    if (filename == nil) {
        return;
    }
    
    // 1.从字典中取出音效ID
    SystemSoundID soundID = [[self soundIDs][filename] unsignedIntValue];
    
    // 判断音效ID是否为nil
    if (!soundID) {
        NSLog(@"创建新的soundID");
        
        // 音效ID为nil
        // 根据文件名称加载音效URL
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        
        // 判断url是否为nil
        if (!url) {
            return;
        }
        
        // 创建音效ID
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        
        // 将音效ID添加到字典中
        [self soundIDs][filename] = @(soundID);
    }
    // 播放音效
    AudioServicesPlaySystemSound(soundID);
}

+ (void)disposeAudioWithFilename:(NSString *)filename
{
    // 0.判断文件名是否为nil
    if (filename == nil) {
        return;
    }
    
    // 1.从字典中取出音效ID
    SystemSoundID soundID = [[self soundIDs][filename] unsignedIntValue];
    
    if (soundID) {
        // 2.销毁音效ID
        AudioServicesDisposeSystemSoundID(soundID);
        
        // 3.从字典中移除已经销毁的音效ID
        [[self soundIDs] removeObjectForKey:filename];
    }
  
}
@end
