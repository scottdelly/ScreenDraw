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
@synthesize darknessSlider;
@synthesize clearButton;
@synthesize masterColorButton;
//@synthesize color;

- (id)init
{
    CGRect frame = CGRectMake(0, 0, 100, 170);
    if (self = [super initWithFrame:frame]) {
        CGFloat currentDrawHeight = 0;
        CGRect labelFrame = CGRectMake(0, 0, frame.size.width, 16);
        self.titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        currentDrawHeight += labelFrame.size.height;
        self.mainColorWheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(0, currentDrawHeight, frame.size.width, frame.size.width)];
        [self.mainColorWheel setDelegate:self];
        [self.mainColorWheel setContinuous:YES];
        
        currentDrawHeight += self.mainColorWheel.frame.size.height;
        self.darknessSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, currentDrawHeight, frame.size.width, 16)];
        [self.darknessSlider addTarget:self action:@selector(darknessSliderDidChange) forControlEvents:UIControlEventAllEvents];
        [self.darknessSlider setContinuous:YES];
        [self.darknessSlider setValue:1];
        
        currentDrawHeight += self.darknessSlider.frame.size.height + 5.0f;
        self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, currentDrawHeight, frame.size.width/2, 22)];
        [self.clearButton setTitle:@"X" forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.clearButton setBackgroundColor:[UIColor grayColor]];
        
        self.masterColorButton = [[UIButton alloc] initWithFrame:CGRectMake(self.clearButton.frame.size.width, currentDrawHeight, frame.size.width/2, 22)];
        [self.masterColorButton setTitle:@"=" forState:UIControlStateNormal];
        [self.masterColorButton addTarget:self action:@selector(masterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.masterColorButton setBackgroundColor:[UIColor grayColor]];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.mainColorWheel];
        [self addSubview:self.darknessSlider];
        [self addSubview:self.clearButton];
        [self addSubview:self.masterColorButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        [self.mainColorWheel setTouchPoint:[aDecoder decodeCGPointForKey:KEY_WHEEL_POINT]];
        [self.darknessSlider setValue:[aDecoder decodeFloatForKey:KEY_SLIDER_VALUE]];
        [self.mainColorWheel setBrightness:self.darknessSlider.value];
        [self.mainColorWheel updateImage];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeCGPoint:self.mainColorWheel.touchPoint forKey:KEY_WHEEL_POINT];
    [aCoder encodeFloat:self.darknessSlider.value forKey:KEY_SLIDER_VALUE];
}

- (void)darknessSliderDidChange
{
    [self.mainColorWheel setBrightness:self.darknessSlider.value];
    [self.mainColorWheel updateImage];
    [self colorWheelDidChangeColor:self.mainColorWheel];
}

- (void)clearButtonPressed
{
    NSLog(@"Clear button pressed");
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDColorPickerDidClearColor:)]) {
        [self.delegate SDColorPickerDidClearColor:self];
    }
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
