//
//  XcfHomeTestSuite.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-9.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "XcfHomeTestSuite.h"

@implementation XcfHomeTestSuite

- (void)setup
{
}

- (void)teardown
{
}

- (void)testSearch
{
    [self assert:[self hasFeature:@"placeholder"]];
    [self tapFeature:@"placeholder"];
    [self delay:3];
    [self assert:[self hasFeature:@"cancel_search"]];
    [self tapFeature:@"cancel_search"];
    [self delay:3];
}

- (void)testMenu
{
    [self assert:[self hasFeature:@"menu"]];
    [self tapFeature:@"menu"];
    [self delay:3];
    [self assert:[self hasFeature:@"xcf_textlogo"]];
    [self tapPoint:CGPointMake(290, 30)];// go back
    [self delay:3];
}

- (void)testHotDish
{
    [self assert:[self hasFeature:@"hotdish"]];
    [self tapFeature:@"hotdish"];
    [self delay:3];
    [self assert:[self hasFeature:@"hotdish_refresh"]];
    [self assert:[self hasFeature:@"goback_button"]];
    [self tapFeature:@"goback_button"];
    [self delay:3];
    [self assert:[self hasFeature:@"menu"]];
    [self assert:[self hasFeature:@"dailyhotspot"]];
}

- (void)testError
{
    [self assert:NO];
}

@end
