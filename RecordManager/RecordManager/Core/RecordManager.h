//
//  RecordManager.h
//  YiChatIOSAndH5
//
//  Created by Netinfo_Mac on 2020/9/24.
//  Copyright © 2020 Netinfo_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface RecordManager : NSObject


+(instancetype)sharedManager;

-(void)startRecordWithCompleted:(void(^)(BOOL isCanRecord))completed;

-(void)stopRecordWithCompleted:(void (^)(NSString * _Nullable recordFilePath, long elpased,NSString * _Nullable base64Str))completed;


-(void)playRecordWithFilePath:(NSString *)filePath;



@end

NS_ASSUME_NONNULL_END
