//
//  ViewController.m
//  YHCamera
//
//  Created by 吴云海 on 2020/6/22.
//  Copyright © 2020 YH. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

//摄像头输入
@property(nonatomic, strong) AVCaptureDeviceInput   *cameraInput;
//麦克风输入
@property(nonatomic, strong) AVCaptureDeviceInput   *audioMicInput;
//捕获视频的会话
@property(nonatomic, strong) AVCaptureSession       *recordSession;

@property (copy  , nonatomic) dispatch_queue_t       captureQueue;//录制的队列


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//捕获视频的会话
-(AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        //添加后置摄像头的输出
        
    }
    
    return _recordSession;
}

//摄像头设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    
    return nil;
}


//摄像头输入
-(AVCaptureDeviceInput *)cameraInput {
    if (_cameraInput == nil) {
        NSError *error;
        _cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:&error];
    }
    return _cameraInput;
}

//麦克风输入
-(AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
    }
    return _audioMicInput;
}

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create(0, 0);
    }
    return _captureQueue;
}


@end
