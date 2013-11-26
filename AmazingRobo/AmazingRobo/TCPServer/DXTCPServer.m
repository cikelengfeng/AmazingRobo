//
//  DXTCPServer.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-25.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXTCPServer.h"
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface DXTCPServer ()

@property (strong,nonatomic) NSInputStream *inputStream;
@property (strong,nonatomic) NSOutputStream *outputStream;

@end

@implementation DXTCPServer

static DXTCPServer *singleton;

+ (instancetype)sharedServer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc]init];
    });
    return singleton;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [super allocWithZone:zone];
    });
    return singleton;
}

- (void)start
{
    CFSocketContext     context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    CFSocketRef serverSocket = CFSocketCreate(
                                              kCFAllocatorDefault,
                                              PF_INET,
                                              SOCK_STREAM,
                                              IPPROTO_TCP,
                                              kCFSocketAcceptCallBack, handleConnect, &context);
    struct sockaddr_in sin;
    
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(7751);
    sin.sin_addr.s_addr= INADDR_ANY;
    
    CFDataRef sincfd = CFDataCreate(
                                    kCFAllocatorDefault,
                                    (UInt8 *)&sin,
                                    sizeof(sin));
    
    CFSocketSetAddress(serverSocket, sincfd);
    CFRelease(sincfd);
    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(
                                                                  kCFAllocatorDefault,
                                                                  serverSocket,
                                                                  0);
    
    CFRunLoopAddSource(
                       CFRunLoopGetCurrent(),
                       socketsource,
                       kCFRunLoopDefaultMode);
    CFRelease(socketsource);
    CFRelease(serverSocket);
}

void handleConnect(
                   CFSocketRef s,
                   CFSocketCallBackType callbackType,
                   CFDataRef address,
                   const void *data,
                   void *info
                   )
{
    DXTCPServer *server = [DXTCPServer sharedServer];
    if (callbackType == kCFSocketAcceptCallBack && ![server hasConnected]) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, (CFSocketNativeHandle)data, &readStream, &writeStream);
        server.inputStream = (__bridge NSInputStream *)readStream;
        server.outputStream = (__bridge NSOutputStream *)writeStream;
        server.inputStream.delegate = singleton;
        server.outputStream.delegate = singleton;
        [server.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [server.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [server.inputStream open];
        [server.outputStream open];
    }
}

- (BOOL)hasConnected
{
    return (self.inputStream.streamStatus != NSStreamStatusClosed && self.inputStream.streamStatus != NSStreamStatusNotOpen) || (self.outputStream.streamStatus != NSStreamStatusClosed && self.outputStream.streamStatus != NSStreamStatusNotOpen);
}

- (void)sendString:(NSString *)data error:(NSError *__autoreleasing *)err
{
    if (![self hasConnected]) {
        *err = self.inputStream.streamError ? self.inputStream.streamError : self.outputStream.streamError;
        return;
    }
    NSLog(@"sending data : %@",data);
    int const bufferSize = 1024;
    NSInteger result;
    uint8_t *buffer = (uint8_t *)data.UTF8String;
    result = [self.outputStream write:buffer maxLength:bufferSize];
    if (result == -1) {
        *err = self.outputStream.streamError;
        return;
    }
}

#pragma mark - stream delegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    int const bufferSize = 256;
    uint8_t buffer[bufferSize] = {0};
    NSInteger readed = 0;
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            memset(buffer, 0, sizeof(buffer));
            readed = [self.inputStream read:buffer maxLength:bufferSize];
            if (readed > 0) {
                NSString *coming = [NSString stringWithUTF8String:(char *)buffer];
                NSLog(@"coming data : %@",coming);
            }
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccurred : %@",aStream.streamError);
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        default:
            break;
    }
}


@end
