//
//  UIImage+ScreenDraw.h
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScreenDraw)

+ (UIImage *)rectWithColor:(UIColor *)color inRect:(CGRect)rect;
+ (UIImage *)roundedRectWithTopFillColor:(UIColor *)topFillColor bottomFillColor:(UIColor *)bottomFillColor strokeColor:(UIColor *)strokeColor inRect:(CGRect)rect;
+ (UIImage *)roundedRectWithTopFillColor:(UIColor *)topFillColor bottomFillColor:(UIColor *)bottomFillColor strokeColor:(UIColor *)strokeColor inRect:(CGRect)rect roundedCorners:(UIRectCorner)corners;
+ (UIImage *)elipseWithTopFillColor:(UIColor *)topFillColor bottomFillColor:(UIColor *)bottomFillColor strokeColor:(UIColor *)strokeColor inRect:(CGRect)rect;
@end
