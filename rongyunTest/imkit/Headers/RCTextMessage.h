//
//  RCTextMessage.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"

/**
    文本消息类定义
 */
@interface RCTextMessage : RCMessageContent
/** 文本消息内容 */
@property(nonatomic, strong) NSString* content;
/**
    根据参数创建文本消息对象
    
    @param content  文本消息内容
 */
+(instancetype)messageWithContent:(NSString *)content;

@end
