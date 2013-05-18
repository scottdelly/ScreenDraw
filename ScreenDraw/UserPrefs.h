//
//  UserPrefs.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDDrawView.h"

@interface UserPrefs : NSObject

FOUNDATION_EXPORT NSString *const KEY_BACKGROUND_COLOR;
FOUNDATION_EXPORT NSString *const KEY_LINE_COLOR;
FOUNDATION_EXPORT NSString *const KEY_FILL_COLOR;
FOUNDATION_EXPORT NSString *const KEY_DRAW_MODE;

+ (UIColor *)getBackgroundColor;
+ (void)setBackgroundColor:(UIColor *)color;

+ (UIColor *)getLineColor;
+ (void)setLineColor:(UIColor *)color;

+ (UIColor *)getFillColor;
+ (void)setFillColor:(UIColor *)color;

+ (SDDrawMode)getDrawMode;
+ (void)setDrawMode:(SDDrawMode)mode;

@end
