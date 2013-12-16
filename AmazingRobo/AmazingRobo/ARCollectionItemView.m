//
//  ARCollectionItemView.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-16.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "ARCollectionItemView.h"

@implementation ARCollectionItemView

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
    // Drawing code here.
	NSRect drawRect = NSInsetRect(self.bounds, 5, 5);
    
	if (self.selected)
	{
		[[NSColor blueColor] set];
		[NSBezierPath strokeRect:drawRect];
	}
}

#pragma mark Properties

- (void)setSelected:(BOOL)selected
{
	_selected = selected;
	[self setNeedsDisplay:YES];
}

@end
