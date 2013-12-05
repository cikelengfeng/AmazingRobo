//
//  DXImageView.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-3.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DXImageView;

@protocol DXImageViewDelegate <NSObject>

- (void)dxImageView:(DXImageView *)view mouseDown:(NSPoint)point;

@end

@interface DXImageView : NSImageView

@property (strong,nonatomic)  id<DXImageViewDelegate> IBOutlet delegate;


@end
