//
//  SDDrawView.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDDrawView.h"

static int viewNumber = 0;

NSString *const KEY_START_POINT = @"Start_Point";
NSString *const KEY_END_POINT = @"End_Point";

@interface SDDrawView ()

@property (nonatomic, strong) NSMutableDictionary *points;

@end

@implementation SDDrawView

@synthesize title;

+ (int)getViewNumber
{
    return viewNumber++;
}

- (id)initWithFrame:(CGRect)frame drawMode:(SDDrawMode)mode {
    if (self = [super initWithFrame:frame]) {
        self.title = [NSString stringWithFormat:@"%i", [SDDrawView getViewNumber]];
        NSLog(@"New view with title: %@", self.title);
        [self setDrawMode:mode];
        self.points = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
        
    CGPoint startPoint;
    CGPoint endPoint;
    BOOL hasStartPoint = NO;
    BOOL hasEndPoint = NO;
    if ([self.points objectForKey:KEY_START_POINT]) {
        startPoint = [[self.points objectForKey:KEY_START_POINT] CGPointValue];
        hasStartPoint = YES;
    }
    if ([self.points objectForKey:KEY_END_POINT] ) {
        endPoint = [[self.points objectForKey:KEY_END_POINT] CGPointValue];
        hasEndPoint = YES;
    }
    
    if (self.drawMode == drawModeLine && hasStartPoint && hasEndPoint) {
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    } else if (self.drawMode == drawModeRect && hasStartPoint && hasEndPoint) {
        CGRect newRect = CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
        CGContextAddRect(context, newRect);
    } else if (self.drawMode == drawModeElipse && hasStartPoint && hasEndPoint){
        CGRect newRect = CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
        CGContextAddEllipseInRect(context, newRect);
    }
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

- (void)addPoint:(CGPoint)point
{
    CGPoint newPoint = CGPointMake(floor(point.x), ceil(point.y));
    NSValue *pointValue = [NSValue valueWithCGPoint:newPoint];
    if ([self.points count] == 0) {
        [self.points setObject:pointValue forKey:KEY_START_POINT];
    } else if (self.drawMode == drawModeLine || self.drawMode == drawModeRect || self.drawMode == drawModeElipse) {
        [self.points setObject:pointValue forKey:KEY_END_POINT];
    } else {
        [self.points setObject:pointValue forKey:pointValue];
    }
    [self setNeedsDisplay];
}

- (void)setEndPoint:(CGPoint)point
{
    CGPoint newPoint = CGPointMake(floor(point.x), ceil(point.y));
    NSValue *pointValue = [NSValue valueWithCGPoint:newPoint];
    [self.points setObject:pointValue forKey:KEY_END_POINT];
    [self setNeedsDisplay];
}

- (NSString *)nameForMode:(SDDrawMode)mode
{
    if (mode == drawModeElipse) {
        return @"Elipse";
    } else if (mode == drawModeRect) {
        return @"Rectangle";
    }
    return @"Line";
}

@end
