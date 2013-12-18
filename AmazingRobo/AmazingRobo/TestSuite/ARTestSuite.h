//
//  DXTestSuite.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-9.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARTestEngine.h"

/**
 *该类负责存放所有测试方法
 *使用方法：子类化该类，所有的测试方法都应该以"test"（小写）开头，无返回值。
 *每一个子类应该对应一个逻辑页面的相关UI测试
 **/
@interface ARTestSuite : NSObject

-(instancetype)initWithTestEngine:(ARTestEngine *)engine;

- (void)setup;

- (void)teardown;

@end
