//
//  RCVoiceMessage.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"

/**
    声音消息
 */
@interface RCVoiceMessage : RCMessageContent
/** 音频原始数据 */
@property(nonatomic, strong) NSData* wavAudioData;
/** 时长 */
@property(nonatomic, assign) long duration;
/**
    由指定信息创建声音消息实例
 
    @param  audioData   音频数据
    @param  duration    时长
 */
+(instancetype)messageWithAudio:(NSData *)audioData
                       duration:(long)duration;
@end
