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
FOUNDATION_EXPORT NSString *const KEY_STROKE_COLOR;
FOUNDATION_EXPORT NSString *const KEY_FILL_COLOR;
FOUNDATION_EXPORT NSString *const KEY_DRAW_MODE;
FOUNDATION_EXPORT NSString *const KEY_LINE_SIZE;

+ (void)storeObject:(NSObject *)object forKey:(NSString *)key;
+ (NSObject *)getObjectForKey:(NSString *)key;
+ (void)clearDataForKey:(NSString *)key;

+ (SDDrawMode)getDrawMode;
+ (void)setDrawMode:(SDDrawMode)mode;

+ (CGFloat)getLineSize;
+ (void)storeLineSize:(CGFloat)size;

//+ (void)storePoint:(CGPoint)point forKey:(NSString *)key;
//+ (NSValue *)getPointValueForKey:(NSString *)key;

@end
