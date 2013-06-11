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

///A weak pointer to the SDColorPickerView's delegate
@property (nonatomic, weak) id<SDColorPickerViewDelegate>delegate;

///The UILable displayed at the top of the SDColorPickerView designated for the title of the color picker
@property (nonatomic, strong) UILabel *titleLabel;

///The color wheel
@property (nonatomic, strong) ISColorWheel *mainColorWheel;

///A slider to control the brightness of the color wheel and it's output
@property (nonatomic, strong) UISlider *brightnessSlider;

///A button that toggles the color wheel's output, when off the color is set to clearColor and the color wheel's reticule is removed
@property (nonatomic, strong) UIButton *clearButton;

///A button that sets all other color pickers to the color of this color picker
@property (nonatomic, strong) UIButton *masterColorButton;

///A boolean that store whether or not the color picker is clear
@property (nonatomic, getter = isClear) BOOL clear;


///A static method that returns the default frame for color pickers.  Changing the shap of this frame will change the size of the picker.
+ (CGRect)defaultFrame;

///A function to be called when the clear button is pressed
- (void)clearButtonPressed;

@end

