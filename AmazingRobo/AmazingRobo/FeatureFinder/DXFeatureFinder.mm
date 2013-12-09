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

@implementation DXFeatureFinder

int match_method = CV_TM_CCOEFF_NORMED;

+ (CGPoint)findFeature:(NSImage *)feature inImage:(NSImage *)image
{
    Mat resultMat = [self resultMatFromFeature:feature inImage:image];
    
    double minVal; double maxVal; cv::Point minLoc; cv::Point maxLoc;
    cv::Point matchLoc;
    minMaxLoc(resultMat, &minVal, &maxVal, &minLoc, &maxLoc, Mat());
    /// 对于方法 SQDIFF 和 SQDIFF_NORMED, 越小的数值代表更高的匹配结果. 而对于其他方法, 数值越大匹配越好
    if( match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED ) {
        matchLoc = minLoc;
    }else{
        if (maxVal < 0.9) {
            return CGPointMake(-1, -1);
        }
        matchLoc = maxLoc;
    }
    NSLog(@"min %f , max %f",minVal,maxVal);
    return CGPointMake(matchLoc.x, matchLoc.y);
}

+ (Mat)resultMatFromFeature:(NSImage *)feature inImage:(NSImage *)image
{
    Mat imageMat,featureMat;
    imageMat = image.CVMat;
    featureMat = feature.CVMat;
    Mat resultMat(imageMat.rows-featureMat.rows+1, imageMat.cols-featureMat.cols+1, CV_32FC1);
    matchTemplate(imageMat, featureMat, resultMat, match_method);
    threshold(resultMat, resultMat, 0.9, 1., CV_THRESH_TOZERO);
    return resultMat;
}

+ (NSImage *)resultFromFeature:(NSImage *)feature inImage:(NSImage *)image
{
    return [NSImage imageWithCVMat:[self resultMatFromFeature:feature inImage:image]];
}

+ (NSImage *)imageFromImage:(NSImage *)img
{
    Mat mat = img.CVMat;
    return [NSImage imageWithCVMat:mat];
}

@end
