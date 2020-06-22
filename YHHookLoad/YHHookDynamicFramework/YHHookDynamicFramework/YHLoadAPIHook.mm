//
//  YHLoadAPIHook.m
//  YHHookDynamicFramework
//
//  Created by 吴云海 on 2020/5/28.
//  Copyright © 2020 YH. All rights reserved.
//

#import "YHLoadAPIHook.h"
#include <vector>
#include <string>
#include <mach-o/dyld.h>
#import <objc/message.h>
#include <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


// 获取所有加载的macho
static void AppendAllImagePaths(std::vector<std::string>& image_paths) {
    uint32_t imageCount = _dyld_image_count();
    for(uint32_t imageIndex = 0; imageIndex < imageCount; ++imageIndex){
        const char * path = _dyld_get_image_name(imageIndex);
        image_paths.push_back(std::string(path));
    }
}

// 打印所有加载的macho path
static void AppendProductImagePaths(std::vector<std::string> & product_image_paths) {
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    std::vector<std::string> all_image_paths;
    AppendAllImagePaths(all_image_paths);
    for(auto path: all_image_paths){
        NSString *imagePath = [NSString stringWithUTF8String:path.c_str()];
        
        if([imagePath containsString:mainBundlePath] ||[imagePath containsString:@"Build/Products/"]){
            product_image_paths.push_back(path);
            NSLog(@"%@", imagePath);
        }
    }
}

// 获取当前产品自动链接的所有macho
static void PrintAllImagePaths() {
    std::vector<std::string> image_paths;
    AppendAllImagePaths(image_paths);
    for(auto path: image_paths){
        NSLog(@"%s",path.c_str());
    }
    
    return;
    
    int numClasses;
    Class * classes = NULL;
    
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 ) {
        classes = (Class*)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        for(int idx = 0; idx < numClasses; ++idx) {
            Class cls = *(classes + idx);
            
            const char *className = object_getClassName(cls);
            Class metaCls = objc_getMetaClass(className);
            
            BOOL hasLoad = NO;
            unsigned int methodCount = 0;
            
            Method *methods = class_copyMethodList(metaCls, & methodCount);
            
            if(methods){
                for(int j = 0; j < methodCount; ++j) {
                    Method method = *(methods + j);
                    SEL name = method_getName(method);
                    NSString *methodName = NSStringFromSelector(name);
                    
                    if([methodName isEqualToString:@"load"]){
                        hasLoad = YES;
                        break;
                    }
                }
            }
            
            if(hasLoad){
                NSLog(@"has load : %@", NSStringFromClass(cls));
            } else {
                //                NSLog(@"not has load : %@", NSStringFromClass(cls));
            }
        }
    }
    
    free(classes);
}

static NSMutableArray<NSString*> *g_loadcosts;


#define LoadRulerBegin \
    NSLog(@">>>> before");\
//    CFTimeInterval begin = CACurrentMediaTime();

#define LoadRulerEnd \
//    CFTimeInterval end = CACurrentMediaTime();\
    if(!g_loadcosts){\
    g_loadcosts = [[NSMutableArray alloc]initWithCapacity:10];\
    }\
//    [g_loadcosts addObject:[NSString stringWithFormat:@"%@ - %@ms",NSStringFromClass([self class]), @(1000 * (end - begin))]];\
    NSLog(@"<<<< after");

@interface YHLoadAPIHook : NSObject
@end

@implementation YHLoadAPIHook

+(void)LoadRulerSwizzledLoad0{
    NSLog(@">>>> before");
//    LoadRulerBegin;
//        CFTimeInterval begin = CACurrentMediaTime();
    [self LoadRulerSwizzledLoad0];
//    LoadRulerEnd
//        CFTimeInterval end = CACurrentMediaTime();
    //    if(!g_loadcosts){
    //    g_loadcosts = [[NSMutableArray alloc]initWithCapacity:10];
    //    }
    //    [g_loadcosts addObject:[NSString stringWithFormat:@"%@ - %@ms",NSStringFromClass([self class]), @(1000 * (end - begin))]];
//    NSLog(@"<<<< after");
}

+(void)LoadRulerSwizzledLoad1{
    //    LoadRulerBegin;
    [self LoadRulerSwizzledLoad1];
    //    LoadRulerEnd;
}
+(void)LoadRulerSwizzledLoad2{
    //    LoadRulerBegin;
    [self LoadRulerSwizzledLoad2];
    //    LoadRulerEnd;
}
+(void)LoadRulerSwizzledLoad3{
    //    LoadRulerBegin;
    [self LoadRulerSwizzledLoad3];
    //    LoadRulerEnd;
}
+(void)LoadRulerSwizzledLoad4{
    //    LoadRulerBegin;
    [self LoadRulerSwizzledLoad4];
    //    LoadRulerEnd;
}

+ (void)load {
    
    //    PrintAllImagePaths();
    
    SEL originalSelector = @selector(load);
    Class hookClass = object_getClass(NSClassFromString(@"YHLoadAPIHook"));
    
    std::vector<std::string> product_image_paths;
    AppendProductImagePaths(product_image_paths);
    
    for (auto path : product_image_paths) {
        unsigned int classCount = 0;
        const char ** classNames = objc_copyClassNamesForImage(path.c_str(),&classCount);
        
        for(unsigned int classIndex = 0; classIndex < classCount; ++classIndex){
            NSString *className = [NSString stringWithUTF8String:classNames[classIndex]];
            Class cls = object_getClass(NSClassFromString(className));
            
            // 不要把自己hook了
            if(cls == hookClass ){
                continue;
            }
            
            unsigned int methodCount = 0;
            Method * methods = class_copyMethodList(cls, &methodCount);
            NSUInteger currentLoadIndex = 0;
            
            for(unsigned int methodIndex = 0; methodIndex < methodCount; ++methodIndex){
                Method method = methods[methodIndex];
                std::string methodName(sel_getName(method_getName(method)));
                
                if(methodName == "load") {
                    SEL swizzledSelector = NSSelectorFromString([NSString stringWithFormat:@"LoadRulerSwizzledLoad%@",@(currentLoadIndex)]);
                    Method originalMethod = method;
                    Method swizzledMethod = class_getClassMethod(hookClass, swizzledSelector);
                    
                    BOOL addSuccess = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
                    // 添加成功，则说明不存在load。但动态添加的load，不会被调用。与load的调用方式有关。
                    if(!addSuccess) {
                        // 已经存在，则添加新的selector
                        BOOL didAddSuccess = class_addMethod(cls, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
                        
                        if(didAddSuccess){
                            // 然后交换
                            swizzledMethod = class_getClassMethod(cls, swizzledSelector);
                            method_exchangeImplementations(originalMethod, swizzledMethod);
                        }
                    }
                    ++currentLoadIndex;
                }
            }
        }
        
    }
    
    
}




@end


extern "C"
void LoadRulerPrintLoadCostsInfo(){
    NSLog(@">> all load cost info below :");
    for(NSString *costInfo in g_loadcosts){
        NSLog(@"%@",costInfo);
    }
}

