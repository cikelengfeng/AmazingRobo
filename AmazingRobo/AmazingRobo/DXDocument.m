//
//  DXDocument.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-11-19.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "DXDocument.h"

@interface DXDocument ()


- (IBAction)buttonTapped:(NSButton *)sender;

@property (strong,nonatomic) QServer *server;
@property (strong,nonatomic) NSInputStream *input;
@property (strong,nonatomic) NSOutputStream *output;

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

- (IBAction)buttonTapped:(NSButton *)sender {
    static BOOL flag = YES;
    NSError *err = nil;
    if (flag) {
        [self sendString:@"{\"beganPoints\":[{\"x\":30,\"y\":30}],\"endedPoints\":[{\"x\":30,\"y\":30}],\"type\":0,\"duration\":0.3}" error:&err];//tap at (30,30)
    }else {
        [self sendString:@"{\"beganPoints\":[{\"x\":290,\"y\":30}],\"endedPoints\":[{\"x\":290,\"y\":30}],\"type\":0,\"duration\":0.3}" error:&err];//tap at (290,30)
    }
    flag = !flag;
    if (err) {
        NSLog(@"error occured : %@",err);
    }
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
        inputStream.delegate = self;
        outputStream.delegate = self;
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
        result = self;
    }
    
    return result;
}

- (void)server:(QServer *)server closeConnection:(id)connection
{
    [self.input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.input close];
    [self.output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.output close];
    [self.server closeOneConnection:self];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    int const bufferSize = 256;
    uint8_t buffer[bufferSize] = {0};
    NSInteger readed = 0;
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            memset(buffer, 0, sizeof(buffer));
            readed = [self.input read:buffer maxLength:bufferSize];
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

#pragma mark - send string 
- (void)sendString:(NSString *)data error:(NSError *__autoreleasing *)err
{
    NSLog(@"sending data : %@",data);
    int const bufferSize = 1024;
    NSInteger result;
    uint8_t *buffer = (uint8_t *)data.UTF8String;
    result = [self.output write:buffer maxLength:bufferSize];
    if (result == -1) {
        *err = self.output.streamError;
        return;
    }
}

@end
