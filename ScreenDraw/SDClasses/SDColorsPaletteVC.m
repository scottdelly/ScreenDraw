//
//  SDColorsPaletteVC.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDColorsPaletteVC.h"
#import "UserPrefs.h"


NSString *const KEY_BACKGROUND_COLOR = @"Background_Color";
NSString *const KEY_FILL_COLOR = @"Fill_Color";
NSString *const KEY_STROKE_COLOR = @"Stroke_Color";


@implementation SDColorsPaletteVC
@synthesize colorPickers;
@synthesize backgroundColorPicker, fillColorPicker, strokeColorPicker;

- (id)init
{
    if (self = [super init]) {
        CGRect defaultColorPickerViewFrame = [SDColorPickerView defaultFrame];
        self.backgroundColorPicker = [[SDColorPickerView alloc] initWithFrame:defaultColorPickerViewFrame];
        self.fillColorPicker = [[SDColorPickerView alloc] initWithFrame:defaultColorPickerViewFrame];
        self.strokeColorPicker = [[SDColorPickerView alloc] initWithFrame:defaultColorPickerViewFrame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColorPicker = [aDecoder decodeObject];
        self.fillColorPicker = [aDecoder decodeObject];
        self.strokeColorPicker = [aDecoder decodeObject];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.backgroundColorPicker];
    [aCoder encodeObject:self.fillColorPicker];
    [aCoder encodeObject:self.strokeColorPicker];
}

- (void)loadView
{
    [super loadView];
        
    self.colorPickers = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat frameX = [[UIScreen mainScreen] bounds].size.width;
    CGFloat frameWidth = 120.0f;

    [self.view setFrame:CGRectMake(frameX, self.view.frame.origin.y, frameWidth, self.view.frame.size.height)];

    CGRect backgroundColorPickerFrame = [SDColorPickerView defaultFrame];
    backgroundColorPickerFrame.origin.y = 44;
    [self.backgroundColorPicker setFrame:backgroundColorPickerFrame];
    [self.backgroundColorPicker.titleLabel setText:@"Background Color"];
    [self.backgroundColorPicker.mainColorWheel setContinuous:YES];
    [self.backgroundColorPicker setTag:0];
    [self.backgroundColorPicker setDelegate:self];
    [self.colorPickers addObject:self.backgroundColorPicker];

    CGRect fillColorPickerFrame = self.fillColorPicker.frame;
    fillColorPickerFrame.origin.y = self.backgroundColorPicker.frame.origin.y + self.backgroundColorPicker.frame.size.height;
    [self.fillColorPicker setFrame:fillColorPickerFrame];
    [self.fillColorPicker.titleLabel setText:@"Fill Color"];
    [self.fillColorPicker setTag:1];
    [self.fillColorPicker setDelegate:self];
    [self.colorPickers addObject:self.fillColorPicker];
    
    CGRect strokeColorPickerFrame = self.strokeColorPicker.frame;
    strokeColorPickerFrame.origin.y = fillColorPickerFrame.origin.y + fillColorPickerFrame.size.height;
    [self.strokeColorPicker setFrame:strokeColorPickerFrame];
    [self.strokeColorPicker.titleLabel setText:@"Stroke Color"];
    [self.strokeColorPicker setTag:2];
    [self.strokeColorPicker setDelegate:self];
    [self.colorPickers addObject:self.strokeColorPicker];
    
    [self.view addSubview:self.backgroundColorPicker];
    [self.view addSubview:self.fillColorPicker];
    [self.view addSubview:self.strokeColorPicker];
}

- (void)show
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x = viewFrame.size.width - self.view.frame.size.width;
    viewFrame.size.width = self.view.frame.size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)hideWithCompletion:(void(^)(void))block
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x = viewFrame.size.width;
    viewFrame.size.width = self.view.frame.size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

- (void)clearBackgroundColor
{
    if (!self.backgroundColorPicker.isClear) {
        [self.backgroundColorPicker clearButtonPressed];
    }
}

- (NSString *)keyForPickerView:(SDColorPickerView *)pickerView
{
    if (pickerView == self.backgroundColorPicker) {
        return KEY_BACKGROUND_COLOR;
    }
    if (pickerView == self.fillColorPicker) {
        return KEY_FILL_COLOR;
    }
    if (pickerView == self.strokeColorPicker) {
        return KEY_STROKE_COLOR;
    }
    return nil;
}

#pragma mark - SDColorPickerViewDelegate Methods
- (void)SDColorPickerIsChangingColor:(SDColorPickerView *)pickerView
{
    NSString *curKey = [self keyForPickerView:pickerView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewColor:forKey:)]) {
        [self.delegate previewColor:pickerView.mainColorWheel.currentColor forKey:curKey];
    }
}

- (void)SDColorPickerDidChangeColor:(SDColorPickerView *)pickerView
{
    NSString *curKey = [self keyForPickerView:pickerView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setColor:forKey:)]) {
        [self.delegate setColor:pickerView.mainColorWheel.currentColor forKey:curKey];
    }
}

- (void)SDColorPickerDidClearColor:(SDColorPickerView *)pickerView
{
    NSString *curKey = [self keyForPickerView:pickerView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setColor:forKey:)]) {
        [self.delegate setColor:[UIColor clearColor] forKey:curKey];
    }
}

- (void)SDColorPickerIsMasterPicker:(SDColorPickerView *)masterPickerView
{
    for (SDColorPickerView *slaveView in self.colorPickers) {
        if (slaveView == masterPickerView) {
            continue;
        }
        [slaveView.mainColorWheel setTouchPoint:masterPickerView.mainColorWheel.touchPoint];
        [slaveView.brightnessSlider setValue:masterPickerView.brightnessSlider.value];
        [slaveView.mainColorWheel setBrightness:masterPickerView.brightnessSlider.value];
        [slaveView.mainColorWheel updateImage];
        [self SDColorPickerDidChangeColor:slaveView];
    }

}

@end
