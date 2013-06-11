//
//  UserPrefs.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "UserPrefs.h"
#import "SDColorPickerView.h"
#import "ISColorWheel.h"

NSString *const KEY_DRAW_MODE = @"Draw_Mode";
NSString *const KEY_LINE_SIZE = @"Line_Size";

@implementation UserPrefs

+ (void)storeObject:(NSObject *)object forKey:(NSString *)key
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
        [[NSUserDefaults standardUserDefaults] setObject:objectData forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

+ (NSObject *)getObjectForKey:(NSString *)key
{
    NSObject *tempObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (tempObject && [tempObject isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)tempObject];
    }
    return nil;
}

+ (void)clearDataForKey:(NSString *)key
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

+ (SDDrawMode)getDrawMode
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject *tempObject = [prefs objectForKey:KEY_DRAW_MODE];
    if (tempObject && [tempObject isKindOfClass:[NSNumber class]]) {
        return (SDDrawMode)[(NSNumber *)tempObject intValue];
    } else {
        return drawModeBrush;
    }
}

+ (void)setDrawMode:(SDDrawMode)mode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithInt:mode] forKey:KEY_DRAW_MODE];
        [prefs synchronize];
    });
}

+ (CGFloat)getLineSize
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject *tempObject = [prefs objectForKey:KEY_LINE_SIZE];
    if (tempObject && [tempObject isKindOfClass:[NSNumber class]]) {
        return (CGFloat)[(NSNumber *)tempObject floatValue];
    } else {
        return 10.0f;
    }
}

+ (void)storeLineSize:(CGFloat)size
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithInt:size] forKey:KEY_LINE_SIZE];
        [prefs synchronize];
    });
}

//+ (void)storePoint:(CGPoint)point forKey:(NSString *)key
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSValue *pointValue = [NSValue valueWithCGPoint:point];
//        NSData *pointData = [NSKeyedArchiver archivedDataWithRootObject:pointValue];
//        [[NSUserDefaults standardUserDefaults] setObject:pointData forKey:key];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    });
//}
//
//+ (NSValue *)getPointValueForKey:(NSString *)key
//{
//    NSObject *tempObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
//    if (tempObject && [tempObject isKindOfClass:[NSData class]]) {
//        return (NSValue *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)tempObject];
//    }
//    return nil;
//}

@end
