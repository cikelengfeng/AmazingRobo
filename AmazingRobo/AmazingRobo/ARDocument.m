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
#import "DXTestEngine.h"

@interface DXDocument ()

- (IBAction)clipButtonTapped:(id)sender;
- (IBAction)findClippedButtonTapped:(id)sender;
- (IBAction)fileNameInputComplete:(id)sender;
- (IBAction)tapClippedButtonTapped:(id)sender;

@property (strong,nonatomic) DXTestEngine *engine;
@property (strong,nonatomic) NSMutableArray *features;

@property (weak) IBOutlet DXImageView *screenShot;
@property (weak) IBOutlet NSTextField *fileNameView;
@property (weak) IBOutlet NSTextField *findResultView;
@property (weak) IBOutlet NSTextField *matchingRateView;
@property (weak) IBOutlet NSCollectionView *fileCollectionView;

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
    [self loadFeatures];
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


- (IBAction)clipButtonTapped:(id)sender {
    NSString *fileName = self.fileNameView.stringValue.length > 0 ? self.fileNameView.stringValue.stringByDeletingPathExtension : [NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSinceReferenceDate];
    NSString *path = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"AmazingRobo"] stringByAppendingPathComponent:@"features"] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"png"];
    BOOL result = [self.screenShot saveClippedImageToPath:path];
    if (result) {
        NSLog(@"clipped image has been saved into %@",path);
        [self loadFeatures];
    }
}

- (IBAction)findClippedButtonTapped:(id)sender {
    CGRect result = [self.engine findFeatureByName:self.fileNameView.stringValue.stringByDeletingPathExtension];
    self.findResultView.stringValue = NSStringFromPoint(result.origin);
    CGRect drawMaskRect = CGRectMake(result.origin.x, self.screenShot.bounds.size.height - result.origin.y - result.size.height, result.size.width, result.size.height);
    [self.screenShot setRectangleMask:drawMaskRect];
}

- (IBAction)fileNameInputComplete:(id)sender {
    [self findClippedButtonTapped:nil];
}

- (IBAction)tapClippedButtonTapped:(id)sender {
    [self.engine tapFeature:self.fileNameView.stringValue.stringByDeletingPathExtension];
    [self findClippedButtonTapped:nil];
}

#pragma mark - test engine delegate
-(void)testEngine:(DXTestEngine *)engine hasNewScreenShot:(NSImage *)screenshot
{
    self.screenShot.image = screenshot;
}

- (void)testEngine:(DXTestEngine *)engine hasNewMatchResult:(CGRect)result min:(double)min max:(double)max matchMethod:(int)method
{
    self.matchingRateView.stringValue = @(max).description;
}

#pragma mark -  file operations
- (void)loadFeatures
{
    NSURL *url = [NSURL fileURLWithPath:self.engine.featurePath];
    NSError *error = nil;
    NSArray *properties = @[ NSURLLocalizedNameKey,
                           NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey];
    
    NSArray *array = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtURL:url
                      includingPropertiesForKeys:properties
                      options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                      error:&error];
    if (array == nil) {
        // Handle the error
        return;
    }
    self.features = [NSMutableArray arrayWithArray:array];
}

- (void)deleteSelectedFile
{
    NSInteger selectionIndex = [self.fileCollectionView.selectionIndexes firstIndex];
    NSURL *deletion = self.features[selectionIndex];
    [self.features removeObjectAtIndex:selectionIndex];
    NSError *err = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtURL:deletion error:&err];
    if (!result) {
        NSLog(@"delete file %@ failed : %@",deletion,err);
    }
    [self loadFeatures];
}

- (void)copySelectedFileName
{
    NSInteger selectionIndex = [self.fileCollectionView.selectionIndexes firstIndex];
    NSURL *selection = self.features[selectionIndex];
    NSString *fileName = selection.absoluteString.lastPathComponent.stringByDeletingPathExtension;
    [[NSPasteboard generalPasteboard] declareTypes:@[NSStringPboardType] owner:NULL];
    [[NSPasteboard generalPasteboard] setString:fileName forType:NSStringPboardType];
}

#pragma mark - keyboard event responder
- (void)keyboardDeleteEventComingToResponder:(NSResponder *)responder
{
    if (responder == self.fileCollectionView) {
        [self deleteSelectedFile];
    }
}

- (void)keyboardEnterEventComingToResponder:(NSResponder *)responder
{
    if (responder == self.fileCollectionView) {
        [self findClippedButtonTapped:nil];
    }
}

-(void)keyboardCopyEventComingToResponder:(NSResponder *)responder
{
    if (responder == self.fileCollectionView) {
        [self copySelectedFileName];
    }
}

@end