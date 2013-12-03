//
//  NSImage+OpenCV.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-2.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (OpenCV)

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end
