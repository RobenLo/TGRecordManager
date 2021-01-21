//
//  ViewController.m
//  RecordManager
//
//  Created by Roben on 2021/1/21.
//

#import "ViewController.h"
#import "RecordManager.h"

@interface ViewController ()

@property(nonatomic,copy)NSString *filePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startButtonClick:(UIButton *)sender
{
    
    [[RecordManager sharedManager] startRecordWithCompleted:^(BOOL isCanRecord) {
        
        if (!isCanRecord) {
            NSLog(@"未开启麦克风权限");
        }
        
    }];
    
}
- (IBAction)stopButtonClick:(UIButton *)sender
{

    __weak typeof(self) weakself = self;
    [[RecordManager sharedManager] stopRecordWithCompleted:^(NSString * _Nullable recordFilePath, long elpased, NSString * _Nullable base64Str) {
        
        NSLog(@"%@--%ld",recordFilePath,elpased);
        weakself.filePath = recordFilePath;
    }];
}

- (IBAction)playButtonClick:(UIButton *)sender {
    
    [[RecordManager sharedManager] playRecordWithFilePath:self.filePath];
}


@end
