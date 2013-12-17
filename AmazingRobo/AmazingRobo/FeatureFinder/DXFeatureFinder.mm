//
//  DXFeatureFinder.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-2.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXFeatureFinder.h"
#import "NSImage+OpenCV.h"

using namespace cv;

#define kThreshold 0.85

@implementation DXFeatureFinder

int match_method = CV_TM_CCOEFF_NORMED;

+ (CGRect)findFeature:(NSImage *)feature inImage:(NSImage *)image min:(double *)minVal max:(double *)maxVal method:(int *)method
{
    if (!feature) {
        return CGRectMake(-1, -1, 0, 0);
    }
    Mat resultMat = [self resultMatFromFeature:feature inImage:image];
    
    cv::Point minLoc; cv::Point maxLoc;
    cv::Point matchLoc;
    method = &match_method;
    minMaxLoc(resultMat, minVal, maxVal, &minLoc, &maxLoc, Mat());
    /// 对于方法 SQDIFF 和 SQDIFF_NORMED, 越小的数值代表更高的匹配结果. 而对于其他方法, 数值越大匹配越好
    if( match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED ) {
        matchLoc = minLoc;
    }else{
        if (*maxVal < kThreshold) {
            return CGRectMake(-1, -1, 0, 0);
        }
        matchLoc = maxLoc;
    }
    NSLog(@"min %f , max %f",*minVal,*maxVal);
    return CGRectMake(matchLoc.x, matchLoc.y, feature.size.width, feature.size.height);
}

+ (CGRect)findFeature:(NSImage *)feature inImage:(NSImage *)image
{
    double min ,max ;
    int method;
    return [self findFeature:feature inImage:image min:&min max:&max method:&method];
}

+ (Mat)resultMatFromFeature:(NSImage *)feature inImage:(NSImage *)image
{
    Mat imageMat,featureMat;
    imageMat = image.CVMat;
    featureMat = feature.CVMat;
    Mat resultMat(imageMat.rows-featureMat.rows+1, imageMat.cols-featureMat.cols+1, CV_32FC1);
    matchTemplate(imageMat, featureMat, resultMat, match_method);
    threshold(resultMat, resultMat, kThreshold, 1., CV_THRESH_TOZERO);
    return resultMat;
}

+ (NSImage *)resultFromFeature:(NSImage *)feature inImage:(NSImage *)image
{
    if (!feature) {
        return nil;
    }
    return [NSImage imageWithCVMat:[self resultMatFromFeature:feature inImage:image]];
}

+ (NSImage *)imageFromImage:(NSImage *)img
{
    Mat mat = img.CVMat;
    return [NSImage imageWithCVMat:mat];
}

@end
