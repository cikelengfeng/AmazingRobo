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

@end

@implementation ARTestRunner

- (instancetype)initWithTestEngine:(ARTestEngine *)engine testSuiteClasses:(NSArray *)suiteClasses
{
    self = [super init];
    if (self) {
        _engine = engine;
        _suiteClasses = suiteClasses;
    }
    return self;
}

- (void)run
{
    for (Class suiteClass in self.suiteClasses) {
        ARTestSuite *suite = [[suiteClass alloc]initWithTestEngine:self.engine];
        unsigned int methodCount ;
        Method *allMethods = class_copyMethodList(suiteClass, &methodCount);
        for (int i = 0; i < methodCount; i++) {
            Method *method = &allMethods[i];
            SEL selector = method_getName(*method);
            NSString *selString = NSStringFromSelector(selector);
            if ([selString hasPrefix:@"test"]) {
                [suite performSelector:selector];
                NSLog(@"method : %@ of suite %@ is under testing",selString,suite);
            }
        }
    }
}

- (void)stop
{
    
}

@end
