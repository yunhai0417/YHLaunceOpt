//
//  ViewController.h
//  YHHookLoadOC
//
//  Created by 吴云海 on 2020/5/28.
//  Copyright © 2020 YH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXViewController.h"


//CHDeclareClass(ViewController)
//
//CHClassMethod0(void, ViewController, load){
//    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
//    
//    CHSuper0(ViewController,load);
//    
//    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
////     output: end - start
//    NSLog(@"@f",end - start);
//}
//
//__attribute__((constructor)) static void entry(){
//    NSLog(@"dylib loaded");
//    
//    CHLoadLateClass(ViewController);
//    CHHook0(ViewController, load);
//}

@interface ViewController : UIViewController


@end

