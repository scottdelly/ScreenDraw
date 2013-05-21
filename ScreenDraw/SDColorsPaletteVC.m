//
//  SDColorsPaletteVC.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDColorsPaletteVC.h"
#import "UserPrefs.h"

NSString *const KEY_COLORPICKER = @"Color_Picker";
NSString *const KEY_BACKGROUND_COLOR = @"Background_Color";
NSString *const KEY_STROKE_COLOR = @"Line_Color";
NSString *const KEY_FILL_COLOR = @"Fill_Color";

@implementation SDColorsPaletteVC
@synthesize backgroundColorPicker, strokeColorPicker, fillColorPicker;

- (void)loadView
{
    [super loadView];

    CGFloat frameX = [[UIScreen mainScreen] bounds].size.width;
    CGFloat frameWidth = 200.0f;

    [self.view setFrame:CGRectMake(frameX, self.view.frame.origin.y, frameWidth, self.view.frame.size.height)];

    NSObject *tempObject = [UserPrefs getObjectForKey:KEY_BACKGROUND_COLOR];
    if ([tempObject isKindOfClass:[SDColorPickerView class]]) {
        self.backgroundColorPicker = (SDColorPickerView *)tempObject;
    } else {
        self.backgroundColorPicker = [SDColorPickerView new];
    }
    [self.backgroundColorPicker.titleLabel setText:@"Background Color"];
    [self.backgroundColorPicker.mainColorWheel setContinuous:YES];
    [self.backgroundColorPicker setTag:0];
    [self.backgroundColorPicker setDelegate:self];

    
    tempObject = [UserPrefs getObjectForKey:KEY_STROKE_COLOR];
    if ([tempObject isKindOfClass:[SDColorPickerView class]]) {
        self.strokeColorPicker = (SDColorPickerView *)tempObject;
    } else {
        self.strokeColorPicker = [SDColorPickerView new];
    }
    CGRect lineColorPickerFrame = self.strokeColorPicker.frame;
    lineColorPickerFrame.origin.y = self.backgroundColorPicker.frame.origin.x + self.backgroundColorPicker.frame.size.height;
    [self.strokeColorPicker setFrame:lineColorPickerFrame];
    [self.strokeColorPicker.titleLabel setText:@"Stroke Color"];
    [self.strokeColorPicker setTag:1];
    [self.strokeColorPicker setDelegate:self];
    
    tempObject = [UserPrefs getObjectForKey:KEY_FILL_COLOR];
    if ([tempObject isKindOfClass:[SDColorPickerView class]]) {
        self.fillColorPicker = (SDColorPickerView *)tempObject;
    } else {
        self.fillColorPicker = [SDColorPickerView new];
    }
    CGRect fillColorPickerFrame = self.fillColorPicker.frame;
    fillColorPickerFrame.origin.y = lineColorPickerFrame.origin.y + lineColorPickerFrame.size.height;
    [self.fillColorPicker setFrame:fillColorPickerFrame];
    [self.fillColorPicker.titleLabel setText:@"Fill Color"];
    [self.fillColorPicker setTag:2];
    [self.fillColorPicker setDelegate:self];
    
    [self.view addSubview:self.backgroundColorPicker];
    [self.view addSubview:self.strokeColorPicker];
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

#pragma mark - SDColorPickerViewDelegate Methods
-(void)SDColorPickerDidChangeColor:(SDColorPickerView *)pickerView
{
    NSString *curKey;
    if (pickerView == self.backgroundColorPicker) {
        curKey = KEY_BACKGROUND_COLOR;
    } else if (pickerView == self.strokeColorPicker) {
        curKey = KEY_STROKE_COLOR;
    } else if (pickerView == self.fillColorPicker) {
        curKey = KEY_FILL_COLOR;
    }
    
    [UserPrefs storeObject:pickerView forKey:curKey];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorsDidChange)]) {
        [self.delegate colorsDidChange];
    }
}

- (void)SDColorPickerIsMasterPicker:(SDColorPickerView *)pickerView
{
    CGPoint masterTouchPoint;
    float masterDarknessValue = 0.0;
    SDColorPickerView *slaveView;
    if (pickerView == self.backgroundColorPicker) {
        //Do nothing
    } else if (pickerView == self.strokeColorPicker) {
        masterTouchPoint = self.strokeColorPicker.mainColorWheel.touchPoint;
        masterDarknessValue = self.strokeColorPicker.darknessSlider.value;
        slaveView = self.fillColorPicker;
    } else {
        masterTouchPoint = self.fillColorPicker.mainColorWheel.touchPoint;
        masterDarknessValue = self.fillColorPicker.darknessSlider.value;
        slaveView = self.strokeColorPicker;
    }
    [slaveView.mainColorWheel setTouchPoint:masterTouchPoint];
    [slaveView.darknessSlider setValue:masterDarknessValue];
    [slaveView.mainColorWheel setBrightness:masterDarknessValue];
    [slaveView.mainColorWheel updateImage];
    [self SDColorPickerDidChangeColor:slaveView];
}

@end
