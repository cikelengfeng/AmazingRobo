//
//  DXTouchCommand.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-26.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXTouchCommand.h"

@interface DXTouchCommand ()

@property (readwrite,nonatomic) CommandType pType;
@property (readwrite,nonatomic,copy) NSArray *pBeganPoints;
@property (readwrite,nonatomic,copy) NSArray *pEndedPoints;
@property (readwrite,nonatomic) NSTimeInterval pDuration;

@end

NSDictionary * touchPointFromCGPoint(CGPoint p)
{
    return touchPointMake(p.x, p.y);
}

NSDictionary * touchPointFromNSPoint(NSPoint p)
{
    return touchPointMake(p.x, p.y);
}

@implementation DXTouchCommand

- (instancetype)initWithType:(CommandType)type beganPoints:(NSArray *)bps endedPoints:(NSArray *)eps duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self) {
        _pType = type;
        if (bps.count > 0 && eps.count > 0) {
            _pBeganPoints = [bps copy];
            _pEndedPoints = [eps copy];
        }else {
            [NSException raise:@"EmptyTouchPointArrayException" format:@"beganPointArray or endedPointArray is empty"];
            return nil;
        }
        if (duration > 0) {
            _pDuration = duration;
        }else {
            [NSException raise:@"DurationNotPostiveException" format:@"duration : %f is nagetive",duration];
            return nil;
        }
    }
    return self;
}

@end

@implementation DXTouchCommand (JSON)

- (NSString *)toJSONString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = @(self.pType);
    dict[@"beganPoints"] = self.pBeganPoints;
    dict[@"endedPoints"] = self.pEndedPoints;
    dict[@"duration"] = @(self.pDuration);
    return [dict JSONString];
}

@end
