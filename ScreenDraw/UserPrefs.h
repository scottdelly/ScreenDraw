//
//  UserPrefs.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPrefs : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;

FOUNDATION_EXPORT NSString *const KEY_BACKGROUND_COLOR;
+ (UIColor *)getBackgroundColor;
+ (void)setBackgroundColor:(UIColor *)color;

@end
