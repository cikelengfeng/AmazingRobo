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

@class ARTestEngine;
@protocol DXTestEngineDelegate <NSObject>

- (void)testEngine:(ARTestEngine *)engine hasNewScreenShot:(NSImage *)screenshot;
- (void)testEngine:(ARTestEngine *)engine hasNewMatchResult:(CGRect)result min:(double)min max:(double)max matchMethod:(int)method;

@end

@interface ARTestEngine : NSObject<GCDAsyncSocketDelegate>

@property (weak,nonatomic) id<DXTestEngineDelegate> delegate;
@property (strong,nonatomic,readonly) NSString *featurePath;
@property (strong,nonatomic,readonly) NSString *rootPath;
@property (strong,nonatomic,readonly) NSString *featureExtension;

- (void)start;

- (void)tapPoint:(CGPoint)point;
- (void)tapFeature:(NSString *)featureName;
- (void)sendTouchCommand:(DXTouchCommand *)command;

- (CGRect)findFeature:(NSImage *)feature;
- (CGRect)findFeatureByName:(NSString *)featureName;
- (BOOL)hasFeature:(NSString *)featureName;

- (NSString *)featurePathWithName:(NSString *)name;

@end
