//
//  DXDocument.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-19.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DXImageView.h"
#import "DXTestEngine.h"
#import "ARCollectionView.h"

@interface DXDocument : NSDocument<DXTestEngineDelegate,NSCollectionViewDelegate,ARKeyboardEventResponder>

@property (strong,nonatomic,readonly) NSMutableArray *features;

@end
