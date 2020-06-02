//
//  main.m
//  YHHookLoadOC
//
//  Created by 吴云海 on 2020/5/28.
//  Copyright © 2020 YH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

FOUNDATION_IMPORT void LoadRulerPrintLoadCostsInfo();

int main(int argc, char * argv[]) {
    
    LoadRulerPrintLoadCostsInfo();
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
