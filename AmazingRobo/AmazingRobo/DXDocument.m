//
//  DXDocument.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-19.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXDocument.h"
#import "DXTouchCommand.h"
#import "Base64.h"
#import "DXFeatureFinder.h"
#import "NSImageView+AddMask.h"

@interface DXDocument ()


- (IBAction)tapLeftTopButtonTapped:(NSButton *)sender;
- (IBAction)panButtonTapped:(NSButton *)sender;
- (IBAction)tapMenuTapped:(NSButton *)sender;
- (IBAction)tapBuylistTapped:(id)sender;
- (IBAction)tapHotDishesTapped:(id)sender;
- (IBAction)tapRightTopButtonTapped:(id)sender;

@property (strong,nonatomic) GCDAsyncSocket *serverSocket;
@property (strong,nonatomic) GCDAsyncSocket *connectSocket;

@property (weak) IBOutlet NSImageView *screenShot;
@property (weak) IBOutlet NSImageView *resultView;

@end

@implementation DXDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"DXDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    if (!self.serverSocket.isConnected) {
        NSError *err = nil;
        [self.serverSocket acceptOnPort:7751 error:&err];
    }
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

- (IBAction)tapLeftTopButtonTapped:(NSButton *)sender {
    [self tapPoint:CGPointMake(30, 30)];
}

- (IBAction)panButtonTapped:(id)sender {
    static BOOL flag = YES;
    NSError *err = nil;
    static DXTouchCommand *testCommand1,*testCommand2;
    testCommand1 = [[DXTouchCommand alloc]initWithType:CommandPan beganPoints:@[touchPointMake(30, 30)] endedPoints:@[touchPointMake(290, 30)] duration:0.3];
    testCommand2 = [[DXTouchCommand alloc]initWithType:CommandPan beganPoints:@[touchPointMake(290, 30)] endedPoints:@[touchPointMake(30, 30)] duration:0.3];
    if (flag) {
        [self sendTouchCommand:testCommand1];//pan from (30,30) to (290,30)
    }else {
        [self sendTouchCommand:testCommand2];//pan from (290,30) to (30,30)
    }
    flag = !flag;
    if (err) {
        NSLog(@"error occured : %@",err);
    }
}

- (IBAction)tapMenuTapped:(id)sender {
    [self tapFeature:@"menu"];
}

- (IBAction)tapBuylistTapped:(id)sender {
    [self tapFeature:@"buylist"];
}

- (IBAction)tapHotDishesTapped:(id)sender {
    [self tapFeature:@"hotdish"];
}

- (IBAction)tapRightTopButtonTapped:(id)sender {
    [self tapPoint:CGPointMake(290, 30)];
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
            self.screenShot.image = image;
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

#pragma mark - dx image view delegate

- (void)dxImageView:(DXImageView *)view mouseDown:(NSPoint)point
{
    CGSize s = view.bounds.size;
    CGPoint p = CGPointMake(point.x, s.height - point.y);
    [self tapPoint:NSPointToCGPoint(p)];
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

- (void)tapFeature:(NSString *)featureName
{
    NSImage *feature = [[NSBundle mainBundle]imageForResource:featureName];
    CGPoint loc = [DXFeatureFinder findFeature:feature inImage:self.screenShot.image];
    CGPoint point = CGPointMake(loc.x + feature.size.width/2, loc.y + feature.size.height/2);
    NSImage *result = [DXFeatureFinder resultFromFeature:feature inImage:self.screenShot.image];
    self.resultView.image = result;
    NSLog(@"feature %@ position %@",featureName,NSStringFromPoint(NSPointFromCGPoint(loc)));
    [self tapPoint:point];
}

- (void)tapPoint:(CGPoint)point
{
    DXTouchCommand *testCommand;
    testCommand = [[DXTouchCommand alloc]initWithType:CommandTap beganPoints:@[touchPointFromCGPoint(point)] endedPoints:@[touchPointFromCGPoint(point)] duration:0.3];
    [self sendTouchCommand:testCommand];
}

@end
