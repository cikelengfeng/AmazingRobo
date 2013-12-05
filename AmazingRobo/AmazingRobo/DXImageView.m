//
//  DXImageView.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-3.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXImageView.h"

@implementation DXImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (theEvent.type == NSLeftMouseDown) {
        NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:self.window.contentView];
        [self.delegate dxImageView:self mouseDown:point];
    }
}

- (void)setImage:(NSImage *)newImage
{
    [super setImage:newImage];
    CGRect frame = self.frame;
    if (![self isSize:frame.size equaltoSize:NSSizeToCGSize(newImage.size)]) {
        frame.size.height = newImage.size.height;
        frame.size.width = newImage.size.width;
        self.frame = frame;
    }
}

- (BOOL)isSize:(CGSize)s1 equaltoSize:(CGSize)s2
{
    return s1.width*s1.width*s1.height == s2.width*s2.width*s2.height;
}

@end
