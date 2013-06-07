//
//  UIImage+ScreenDraw.h
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScreenDraw)

+ (UIImage *)imageWithColor:(UIColor *)color inRect:(CGRect)rect;
+ (UIImage *)roundedRectWithTopFillColor:(UIColor *)topFillColor bottomFillColor:(UIColor *)bottomFillColor strokeColor:(UIColor *)strokeColor inRect:(CGRect)rect;
@end
