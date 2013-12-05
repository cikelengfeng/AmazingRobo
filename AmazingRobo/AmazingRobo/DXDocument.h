//
//  DXDocument.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-19.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DXImageView.h"
#import "GCDAsyncSocket.h"

@interface DXDocument : NSDocument<GCDAsyncSocketDelegate,NSStreamDelegate,DXImageViewDelegate>

@end
