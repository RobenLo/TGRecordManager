//
//  RecordManager.m
//  YiChatIOSAndH5
//
//  Created by Netinfo_Mac on 2020/9/24.
//  Copyright © 2020 Netinfo_Mac. All rights reserved.
//

#import "RecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LameTool.h"
static RecordManager *_manager = nil;

@interface RecordManager (){
    AVAudioSession      *_session;
    AVAudioRecorder     *_recorder;    //录音器
    AVAudioPlayer       *_player;      //音频播放器
    NSString            *_recordFilePath;     //录音文件沙盒地址
    
}

@end
@implementation RecordManager

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[RecordManager alloc] init];
    });
    return _manager;
}

-(void)startRecordWithCompleted:(void (^)(BOOL))completed{

    if ([self canRecord]) {
        completed(YES);
    }else{
        completed(NO);
        return;
    }
    _session = [AVAudioSession sharedInstance];
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [_session setActive:YES error:nil];

//    NSError *sessionError;
//    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
//
//    if (_session == nil) {
//        NSLog(@"Error creating session: %@",[sessionError description]);
//    } else {
//        [_session setActive:YES error:nil];
//    }

  
//    UInt32 doChangeDefault = 1;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);

    
    if ([_recorder isRecording]) {
        [_recorder stop];
        _recorder = nil;
    }
        
    //获取文件沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    _recordFilePath = [path stringByAppendingString:@"/Record.caf"];
    //设置参数
    
//    11025
//    NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
//                                    AVSampleRateKey: @11025.00f,
//                                    AVNumberOfChannelsKey: @2,
//                                    AVLinearPCMBitDepthKey: @32,
//                                //    AVLinearPCMIsNonInterleaved: @NO,
//                                    AVLinearPCMIsFloatKey: @YES,
//                                    AVLinearPCMIsBigEndianKey: @YES,
//                                    AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
//
//    };
//
    //设置参数
       NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                      [NSNumber numberWithFloat: 11025.0],AVSampleRateKey,
                                      // 音频格式
                                      [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                      //采样位数  8、16、24、32 默认为16
                                      [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                      // 音频通道数 1 或 2
                                      [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                      //录音质量
                                      [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                      nil];

      //开始录音
   //录音设置
//      NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
//        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
//         [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//       //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
//      [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
//    19     //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
//    20     [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//    21     //线性采样位数  8、16、24、32
//    22     [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    23     //录音的质量
//    24     [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];



    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordFilePath] settings:recordSetting error:nil];
    if (_recorder) {
//        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];

    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
}

-(void)stopRecordWithCompleted:(void (^)(NSString * _Nullable recordFilePath, long elpased,NSString * _Nullable base64Str))completed{
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    
    [_session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];

    [_session setActive:NO error:nil];

    float audioDurationSeconds  = [self audioTime];
 
    NSString *mp3FilePath = nil;
    NSString *base64Str = nil;
    if (_recordFilePath != nil) {
        mp3FilePath = [LameTool audioToMP3:_recordFilePath isDeleteSourchFile:YES];
        NSData *data = [NSData dataWithContentsOfFile:mp3FilePath];
        base64Str = [data base64EncodedStringWithOptions:0];
    }
    !completed?:completed(mp3FilePath,audioDurationSeconds,base64Str);
    _recorder = nil;
    _recordFilePath = nil;
    audioDurationSeconds = 0;
        
}

//播放录音
-(void)playRecordWithFilePath:(NSString *)filePath{
    
    if (filePath) {
        _player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:filePath] error:nil];
        [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_player play];
    }
    
}

-(NSString *)getNowTimeTimestamp{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;

}
//检查是否拥有麦克风权限
-(BOOL)canRecord{
    
   __block BOOL canRecord = NO;
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authorizationStatus == AVAuthorizationStatusNotDetermined) {// 未询问用户是否授权
        //第一次询问用户是否进行授权
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
//            if (granted) {
//                // Microphone enabled code
//                canRecord = granted;
//            }else {
//                // Microphone disabled code
//                canRecord = granted;
//            }
            canRecord = NO;
        }];
    }
    else if(authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) {//

        canRecord = NO;
        NSLog(@"未授权");
    }
    else{
         // 已授权
        canRecord = YES;
    }
    
    return canRecord;
}


//获取音频时长
-(long)audioTime{
    
    if (_recordFilePath) {
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:_recordFilePath] options:nil];
        CMTime audioDuration = audioAsset.duration;
        return CMTimeGetSeconds(audioDuration) * 1000;
    }else{
        return 0;
    }
    
}





@end


 









