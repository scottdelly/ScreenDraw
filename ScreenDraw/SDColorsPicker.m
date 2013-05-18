//
//  SDColorsPicker.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDColorsPicker.h"
#import "UserPrefs.h"

@implementation SDColorsPicker
@synthesize backgroundColorPicker, lineColorPicker, fillColorPicker;

- (void)loadView
{
    [super loadView];
    CGFloat frameX = [[UIScreen mainScreen] bounds].size.width;
    CGFloat frameWidth = floorf([[UIScreen mainScreen] bounds].size.width*0.3f);

    [self.view setFrame:CGRectMake(frameX, self.view.frame.origin.y, frameWidth, self.view.frame.size.height)];
    
    CGRect labelFrame = CGRectMake(0, 10, frameWidth, 16);
    UILabel *backgroundColorLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [backgroundColorLabel setText:@"Background Color"];
    [backgroundColorLabel setBackgroundColor:[UIColor clearColor]];
    [backgroundColorLabel setFont:[UIFont systemFontOfSize:10]];
    [backgroundColorLabel setTextAlignment:NSTextAlignmentCenter];
    
    CGFloat pickerHeight = floorf(self.view.frame.size.height/3.0f);
    self.backgroundColorPicker = [[ISColorWheel alloc] initWithFrame:CGRectMake(0, 25, frameWidth, frameWidth)];
    [self.backgroundColorPicker setDelegate:self];
    [self.backgroundColorPicker setCurrentColor:[UserPrefs getBackgroundColor]];
    [self.backgroundColorPicker setContinuous:YES];
    
    labelFrame.origin.y += 182;
    UILabel *lineColorLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [lineColorLabel setText:@"Line Color"];
    [lineColorLabel setBackgroundColor:[UIColor clearColor]];
    [lineColorLabel setFont:[UIFont systemFontOfSize:10]];
    [lineColorLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.lineColorPicker = [[ISColorWheel alloc] initWithFrame:CGRectMake(0, 25+pickerHeight, frameWidth, frameWidth)];
    [self.lineColorPicker setDelegate:self];
    [self.lineColorPicker setCurrentColor:[UserPrefs getLineColor]];
    
    labelFrame.origin.y += 182;
    UILabel *fillColorLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [fillColorLabel setText:@"Fill Color"];
    [fillColorLabel setBackgroundColor:[UIColor clearColor]];
    [fillColorLabel setFont:[UIFont systemFontOfSize:10]];
    [fillColorLabel setTextAlignment:NSTextAlignmentCenter];
    self.fillColorPicker = [[ISColorWheel alloc] initWithFrame:CGRectMake(0, 25+2*pickerHeight, frameWidth, frameWidth)];
    [self.fillColorPicker setDelegate:self];
    [self.fillColorPicker setCurrentColor:[UserPrefs getFillColor]];

    [self.view addSubview:backgroundColorLabel];
    [self.view addSubview:self.backgroundColorPicker];
    [self.view addSubview:lineColorLabel];
    [self.view addSubview:self.lineColorPicker];
    [self.view addSubview:fillColorLabel];
    [self.view addSubview:self.fillColorPicker];
}

- (void)show
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x = floorf([[UIScreen mainScreen] bounds].size.width*0.7f);
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)hide
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.x = [[UIScreen mainScreen] bounds].size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

-(void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel
{
//    NSLog(@"Color wheel did change to %@", colorWheel.currentColor);
    if (colorWheel == self.backgroundColorPicker) {
        [UserPrefs setBackgroundColor:[colorWheel currentColor]];
    } else if (colorWheel == self.lineColorPicker) {
        [UserPrefs setLineColor:[colorWheel currentColor]];
    } else if (colorWheel == self.fillColorPicker) {
        [UserPrefs setFillColor:[colorWheel currentColor]];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorsDidChange)]) {
        [self.delegate colorsDidChange];
    }
}

@end
