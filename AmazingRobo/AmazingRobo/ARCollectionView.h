//
//  ARCollectionView.h
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-16.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ARKeyboardEventResponder <NSObject>

- (void)keyboardDeleteEventComingToResponder:(NSResponder *)responder;
- (void)keyboardEnterEventComingToResponder:(NSResponder *)responder;
- (void)keyboardCopyEventComingToResponder:(NSResponder *)responder;

@end

@interface ARCollectionView : NSCollectionView

@property (weak,nonatomic) IBOutlet id<ARKeyboardEventResponder> keyEventResponder;

@end
