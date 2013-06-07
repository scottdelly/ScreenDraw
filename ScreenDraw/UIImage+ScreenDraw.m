//
//  UIImage+ScreenDraw.m
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "UIImage+ScreenDraw.h"

@implementation UIImage (ScreenDraw)

+ (UIImage *)imageWithColor:(UIColor *)color inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)roundedRectWithTopFillColor:(UIColor *)topFillColor bottomFillColor:(UIColor *)bottomFillColor strokeColor:(UIColor *)strokeColor inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    // General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Gradient Declarations
    NSArray *gradientColors = (@[
                               (id)topFillColor.CGColor,
                               (id)bottomFillColor.CGColor
                               ]);
    
    CGGradientRef background = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), NULL);
    
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4.0f];
    
    // Use the bezier as a clipping path
    [roundedRectanglePath addClip];
    
    [strokeColor setStroke];
    
    // Draw gradient within the path
    CGContextDrawLinearGradient(context, background, CGPointMake(rect.size.width/2, 0), CGPointMake(rect.size.width/2, rect.size.height), 0);
    
    // Draw border
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Cleanup
    CGGradientRelease(background);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

@end
