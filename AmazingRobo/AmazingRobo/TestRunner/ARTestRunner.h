//
//  ARTestRunner.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-18.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARTestEngine.h"
#import "ARTestSuite.h"

@class ARTestRunner;

@protocol ARTestRunnerDelegate <NSObject>

- (void)testRunnerStartRunning:(ARTestRunner *)runner;
- (void)testRunnerStopRunning:(ARTestRunner *)runner;
- (void)testRunner:(ARTestRunner *)runner startTestSuite:(Class)testSuiteClass;
- (void)testRunner:(ARTestRunner *)runner finishTestSuite:(Class)testSuiteClass;
- (void)testRunner:(ARTestRunner *)runner startTestMethod:(SEL)selector inTestSuite:(Class)testSuiteClass;
- (void)testRunner:(ARTestRunner *)runner finishTestMethod:(SEL)selector exception:(NSException *)exc inTestSuite:(Class)testSuiteClass;

@end

@interface ARTestRunner : NSObject

@property (weak,nonatomic) id<ARTestRunnerDelegate> delegate;

- (instancetype)initWithTestEngine:(ARTestEngine *)engine;


- (void)run;

- (void)stop;

+ (NSArray *)getAllTestClasses;

@end
