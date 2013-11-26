//
//  DXTCPServer.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-25.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTCPServer : NSObject<NSStreamDelegate>

+ (instancetype)sharedServer;

- (void)start;

- (void)sendString:(NSString *)data error:(NSError **)err;

@end
