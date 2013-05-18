//
//  UserPrefs.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "UserPrefs.h"

NSString *const KEY_BACKGROUND_COLOR = @"Background_Color";
NSString *const KEY_LINE_COLOR = @"Line_Color";
NSString *const KEY_FILL_COLOR = @"Fill_Color";
NSString *const KEY_DRAW_MODE = @"Draw_Mode";

@implementation UserPrefs

+ (UIColor *)getBackgroundColor
{
    UIColor *backgroundColor = [UserPrefs retrieveColorForKey:KEY_BACKGROUND_COLOR];
    if (backgroundColor) {
        return backgroundColor;
    }
    return [UIColor whiteColor];
}

+ (void)setBackgroundColor:(UIColor *)color
{
    [UserPrefs storeColor:color forKey:KEY_BACKGROUND_COLOR];
}

+ (UIColor *)getLineColor
{
    UIColor *lineColor = [UserPrefs retrieveColorForKey:KEY_LINE_COLOR];
    if (lineColor) {
        return lineColor;
    }
    return [UIColor blueColor];
}

+ (void)setLineColor:(UIColor *)color
{
    [UserPrefs storeColor:color forKey:KEY_LINE_COLOR];
}

+ (UIColor *)getFillColor
{
    UIColor *fillColor = [UserPrefs retrieveColorForKey:KEY_FILL_COLOR];
    if (fillColor) {
        return fillColor;
    }
    return [UIColor clearColor];
}

+ (void)setFillColor:(UIColor *)color
{
    [UserPrefs storeColor:color forKey:KEY_FILL_COLOR];

}

+ (SDDrawMode)getDrawMode
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject *tempObject = [prefs objectForKey:KEY_DRAW_MODE];
    if (tempObject && [tempObject isKindOfClass:[NSNumber class]]) {
        return (SDDrawMode)[(NSNumber *)tempObject intValue];
    } else {
        return drawModeLine;
    }
}

+ (void)setDrawMode:(SDDrawMode)mode
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithInt:mode] forKey:KEY_DRAW_MODE];
    [prefs synchronize];
}

+ (void)storeColor:(UIColor *)color forKey:(id)key
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIColor *)retrieveColorForKey:(id)key
{
    NSObject *tempObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (tempObject && [tempObject isKindOfClass:[NSData class]]) {
        return (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)tempObject];
    }
    return nil;
}

@end
