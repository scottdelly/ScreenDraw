//
//  SDToolPaletteVC.m
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDToolPaletteVC.h"

@interface SDToolPaletteVC ()

@end

@implementation SDToolPaletteVC
@synthesize toolButtons;
@synthesize brushButton;
@synthesize elipseButton;
@synthesize rectButton;
@synthesize lineButton;
@synthesize cameraButton;
@synthesize brushSize;
@synthesize brushPreview;

-(id) init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

}

- (void)show
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x =  0;
    viewFrame.size.width = self.view.frame.size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)hideWithCompletion:(void(^)(void))block
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x = 0-viewFrame.size.width;
    viewFrame.size.width = self.view.frame.size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

@end
