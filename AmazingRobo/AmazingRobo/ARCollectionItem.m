//
//  ARCollectionItem.m
//  AmazingRobo
//
//  Created by 徐 东 on 13-12-16.
//  Copyright (c) 2013年 DeanXu. All rights reserved.
//

#import "ARCollectionItem.h"
#import "ARCollectionItemView.h"

@interface ARCollectionItem ()

@end

@implementation ARCollectionItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    ((ARCollectionItemView *)self.view).selected = selected;
}

@end
