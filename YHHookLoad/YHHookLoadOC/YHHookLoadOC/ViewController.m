//
//  ViewController.m
//  YHHookLoadOC
//
//  Created by 吴云海 on 2020/5/28.
//  Copyright © 2020 YH. All rights reserved.
//

#import "ViewController.h"
#include <pthread.h>

static pthread_mutex_t mutex;
static pthread_cond_t condition;
static int mutexNum = 0;



@interface ViewController ()

@property(nonatomic,strong) dispatch_queue_t queue;

@end

@implementation ViewController

+ (void)load {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&condition, NULL);
    
    _queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self showConditionLock];
//    [self showConditionUnLock];
    
    sleep(1);
//    [self showMuteLock];
    
    dispatch_async(_queue, ^{
        [self showMuteLock];
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
//        [[NSRunLoop currentRunLoop] run];//维系该线程，一直运行
        [self showCurrentTime];
        sleep(1);
        [self performSelector:@selector(showCurrentTime)];
        sleep(1);
        [self performSelector:@selector(showCurrentTime) withObject:nil afterDelay:0];
        
//        [NSRunLoop currentRunLoop] 
    });
}

- (void)showCurrentTime{
    NSLog(@"showCurrentTime");
}

- (void)showMuteLock {
    pthread_mutex_lock(&mutex);
    sleep(1);
    NSLog(@"xxxxxxx == %d",mutexNum);
    mutexNum++;
    pthread_mutex_unlock(&mutex);
}

-(void)showConditionLock {
    while (mutexNum == 0) {
        NSLog(@"mutexNum == 0");
        pthread_cond_wait(&condition, &mutex);
    }
    
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&condition);
}

-(void)showConditionUnLock {
    sleep(3);
    mutexNum--;
    pthread_cond_signal(&condition);
}
@end
