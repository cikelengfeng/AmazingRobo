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

#pragma mark - setup & teardown

- (void)setup
{
    
}

- (void)teardown
{
    
}

#pragma mark - test API

- (void)tapPoint:(CGPoint)point
{
    [self.engine tapPoint:point];
}

- (void)tapFeature:(NSString *)featureName
{
    [self.engine tapFeature:featureName];
}

- (void)sendTouchCommand:(DXTouchCommand *)command
{
    [self.engine sendTouchCommand:command];
}

- (CGRect)findFeature:(NSImage *)feature
{
    return [self.engine findFeature:feature];
}

- (CGRect)findFeatureByName:(NSString *)featureName
{
    return [self.engine findFeatureByName:featureName];
}

- (BOOL)hasFeature:(NSString *)featureName
{
    return [self.engine hasFeature:featureName];
}

- (void)assert:(BOOL)assertion
{
    if (!assertion) {
        [NSException raise:@"assertion failed" format:@""];
    }
}

- (void)delay:(NSTimeInterval)delay
{
    [NSThread sleepForTimeInterval:delay];
}

@end
