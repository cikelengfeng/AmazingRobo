//
//  NSImageView+AddMask.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-3.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "NSImageView+AddMask.h"

@implementation NSImageView (AddMask)

- (void)addRetangleMaskWithRect:(CGRect)rect
{
//    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//    
//    //save the current graphics state
//    CGContextSaveGState(context);
//    
//    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0.0, 1.0); // yellow line
//    
//    CGContextBeginPath(context);
//    
//    CGContextAddRect(context, rect);
//    
//    CGContextClosePath(context); // close path
//    
//    CGContextSetLineWidth(context, 8.0); // this is set from now on until you explicitly change it
//    
//    CGContextStrokePath(context); // do actual stroking
//    
//    CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.5); // green color, half transparent
//    CGContextFillRect(context, CGRectMake(20.0, 250.0, 128.0, 128.0)); // a square at the bottom left-hand corner
//    
//    //restore the graphics state
//    CGContextRestoreGState(context);
    [[NSColor redColor] set];
    [NSBezierPath strokeRect:rect];
}

@end
