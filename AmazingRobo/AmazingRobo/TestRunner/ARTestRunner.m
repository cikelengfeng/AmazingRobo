//
//  ARTestRunner.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-18.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "ARTestRunner.h"
#import "objc/runtime.h"

@interface ARTestRunner ()

@property (strong,nonatomic) ARTestEngine *engine;
@property (strong,nonatomic) NSArray *suiteClasses;

+ (NSArray *)getSubclassArrayOfClass:(Class)class;

@end

@implementation ARTestRunner

- (instancetype)initWithTestEngine:(ARTestEngine *)engine
{
    self = [super init];
    if (self) {
        _engine = engine;
        _suiteClasses = [ARTestRunner getAllTestClasses];
    }
    return self;
}

- (void)run
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0l), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.delegate testRunnerStartRunning:weakSelf];
        });
        for (Class suiteClass in self.suiteClasses) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.delegate testRunner:weakSelf startTestSuite:suiteClass];
            });
            ARTestSuite *suite = [[suiteClass alloc]initWithTestEngine:self.engine];
            unsigned int methodCount ;
            Method *allMethods = class_copyMethodList(suiteClass, &methodCount);
            [suite setup];
            for (int i = 0; i < methodCount; i++) {
                Method *method = &allMethods[i];
                SEL selector = method_getName(*method);
                NSString *selString = NSStringFromSelector(selector);
                NSException *exc = nil;
                if ([selString hasPrefix:@"test"]) {
                    @try {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate testRunner:weakSelf startTestMethod:selector inTestSuite:suiteClass];
                        });
                        [suite performSelector:selector onThread:[NSThread currentThread] withObject:Nil waitUntilDone:YES];
                        NSLog(@"method : %@ of %s is successed",selString,class_getName(suiteClass));
                    }
                    @catch (NSException *exception) {
                        NSLog(@"method : %@ of %s is failed",selString,class_getName(suiteClass));
                        exc = exception;
                    }
                    @finally {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate testRunner:weakSelf finishTestMethod:selector exception:exc inTestSuite:suiteClass];
                        });
                    }
                }
            }
            [suite teardown];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.delegate testRunner:weakSelf finishTestSuite:suiteClass];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.delegate testRunnerStopRunning:weakSelf];
        });
    });
}

- (void)stop
{
    
}

+ (NSArray *)getAllTestClasses
{
    return [self getSubclassArrayOfClass:[ARTestSuite class]];
}

+ (NSArray *)getSubclassArrayOfClass:(Class)class
{
    int numClasses;
    Class * classes = NULL;
    
    numClasses = objc_getClassList(NULL, 0);
    NSMutableArray *result ;
    if (numClasses > 0 )
    {
        result = [NSMutableArray array];
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0 ; i < numClasses; i++) {
            Class clazz = classes[i];
            if (class_getSuperclass(clazz) == class) {
                [result addObject:clazz];
            }
        }
        free(classes);
    }
    return result;
}

@end
