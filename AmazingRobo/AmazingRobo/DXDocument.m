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

@property (strong,nonatomic) QServer *server;
@property (strong,nonatomic) NSInputStream *input;
@property (strong,nonatomic) NSOutputStream *output;
@property (strong,nonatomic) NSMutableData *dataFromTCP;

@property (weak) IBOutlet NSImageView *screenShot;
@property (weak) IBOutlet NSImageView *resultView;

@end

@implementation DXDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _server = [[QServer alloc]initWithDomain:nil type:nil name:nil preferredPort:7751];
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
    if (!self.server.isStarted) {
        self.server.delegate = self;
        [self.server start];
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
    NSError *err = nil;
    DXTouchCommand *testCommand;
    testCommand = [[DXTouchCommand alloc]initWithType:CommandTap beganPoints:@[touchPointMake(30, 30)] endedPoints:@[touchPointMake(30, 30)] duration:0.3];
    [self sendTouchCommand:testCommand error:&err];
    if (err) {
        NSLog(@"error occured : %@",err);
    }
}

- (IBAction)panButtonTapped:(id)sender {
    static BOOL flag = YES;
    NSError *err = nil;
    static DXTouchCommand *testCommand1,*testCommand2;
    testCommand1 = [[DXTouchCommand alloc]initWithType:CommandPan beganPoints:@[touchPointMake(30, 30)] endedPoints:@[touchPointMake(290, 30)] duration:0.3];
    testCommand2 = [[DXTouchCommand alloc]initWithType:CommandPan beganPoints:@[touchPointMake(290, 30)] endedPoints:@[touchPointMake(30, 30)] duration:0.3];
    if (flag) {
        [self sendTouchCommand:testCommand1 error:&err];//pan from (30,30) to (290,30)
    }else {
        [self sendTouchCommand:testCommand2 error:&err];//pan from (290,30) to (30,30)
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
    NSError *err = nil;
    DXTouchCommand *testCommand;
    testCommand = [[DXTouchCommand alloc]initWithType:CommandTap beganPoints:@[touchPointMake(290, 30)] endedPoints:@[touchPointMake(290, 30)] duration:0.3];
    [self sendTouchCommand:testCommand error:&err];
    if (err) {
        NSLog(@"error occured : %@",err);
    }
}

- (void)openStreams
{
    assert(self.input != nil);            // streams must exist but aren't open
    assert(self.output != nil);
    
    [self.input  setDelegate:self];
    [self.input  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.input  open];
    
    [self.output setDelegate:self];
    [self.output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.output open];
    
}

- (void)closeStreams
{
    assert( (self.input != nil) == (self.output != nil) );      // should either have both or neither
    if (self.input != nil) {
        [self.server closeOneConnection:self];
        
        [self.input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.input close];
        self.input = nil;
        
        [self.output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.output close];
        self.output = nil;
    }
}

- (NSMutableData *)dataFromTCP
{
    if (!_dataFromTCP) {
        _dataFromTCP = [NSMutableData data];
    }
    return _dataFromTCP;
}

#pragma mark - QServer delegate

- (id)server:(QServer *)server connectionForInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    id result;
    
    assert(server == self.server);
#pragma unused(server)
    assert(inputStream != nil);
    assert(outputStream != nil);
    
    assert( (self.input != nil) == (self.output != nil) );      // should either have both or neither
    
    if (self.input != nil) {
        result = nil;
    } else {
        // Latch the input and output sterams and kick off an open.
        
        self.input = inputStream;
        self.output = outputStream;
        [self openStreams];
        
        result = self;
    }
    
    return result;
}

- (void)server:(QServer *)server closeConnection:(id)connection
{
    [self closeStreams];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    int const bufferSize = 2<<14;
    static uint8_t buffer[bufferSize] = {0};
    NSInteger readed = 0;
    static BOOL completeFlag;
    NSMutableDictionary *json;
    if (completeFlag) {
        [self.dataFromTCP setLength:0];
        completeFlag = NO;
    }
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            memset(buffer, 0, sizeof(buffer));
            readed = [self.input read:buffer maxLength:bufferSize];
            NSUInteger appendLength = readed;
             if (readed > 0) {
                 for (int i = 0; i < readed; i++) {
                     if (buffer[i] == 0xed) {// client will send a 0xed as a terminal flag when a JSON object has been sended,because TCP couldn't do this for us.
                         completeFlag = YES;
                         appendLength = i;
                         break;
                     }
                 }
                 [self.dataFromTCP appendBytes:buffer length:appendLength];
             }
//            NSLog(@"readed : %ld",readed);
            if (completeFlag) {
//                NSLog(@"data length : %ld",self.dataFromTCP.length);
                json = [self.dataFromTCP mutableObjectFromJSONData];
//                NSLog(@"readed json : %@",json);
                NSImage *image = [self imageFromJSON:json];
                [self.screenShot setImage:image];
            }
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            [self closeStreams];
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

#pragma mark - send data
- (void)sendString:(NSString *)data error:(NSError *__autoreleasing *)err
{
    NSLog(@"sending string : %@",data);
    NSInteger result;
    uint8_t *buffer = (uint8_t *)data.UTF8String;
    result = [self.output write:buffer maxLength:data.length];
    if (result == -1) {
        *err = self.output.streamError;
        return;
    }
}

- (void)sendTouchCommand:(DXTouchCommand *)command error:(NSError *__autoreleasing *)err
{
    if (command) {
        [self sendString:[command toJSONString] error:err];
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
    NSError *err = nil;
    DXTouchCommand *testCommand;
    testCommand = [[DXTouchCommand alloc]initWithType:CommandTap beganPoints:@[touchPointFromCGPoint(point)] endedPoints:@[touchPointFromCGPoint(point)] duration:0.3];
    [self sendTouchCommand:testCommand error:&err];
    if (err) {
        NSLog(@"error occured : %@",err);
    }
}

@end
