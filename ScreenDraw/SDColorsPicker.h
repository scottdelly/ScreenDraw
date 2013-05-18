//
//  SDColorsPicker.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDMenuViewController.h"
#import "ISColorWheel.h"

@protocol SDColorsPickerDelegate <NSObject>
@required
- (void)colorsDidChange;
@end

@interface SDColorsPicker : SDMenuViewController <ISColorWheelDelegate>

@property (nonatomic, weak) id<SDColorsPickerDelegate>delegate;

@property (nonatomic, strong) ISColorWheel *backgroundColorPicker;
@property (nonatomic, strong) ISColorWheel *lineColorPicker;
@property (nonatomic, strong) ISColorWheel *fillColorPicker;

- (void)show;
- (void)hide;

@end
