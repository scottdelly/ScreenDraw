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
#import "UIImage+ScreenDraw.h"

NSString *const KEY_WHEEL_POINT = @"Wheel_Poiont";
NSString *const KEY_SLIDER_VALUE = @"Slider_Value";

@interface SDColorPickerView () <ISColorWheelDelegate>

@property (nonatomic) BOOL sliderInUse;

@end

@implementation SDColorPickerView

@synthesize titleLabel;
@synthesize mainColorWheel;
@synthesize brightnessSlider;
@synthesize clearButton;
@synthesize masterColorButton;
@synthesize isClear;
@synthesize sliderInUse;


+ (CGRect)defaultFrame
{
    return CGRectMake(0, 0, 120, 139);
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat contentY = 0;
        CGRect labelFrame = CGRectMake(0, 0, frame.size.width, 16);
        self.titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        contentY += labelFrame.size.height;
        self.mainColorWheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(2, contentY, 100, 100)];
        [self setupColorWheel];
        
        contentY += self.mainColorWheel.frame.size.height;
        self.brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, 50, 100, 16)];
        [self.brightnessSlider addTarget:self action:@selector(sliderWillSlide) forControlEvents:UIControlEventTouchDown];
        [self.brightnessSlider addTarget:self action:@selector(sliderSliding) forControlEvents:UIControlEventValueChanged];
        [self.brightnessSlider addTarget:self action:@selector(sliderDidFinishSliding) forControlEvents:UIControlEventTouchUpInside];
        [self.brightnessSlider setContinuous:YES];
        [self.brightnessSlider setValue:1];
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
        self.brightnessSlider.transform = trans;

        UIColor *normalTopColor = [UIColor grayColor];
        UIColor *normalBottomColor = [UIColor darkGrayColor];
        UIColor *selectedTopColor = [UIColor lightGrayColor];
        UIColor *selectedBottomColor = [UIColor grayColor];
        
        CGFloat buttonMargin = 5.0f;
        CGFloat buttonWidth = frame.size.width/2 - 2*buttonMargin;
        CGFloat buttonHeight = 22.0f;
        
        UIImage *buttonBack = [UIImage roundedRectWithTopFillColor:normalTopColor bottomFillColor:normalBottomColor strokeColor:[UIColor whiteColor] inRect:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        UIImage *buttonBackSelected = [UIImage roundedRectWithTopFillColor:selectedTopColor bottomFillColor:selectedBottomColor strokeColor:[UIColor whiteColor] inRect:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        
        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clearButton setFrame:CGRectMake(buttonMargin, contentY, buttonWidth, buttonHeight)];
        [self.clearButton setTitle:@"X" forState:UIControlStateNormal];
        [self.clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.clearButton setBackgroundImage:buttonBack forState:UIControlStateNormal];
        [self.clearButton setBackgroundImage:buttonBackSelected forState:UIControlStateHighlighted];
        [self.clearButton setBackgroundImage:buttonBackSelected forState:UIControlStateSelected];
        [self.clearButton setBackgroundImage:buttonBackSelected forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [self.clearButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.clearButton.titleLabel setShadowOffset:CGSizeMake(0, -.5)];
        
        [self.clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.masterColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat masterColorButtonX = self.clearButton.frame.origin.x + self.clearButton.frame.size.width + 2*buttonMargin;
        [self.masterColorButton setFrame:CGRectMake(masterColorButtonX, contentY, buttonWidth, buttonHeight)];
        [self.masterColorButton setTitle:@"=" forState:UIControlStateNormal];
        [self.masterColorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.masterColorButton setBackgroundImage:buttonBack forState:UIControlStateNormal];
        [self.masterColorButton setBackgroundImage:buttonBackSelected forState:UIControlStateHighlighted];
        [self.masterColorButton setBackgroundImage:buttonBackSelected forState:UIControlStateSelected];
        [self.masterColorButton setBackgroundImage:buttonBackSelected forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [self.masterColorButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.masterColorButton.titleLabel setShadowOffset:CGSizeMake(0, -.5)];
        [self.masterColorButton addTarget:self action:@selector(masterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
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
    if (self = [self initWithFrame:[SDColorPickerView defaultFrame]]) {
        if (self.mainColorWheel) {
            [self.mainColorWheel removeFromSuperview];
        }
        [self setMainColorWheel:[aDecoder decodeObject]];
        [self.brightnessSlider setValue:[aDecoder decodeFloatForKey:KEY_SLIDER_VALUE]];
        [self setupColorWheel];
    }
    return self;
}

- (void)postInit
{
    
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

- (void)sliderWillSlide
{
    //Nothing to do ATM
}

- (void)sliderSliding
{
    self.sliderInUse = YES;
    [self.mainColorWheel previewBrightness:self.brightnessSlider.value];
}

- (void)sliderDidFinishSliding
{
    if (self.sliderInUse) {
        [self setSliderInUse:NO];
        [self.mainColorWheel setBrightness:self.brightnessSlider.value];
    }
}


- (void)clearButtonPressed
{
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

#pragma mark - ISColorWheelDelegate Methods

- (void)colorWheelIsChanging:(ISColorWheel *)colorWheel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDColorPickerIsChangingColor:)]) {
        [self.delegate SDColorPickerIsChangingColor:self];
    }
}

- (void)colorWheelDidFinishChanging:(ISColorWheel *)colorWheel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDColorPickerDidChangeColor:)]) {
        [self.delegate SDColorPickerDidChangeColor:self];
    }
}

@end
