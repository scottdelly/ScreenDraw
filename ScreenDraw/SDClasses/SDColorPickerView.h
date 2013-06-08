//
//  SDColorPickerView.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/20/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDColorPickerViewDelegate.h"
FOUNDATION_EXPORT NSString *const KEY_WHEEL_POINT;
FOUNDATION_EXPORT NSString *const KEY_SLIDER_VALUE;

@class ISColorWheel;

@interface SDColorPickerView : UIView <NSCoding>

@property (nonatomic, weak) id<SDColorPickerViewDelegate>delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ISColorWheel *mainColorWheel;
@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *masterColorButton;
@property (nonatomic) BOOL isClear;

+ (CGRect)defaultFrame;
- (void)clearButtonPressed;

@end

