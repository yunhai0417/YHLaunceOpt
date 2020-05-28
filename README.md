# YHLaunceOpt
项目分析iOS项目启动流程，并设计优化方向

# AppleTrace 性能分析工具
# https://everettjf.github.io/2017/09/21/appletrace/

# 局限性 手动对方法添加 APTBeginSection 和 APTEndSection 截取方法的开始和结束时间

# Hook objc_msgSend

# pre-main load方法加载简介
/**
*	All initializers in any framework you link to. // 在你所链接的任何框架中的所有初始化器
*	All +load methods in your image. // 在你镜像中的所有 +load方法
*	All C++ static initializers and C/C++ __attribute__(constructor) functions in your image. // 在你镜像中的所有C++静态初始化器和C/C++ __attribute__(constructor) 函数
*	All initializers in frameworks that link to you. 所有链接到你程序的框架中的初始化器
*	————————————————
*	A class’s +load method is called after all of its superclasses’+load methods. // 类的+load方法在所有父类的+load方法调用之后调用
*	A category +load method is called after the class’s own+load method. // 分类的+load方法在类的+load方法调用之后调用
*/


# 先看Objective C Runtime
/***********************************************************************
* call_class_loads
* Call all pending class +load methods.
* If new classes become loadable, +load is NOT called for them.
*
* Called only by call_load_methods().
**********************************************************************/
static void call_class_loads(void)
{
    int i;
    
    // Detach current loadable list.
    struct loadable_class *classes = loadable_classes;
    int used = loadable_classes_used;
    loadable_classes = nil;
    loadable_classes_allocated = 0;
    loadable_classes_used = 0;
    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Class cls = classes[i].cls;
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue; 
		if (PrintLoading) {
            _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
        }
        (*load_method)(cls, SEL_load);
    }
    
    // Destroy the detached list.
    if (classes) free(classes);
}

## Hook load

/*
 * 由于+load方法调用时机已经很早，早于 C++ static initializer等，但晚于framework（动态库），
 * 那我们就可以把hook的代码写到动态库中，也就可以做到在主程序的 loadable_classes 全局变量初始化之前就把+load hook掉
 *
 */



