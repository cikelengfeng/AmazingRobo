//
//  DXImageView.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-3.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXImageView.h"

@interface DXImageView ()

@property (assign,nonatomic) CGPoint startPoint;
@property (assign,nonatomic) CGRect clipRect;

- (NSBitmapImageRep *)getClippedBitmap;

@end

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
	
    CGContextRef myContext = [[NSGraphicsContext // 1
                               currentContext] graphicsPort];
    // ********** Your drawing code here ********** // 2
    CGContextSetRGBStrokeColor(myContext, 1, 0, 0, 1);
    CGContextStrokeRectWithWidth(myContext, _clipRect, 2);
}

- (void)setImage:(NSImage *)newImage
{
    NSSize imgs = newImage.size;
    NSRect frame = self.frame;
    frame.size = imgs;
    self.frame = frame;
    [super setImage:newImage];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (theEvent.type == NSLeftMouseDown) {
        NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:self.window.contentView];
//        [self.delegate dxImageView:self mouseDown:point];
        _startPoint.x = point.x;
        _startPoint.y = point.y;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (theEvent.type == NSLeftMouseDragged) {
        NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:self.window.contentView];
        point.x = MIN(self.image.size.width,MAX(0,point.x));
        point.y = MIN(self.image.size.height,MAX(0,point.y));
        //        [self.delegate dxImageView:self mouseDown:point];
        CGPoint offset = CGPointMake(point.x - _startPoint.x, point.y - _startPoint.y);
        _clipRect = CGRectMake(_startPoint.x + (offset.x >= 0 ? 0 : offset.x), _startPoint.y + (offset.y >= 0 ? 0 : offset.y), ABS(offset.x), ABS(offset.y));
        [self setNeedsDisplay:YES];
    }
}

- (NSImage *)getClippedImage
{
    NSBitmapImageRep *image = [self getClippedBitmap];
    NSImage *result = [[NSImage alloc]initWithCGImage:image.CGImage size:image.size];
    return result;
}

- (NSBitmapImageRep *)getClippedBitmap
{/*我们得到的_clipRect的原点是左下角，并且长度单位都是CGImage的一半(Retina，其他像素密度对应不同的scaling)，所以我们将原点x，长，宽直接乘2，ImageView的高减clipRect的原点y减_clipRect的高再乘2得到图片坐标系下的原点y
            nsimage                           cgimage
            +-----------+                     +------------------------+
            | clipRect  |                     |                        |
            |   +--+    |                     |                        |
            |   |  |    |                     |      rectInImage       |
            |o1 +--+    |                     |     o2 +----+          |
            |           |                     |        |    |          |
            +-----------+                     |        |    |          |
                                              |        +----+          |
                                              |                        |
                                              |                        |
                                              |                        |
                                              +------------------------+
  
  */
    CGRect rectInImage = CGRectMake(_clipRect.origin.x * 2, (self.bounds.size.height - _clipRect.origin.y - _clipRect.size.height)*2, _clipRect.size.width*2, _clipRect.size.height*2);
    CGImageRef cgOriginImg = [self.image CGImageForProposedRect:nil context:[NSGraphicsContext currentContext] hints:nil];
    CGImageRef cgClippedImg = CGImageCreateWithImageInRect(cgOriginImg,rectInImage);
    NSBitmapImageRep *image = [[NSBitmapImageRep alloc]initWithCGImage:cgClippedImg];
    //由于从CGImage上截下来的图是双倍(Retina，其他像素密度对应不同的scaling)尺寸，所以要把尺寸设置为_clipRect的尺寸
    image.size = _clipRect.size;
    CGImageRelease(cgClippedImg);
    return image;
}

- (BOOL)saveClippedImageToPath:(NSString *)path
{
    NSFileManager*fm = [NSFileManager defaultManager];
    NSBitmapImageRep *image = [self getClippedBitmap];
    NSData *pngData = [image representationUsingType:NSPNGFileType properties:nil];
    [fm createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:NO attributes:nil error:nil];
    NSError *err = nil;
    BOOL result = [pngData writeToFile:path options:0 error:&err];
    if (!result) {
        NSLog(@"saving file failed, error ");
    }
    return result;
}

@end
