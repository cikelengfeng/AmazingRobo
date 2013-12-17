//
//  DXFeatureFinder.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-2.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXFeatureFinder : NSObject

+ (CGRect)findFeature:(NSImage *)feature inImage:(NSImage *)image min:(double *)min max:(double *)max  method:(int *)method;

+ (CGRect)findFeature:(NSImage *)feature inImage:(NSImage *)image;

+ (NSImage *)resultFromFeature:(NSImage *)feature inImage:(NSImage *)image;

+ (NSImage *)imageFromImage:(NSImage *)img;

@end
