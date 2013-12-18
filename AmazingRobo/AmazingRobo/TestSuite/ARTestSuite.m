//
//  DXTestSuite.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-9.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "ARTestSuite.h"

@interface ARTestSuite ()

@property (strong,nonatomic) ARTestEngine *engine;

@end

@implementation ARTestSuite

- (instancetype)initWithTestEngine:(ARTestEngine *)engine
{
    self = [super init];
    if (self) {
        _engine = engine;
    }
    return self;
}

@end
