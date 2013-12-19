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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0l), ^{
        for (Class suiteClass in self.suiteClasses) {
            ARTestSuite *suite = [[suiteClass alloc]initWithTestEngine:self.engine];
            unsigned int methodCount ;
            Method *allMethods = class_copyMethodList(suiteClass, &methodCount);
            [suite setup];
            for (int i = 0; i < methodCount; i++) {
                Method *method = &allMethods[i];
                SEL selector = method_getName(*method);
                NSString *selString = NSStringFromSelector(selector);
                if ([selString hasPrefix:@"test"]) {
                    @try {
                        [suite performSelector:selector onThread:[NSThread currentThread] withObject:Nil waitUntilDone:YES];
                        NSLog(@"method : %@ of %s is successed",selString,class_getName(suiteClass));
                    }
                    @catch (NSException *exception) {
                        NSLog(@"method : %@ of %s is failed",selString,class_getName(suiteClass));
                    }
                    @finally {
                        
                    }
                }
            }
            [suite teardown];
        }
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
