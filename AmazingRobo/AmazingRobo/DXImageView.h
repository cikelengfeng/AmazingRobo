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

//- (void)dxImageView:(DXImageView *)view mouseDown:(NSPoint)point;
- (void)dxImageView:(DXImageView *)view clippedImage:(NSImage *)clipped;

@end

/**
 * 用于显示图片和鼠标截图的工具类
 * @note 不要为该类设置任何边框
 **/
@interface DXImageView : NSImageView

@property (strong,nonatomic)  id<DXImageViewDelegate> IBOutlet delegate;
@property (assign,nonatomic) NSRect rectangleMask;

- (NSImage *)getClippedImage;
- (BOOL)saveClippedImageToPath:(NSString *)path;

@end
