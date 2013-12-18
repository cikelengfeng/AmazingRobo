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

@interface ARDocument : NSDocument<DXTestEngineDelegate,NSCollectionViewDelegate,ARKeyboardEventResponder>

@property (strong,nonatomic,readonly) NSMutableArray *features;

@end
