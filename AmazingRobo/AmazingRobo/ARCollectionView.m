//
//  ARCollectionView.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-16.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "ARCollectionView.h"

@implementation ARCollectionView

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

- (void)keyDown:(NSEvent *)theEvent
{
    [self interpretKeyEvents:@[theEvent]];
}

- (void)deleteBackward:(id)sender
{
    [self.keyEventResponder keyboardDeleteEventComingToResponder:self];
}

- (void)insertNewline:(id)sender
{
    [self.keyEventResponder keyboardEnterEventComingToResponder:self];
}

- (void)copy:(id)sender
{
    [self.keyEventResponder keyboardCopyEventComingToResponder:self];
}

- (void)delete:(id)sender
{
    [self.keyEventResponder keyboardDeleteEventComingToResponder:self];
}

@end
