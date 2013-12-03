//
//  DXTouchCommand.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-26.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define touchPointMake(x,y) @{@"x":@(x),@"y":@(y)}

NSString * touchPointFromCGPoint(CGPoint p);

typedef NS_OPTIONS(NSUInteger, CommandType) {
    CommandTap = 0,
    CommandPan = 1
};

@interface DXTouchCommand : NSObject

//all params MUST NOT be nil,arrays MUST NOT be empty,duration MUST be postive
- (instancetype)initWithType:(CommandType)type beganPoints:(NSArray *)bps endedPoints:(NSArray *)eps duration:(NSTimeInterval)duration;

@property (readonly,nonatomic) CommandType pType;
@property (readonly,nonatomic,copy) NSArray *pBeganPoints;
@property (readonly,nonatomic,copy) NSArray *pEndedPoints;
@property (readonly,nonatomic) NSTimeInterval pDuration;

@end

@interface DXTouchCommand (JSON)

- (NSString *)toJSONString;

@end


