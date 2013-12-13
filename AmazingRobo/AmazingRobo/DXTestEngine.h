//
//  DXTestEngine.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-9.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "DXTouchCommand.h"

@class DXTestEngine;
@protocol DXTestEngineDelegate <NSObject>

- (void)testEngine:(DXTestEngine *)engine hasNewScreenShot:(NSImage *)screenshot;
- (void)testEngine:(DXTestEngine *)engine hasNewMatchResult:(NSImage *)result;

@end

@interface DXTestEngine : NSObject<GCDAsyncSocketDelegate>

@property (weak,nonatomic) id<DXTestEngineDelegate> delegate;

- (void)start;

- (void)tapPoint:(CGPoint)point;
- (void)tapFeature:(NSString *)featureName;
- (void)sendTouchCommand:(DXTouchCommand *)command;

- (CGPoint)findFeature:(NSImage *)feature;
- (CGPoint)findFeatureByName:(NSString *)featureName;
- (BOOL)hasFeature:(NSString *)featureName;

@end
