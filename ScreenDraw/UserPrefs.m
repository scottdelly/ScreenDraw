//
//  UserPrefs.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "UserPrefs.h"

NSString *const KEY_DRAW_VIEWS = @"Draw_Views";
NSString *const KEY_BACKGROUND_COLOR = @"Background_Color";
NSString *const KEY_LINE_COLOR = @"Line_Color";
NSString *const KEY_FILL_COLOR = @"Fill_Color";
NSString *const KEY_DRAW_MODE = @"Draw_Mode";
NSString *const KEY_LINE_SIZE = @"Line_Size";

@implementation UserPrefs

+ (NSMutableArray *)getDrawViews
{
    NSObject *tempObject = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_DRAW_VIEWS];
    if (tempObject && [tempObject isKindOfClass:[NSData class]]) {
        return (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)tempObject];
    }
    return nil;
}

+ (void)storeDrawViews:(NSMutableArray *)drawViews
{
    NSData *drawViewsData = [NSKeyedArchiver archivedDataWithRootObject:drawViews];
    [[NSUserDefaults standardUserDefaults] setObject:drawViewsData forKey:KEY_DRAW_VIEWS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearStoredDrawViews
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_DRAW_VIEWS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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

+ (CGFloat)getLineSize
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject *tempObject = [prefs objectForKey:KEY_LINE_SIZE];
    if (tempObject && [tempObject isKindOfClass:[NSNumber class]]) {
        return (CGFloat)[(NSNumber *)tempObject floatValue];
    } else {
        return 2.0f;
    }
}

+ (void)storeLineSize:(CGFloat)size
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithInt:size] forKey:KEY_LINE_SIZE];
    [prefs synchronize];
}

+ (void)storeColor:(UIColor *)color forKey:(NSString *)key
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIColor *)retrieveColorForKey:(NSString *)key
{
    NSObject *tempObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (tempObject && [tempObject isKindOfClass:[NSData class]]) {
        return (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)tempObject];
    }
    return nil;
}

+ (void)storePoint:(CGPoint)point forKey:(NSString *)key
{
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    NSData *pointData = [NSKeyedArchiver archivedDataWithRootObject:pointValue];
    [[NSUserDefaults standardUserDefaults] setObject:pointData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSValue *)retrievePointValueForKey:(NSString *)key
{
    NSObject *tempObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (tempObject && [tempObject isKindOfClass:[NSData class]]) {
        return (NSValue *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)tempObject];
    }
    return nil;
}

@end
