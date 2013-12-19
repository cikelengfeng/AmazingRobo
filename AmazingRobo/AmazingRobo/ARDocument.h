//
//  DXDocument.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-19.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ARImageView.h"
#import "ARTestEngine.h"
#import "ARCollectionView.h"
#import "ARTestRunner.h"

@interface ARDocument : NSDocument<ARTestEngineDelegate,NSCollectionViewDelegate,ARKeyboardEventResponder,ARTestRunnerDelegate>

@property (strong,nonatomic,readonly) NSMutableArray *features;

@end
