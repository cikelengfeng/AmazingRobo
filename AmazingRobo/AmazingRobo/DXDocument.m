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
#import "DXTestEngine.h"

@interface DXDocument ()


- (IBAction)tapLeftTopButtonTapped:(NSButton *)sender;
- (IBAction)panButtonTapped:(NSButton *)sender;
- (IBAction)tapMenuTapped:(NSButton *)sender;
- (IBAction)tapBuylistTapped:(id)sender;
- (IBAction)tapHotDishesTapped:(id)sender;
- (IBAction)tapRightTopButtonTapped:(id)sender;
- (IBAction)clipButtonTapped:(id)sender;

@property (strong,nonatomic) DXTestEngine *engine;

@property (weak) IBOutlet DXImageView *screenShot;
@property (weak) IBOutlet NSImageView *resultView;
@property (weak) IBOutlet NSTextField *fileNameView;

@end

@implementation DXDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _engine = [[DXTestEngine alloc]init];
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
    self.engine.delegate = self;
    [self.engine start];
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
    [self.engine tapPoint:CGPointMake(30, 30)];
}

- (IBAction)panButtonTapped:(id)sender {
    static BOOL flag = YES;
    NSError *err = nil;
    static DXTouchCommand *testCommand1,*testCommand2;
    testCommand1 = [[DXTouchCommand alloc]initWithType:CommandPan beganPoints:@[touchPointMake(30, 30)] endedPoints:@[touchPointMake(290, 30)] duration:0.3];
    testCommand2 = [[DXTouchCommand alloc]initWithType:CommandPan beganPoints:@[touchPointMake(290, 30)] endedPoints:@[touchPointMake(30, 30)] duration:0.3];
    if (flag) {
        [self.engine sendTouchCommand:testCommand1];//pan from (30,30) to (290,30)
    }else {
        [self.engine sendTouchCommand:testCommand2];//pan from (290,30) to (30,30)
    }
    flag = !flag;
    if (err) {
        NSLog(@"error occured : %@",err);
    }
}

- (IBAction)tapMenuTapped:(id)sender {
    [self.engine tapFeature:@"menu"];
}

- (IBAction)tapBuylistTapped:(id)sender {
    [self.engine tapFeature:@"buylist"];
}

- (IBAction)tapHotDishesTapped:(id)sender {
    [self.engine tapFeature:@"hotdish"];
}

- (IBAction)tapRightTopButtonTapped:(id)sender {
    [self.engine tapPoint:CGPointMake(290, 30)];
}

- (IBAction)clipButtonTapped:(id)sender {
    NSImage *clipped = [self.screenShot getClippedImage];
    self.resultView.image = clipped;
    NSString *fileName = self.fileNameView.stringValue.length > 0 ? self.fileNameView.stringValue : [NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSinceReferenceDate];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"AmazingRobo/features/%@",fileName]];
    BOOL result = [self.screenShot saveClippedImageToPath:path];
    if (result) {
        NSLog(@"clipped image has been saved into %@",path);
    }
}

#pragma mark - dx image view delegate

- (void)dxImageView:(DXImageView *)view mouseDown:(NSPoint)point
{
    CGSize s = view.bounds.size;
    CGPoint p = CGPointMake(point.x, s.height - point.y);
    [self.engine tapPoint:NSPointToCGPoint(p)];
}

#pragma mark - test engine delegate
-(void)testEngine:(DXTestEngine *)engine hasNewScreenShot:(NSImage *)screenshot
{
    self.screenShot.image = screenshot;
}

- (void)testEngine:(DXTestEngine *)engine hasNewMatchResult:(NSImage *)result
{
    self.resultView.image = result;
}

@end
