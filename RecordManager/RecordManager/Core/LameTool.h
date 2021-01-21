//
//  LameTool.h
//  YiChatIOSAndH5
//
//  Created by Netinfo_Mac on 2020/9/29.
//  Copyright © 2020 Netinfo_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LameTool : NSObject
+ (NSString *)audioToMP3: (NSString *)sourcePath isDeleteSourchFile: (BOOL)isDelete;

@end

NS_ASSUME_NONNULL_END
