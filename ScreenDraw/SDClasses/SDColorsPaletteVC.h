//
//  SDColorsPaletteVC.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDMenuViewController.h"
#import "SDColorPickerView.h"
#import "ISColorWheel.h"

FOUNDATION_EXPORT NSString *const KEY_COLORPICKER;

@protocol SDColorsPickerDelegate <NSObject>
@required
- (void)colorsDidChange;
- (void)changeToColor:(UIColor *)color forKey:(NSString *)key;
@end

@interface SDColorsPaletteVC : SDMenuViewController <SDColorPickerViewDelegate>

@property (nonatomic, weak) id<SDColorsPickerDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *colorPickers;

@property (nonatomic, strong) SDColorPickerView *backgroundColorPicker;
@property (nonatomic, strong) SDColorPickerView *strokeColorPicker;
@property (nonatomic, strong) SDColorPickerView *fillColorPicker;

- (void)show;
- (void)hide;

@end
