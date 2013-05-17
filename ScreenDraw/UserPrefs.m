//
//  UserPrefs.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "UserPrefs.h"

NSString *const KEY_BACKGROUND_COLOR = @"Background_Color";

@implementation UserPrefs

//@synthesize backgroundColor = _backgroundColor;

+ (UIColor *)getBackgroundColor
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject *tempObject = [prefs objectForKey:KEY_BACKGROUND_COLOR];
    if (tempObject && [tempObject isKindOfClass:[UIColor class]]) {
        return (UIColor *)tempObject;
    } else {
        return [UIColor blackColor];
    }
}

+ (void)setBackgroundColor:(UIColor *)color
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:color forKey:KEY_BACKGROUND_COLOR];
    [prefs synchronize];
}

@end
