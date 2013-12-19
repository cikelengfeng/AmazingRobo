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

@interface ARTestRunner : NSObject

- (instancetype)initWithTestEngine:(ARTestEngine *)engine;

- (void)run;

- (void)stop;

+ (NSArray *)getAllTestClasses;

@end
