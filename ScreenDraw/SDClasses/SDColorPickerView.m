//
//  SDColorPickerView.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/20/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDColorPickerView.h"
#import "UserPrefs.h"
#import "ISColorWheel.h"

NSString *const KEY_WHEEL_POINT = @"Wheel_Poiont";
NSString *const KEY_SLIDER_VALUE = @"Slider_Value";

@interface SDColorPickerView () <ISColorWheelDelegate>

@end

@implementation SDColorPickerView

@synthesize titleLabel;
@synthesize mainColorWheel;
@synthesize brightnessSlider;
@synthesize clearButton;
@synthesize masterColorButton;
@synthesize isClear;

- (id)init
{
    CGRect frame = CGRectMake(0, 0, 120, 139);
    if (self = [super initWithFrame:frame]) {
        CGFloat currentDrawHeight = 0;
        CGRect labelFrame = CGRectMake(0, 0, frame.size.width, 16);
        self.titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        currentDrawHeight += labelFrame.size.height;
        self.mainColorWheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(2, currentDrawHeight, 100, 100)];
        [self setupColorWheel];
        
        currentDrawHeight += self.mainColorWheel.frame.size.height;
        self.brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, 50, 100, 16)];
        [self.brightnessSlider addTarget:self action:@selector(brightnessSliderDidChange) forControlEvents:UIControlEventAllEvents];
        [self.brightnessSlider setContinuous:YES];
        [self.brightnessSlider setValue:1];
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
        self.brightnessSlider.transform = trans;

        self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, currentDrawHeight, frame.size.width/2, 22)];
        [self.clearButton setTitle:@"X" forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.clearButton setBackgroundColor:[UIColor darkGrayColor]];
        
        self.masterColorButton = [[UIButton alloc] initWithFrame:CGRectMake(self.clearButton.frame.size.width, currentDrawHeight, frame.size.width/2, 22)];
        [self.masterColorButton setTitle:@"=" forState:UIControlStateNormal];
        [self.masterColorButton addTarget:self action:@selector(masterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.masterColorButton setBackgroundColor:[UIColor darkGrayColor]];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.brightnessSlider];
        [self addSubview:self.clearButton];
        [self addSubview:self.masterColorButton];
        
        self.isClear = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        [self setMainColorWheel:[aDecoder decodeObject]];
        [self.brightnessSlider setValue:[aDecoder decodeFloatForKey:KEY_SLIDER_VALUE]];
        [self setupColorWheel];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mainColorWheel];
    [aCoder encodeFloat:self.brightnessSlider.value forKey:KEY_SLIDER_VALUE];
}

- (void)setupColorWheel
{
    [self.mainColorWheel setDelegate:self];
    [self addSubview:self.mainColorWheel];
}

- (void)brightnessSliderDidChange
{
    [self.mainColorWheel setBrightness:self.brightnessSlider.value];
}

- (void)clearButtonPressed
{
    NSLog(@"Clear button pressed");
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDColorPickerDidClearColor:)]) {
        [self.delegate SDColorPickerDidClearColor:self];
    }
    [self.mainColorWheel setShowReticule:!self.mainColorWheel.showReticule];
}

- (void)masterButtonPressed
{
    NSLog(@"MasterButtonPressed");
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDColorPickerIsMasterPicker:)]) {
        [self.delegate SDColorPickerIsMasterPicker:self];
    }
}

-(void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDColorPickerDidChangeColor:)]) {
        [self.delegate SDColorPickerDidChangeColor:self];
    }
}

@end
