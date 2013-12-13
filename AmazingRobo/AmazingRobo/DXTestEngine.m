//
//  DXTestEngine.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-9.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXTestEngine.h"
#import "Base64.h"
#import "DXFeatureFinder.h"

@interface DXTestEngine ()

@property (strong,nonatomic) GCDAsyncSocket *serverSocket;
@property (strong,nonatomic) GCDAsyncSocket *connectSocket;
@property (strong,nonatomic) NSImage *screenShot;

- (void)waitIncomingData;

- (void)sendBytes:(void *)bytes maxLength:(NSUInteger)length;

- (void)sendString:(NSString *)data;

- (NSImage *)imageFromJSON:(NSDictionary *)json;

@end

@implementation DXTestEngine

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)setScreenShot:(NSImage *)screenShot
{
    _screenShot = screenShot;
    [self.delegate testEngine:self hasNewScreenShot:_screenShot];
}

- (void)start
{
    if (!self.serverSocket.isConnected) {
        NSError *err = nil;
        [self.serverSocket acceptOnPort:7751 error:&err];
    }
}

- (void)waitIncomingData
{
    assert([self.connectSocket isConnected]);
    uint8_t terminal[1] = {0xed};
    NSData *seperator = [NSData dataWithBytes:terminal length:1];
    [self.connectSocket readDataToData:seperator withTimeout:-1 tag:0xed];
}

#pragma mark - GCDSokcet delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    self.connectSocket = newSocket;
    [self waitIncomingData];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self waitIncomingData];
    if (tag == 0xed) {
        NSData *readed = [NSData dataWithBytes:data.bytes length:data.length - 1];
        NSDictionary *json = [readed mutableObjectFromJSONData];
        if (json) {
            NSImage *image = [self imageFromJSON:json];
            self.screenShot = image;
        }
        
    }
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self waitIncomingData];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket %@ did disconnect with error %@",sock,err);
}

#pragma mark - send data
- (void)sendBytes:(void *)bytes maxLength:(NSUInteger)length
{
    if ([self.connectSocket isConnected]) {
        NSMutableData *sending = [NSMutableData dataWithBytes:bytes length:length];
        uint8_t terminal[1] = {0xed};
        [sending appendBytes:terminal length:1];
        [self.connectSocket writeData:sending withTimeout:-1 tag:0xed];
    }
    
}

- (void)sendString:(NSString *)data
{
    uint8_t *buffer = (uint8_t *)data.UTF8String;
    [self sendBytes:buffer maxLength:data.length];
}

- (void)sendTouchCommand:(DXTouchCommand *)command
{
    if (command) {
        [self sendString:[command toJSONString]];
    }else {
        NSLog(@"command is nil");
    }
}

#pragma mark - image decode
- (NSImage *)imageFromJSON:(NSDictionary *)json
{
    NSString *base64 = json[@"data"];
    NSData *imageData = [NSData dataWithBase64EncodedString:base64];
    NSImage *image = [[NSImage alloc]initWithData:imageData];
    return image;
}

- (NSImage *)imageFromFileByName:(NSString *)name
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"AmazingRobo/features/%@",name]]stringByAppendingPathExtension:@"png"];
    NSImage *img = [[NSImage alloc]initWithContentsOfFile:path];
    return img;
}

- (void)tapFeature:(NSString *)featureName
{
    NSImage *feature = [self imageFromFileByName:featureName];
    CGPoint loc = [self findFeature:feature];
    CGPoint point = CGPointMake(loc.x + feature.size.width/2, loc.y + feature.size.height/2);
    NSLog(@"feature %@ position %@",featureName,NSStringFromPoint(NSPointFromCGPoint(loc)));
    [self tapPoint:point];
}

- (void)tapPoint:(CGPoint)point
{
    DXTouchCommand *testCommand;
    testCommand = [[DXTouchCommand alloc]initWithType:CommandTap beganPoints:@[touchPointFromCGPoint(point)] endedPoints:@[touchPointFromCGPoint(point)] duration:0.3];
    [self sendTouchCommand:testCommand];
}

#pragma mark - find feature

- (CGPoint)findFeature:(NSImage *)feature
{
    CGPoint loc = [DXFeatureFinder findFeature:feature inImage:self.screenShot];
#ifdef DEBUG
    if ([self.delegate respondsToSelector:@selector(testEngine:hasNewScreenShot:)]) {
        NSImage *result = [DXFeatureFinder resultFromFeature:feature inImage:self.screenShot];
        [self.delegate testEngine:self hasNewMatchResult:result];
    }
#endif
    return loc;
}

- (CGPoint)findFeatureByName:(NSString *)featureName
{
    NSImage *feature = [self imageFromFileByName:featureName];
    return [self findFeature:feature];
}

- (BOOL)hasFeature:(NSString *)featureName
{
    NSImage *feature = [self imageFromFileByName:featureName];
    CGPoint loc = [self findFeature:feature];
    return loc.x > 0 && loc.y > 0;
}


@end
