//
//  LameTool.h
//  YiChatIOSAndH5
//
//  Created by Netinfo_Mac on 2020/9/29.
//  Copyright © 2020 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LameTool : NSObject

+(NSString *)tg_audioToMP3:(NSString *)wavSourcePath isDeleteSourchFile: (BOOL)isDelete;

@end

NS_ASSUME_NONNULL_END
