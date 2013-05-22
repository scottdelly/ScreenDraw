//
//  UIView+ScreenDraw.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/22/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "UIView+ScreenDraw.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIView (ScreenDraw)

+ (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
