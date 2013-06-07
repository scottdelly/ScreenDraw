//
//  SDDrawView.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDDrawView.h"
#import "UserPrefs.h"

static int viewNumber = 0;

NSString *const KEY_START_POINT = @"Start_Point";
NSString *const KEY_END_POINT = @"End_Point";

@interface SDDrawView ()

@end

@implementation SDDrawView

@synthesize title;
@synthesize lineSize;
@synthesize pointsDict;
@synthesize strokeColor, fillColor;

+ (int)getViewNumber
{
    return viewNumber++;
}

+ (NSString *)nameForDrawMode:(SDDrawMode)mode
{
    NSArray *modeNames = [NSArray arrayWithObjects:@"Brush", @"Line", @"Rectangle", @"Elipse", nil];
    return [modeNames objectAtIndex:mode];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.title = [NSString stringWithFormat:@"%i", [SDDrawView getViewNumber]];
        NSLog(@"New view with title: %@", self.title);
        self.pointsDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.pointsArray = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setTitle:[aDecoder decodeObject]];
        [self setPointsDict:[aDecoder decodeObject]];
        [self setPointsArray:[aDecoder decodeObject]];
        [self setDrawMode:[aDecoder decodeIntegerForKey:KEY_DRAW_MODE]];
        [self setLineSize:[aDecoder decodeIntegerForKey:KEY_LINE_SIZE]];
        [self setStrokeColor:[aDecoder decodeObject]];
        [self setFillColor:[aDecoder decodeObject]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.title];
    [aCoder encodeObject:self.pointsDict];
    [aCoder encodeObject:self.pointsArray];
    [aCoder encodeInteger:self.drawMode forKey:KEY_DRAW_MODE];
    [aCoder encodeInteger:self.lineSize forKey:KEY_LINE_SIZE];
    [aCoder encodeObject:self.strokeColor];
    [aCoder encodeObject:self.fillColor];
}

- (void)drawRect:(CGRect)rect {
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, self.lineSize);
    
    if (self.drawMode == drawModeLine || self.drawMode == drawModeBrush) {
        CGContextSetFillColorWithColor(context, [self.fillColor CGColor]);
        CGContextSetStrokeColorWithColor(context, [self.fillColor CGColor]);
    } else {
        CGContextSetFillColorWithColor(context, [self.fillColor CGColor]);
        CGContextSetStrokeColorWithColor(context, [self.strokeColor CGColor]);
    }
    
    NSInteger pointCount = [self.pointsDict count];
    
    CGPoint startPoint;
    CGPoint endPoint;
    BOOL hasStartPoint = NO;
    BOOL hasEndPoint = NO;
    if (pointCount > 1 && [self.pointsDict objectForKey:KEY_START_POINT]) {
        startPoint = [[self.pointsDict objectForKey:KEY_START_POINT] CGPointValue];
        hasStartPoint = YES;
    }
    if (pointCount > 1 && [self.pointsDict objectForKey:KEY_END_POINT] ) {
        endPoint = [[self.pointsDict objectForKey:KEY_END_POINT] CGPointValue];
        hasEndPoint = YES;
    }
    
    if (self.drawMode == drawModeLine && hasStartPoint && hasEndPoint) {
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    } else if (self.drawMode == drawModeRect && hasStartPoint && hasEndPoint) {
        CGRect newRect = CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
        CGContextStrokeRect(context, newRect);
        CGContextFillRect(context, newRect);
    } else if (self.drawMode == drawModeElipse && hasStartPoint && hasEndPoint){
        CGRect newRect = CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
        CGContextStrokeEllipseInRect(context, newRect);
        CGContextFillEllipseInRect(context, newRect);
    } else if (self.drawMode == drawModeBrush && pointCount > 0){
        CGRect pointRect = CGRectMake(0, 0, self.lineSize, self.lineSize);

        for (int i = 0; i < [self.pointsArray count]; i++) {
            CGPoint point = [[self.pointsArray objectAtIndex:i] CGPointValue];

            pointRect.origin.x = point.x - pointRect.size.width/2;
            pointRect.origin.y = point.y - pointRect.size.height/2;
            CGContextFillEllipseInRect(context, pointRect);
            if (i > 0 && i < [self.pointsArray count]-1) {
                CGPoint previousPoint = [[self.pointsArray objectAtIndex:i-1] CGPointValue];
                CGPoint nextPoint = [[self.pointsArray objectAtIndex:i+1] CGPointValue];
                CGContextMoveToPoint(context, previousPoint.x, previousPoint.y);
                
                CGContextAddQuadCurveToPoint(context, point.x, point.y, nextPoint.x, nextPoint.y);
                CGContextStrokePath(context);
                
 
            }
        }  
    }
}

- (void)setStartPoint:(CGPoint)point
{
    CGPoint newPoint = CGPointMake(floor(point.x), ceil(point.y));
    NSValue *pointValue = [NSValue valueWithCGPoint:newPoint];
    [self.pointsDict setObject:pointValue forKey:KEY_START_POINT];
}


- (void)setEndPoint:(CGPoint)point
{
    CGPoint newPoint = CGPointMake(floor(point.x), ceil(point.y));
    NSValue *pointValue = [NSValue valueWithCGPoint:newPoint];
    [self.pointsDict setObject:pointValue forKey:KEY_END_POINT];
    [self setNeedsDisplay];
}


- (void)addPoint:(CGPoint)point
{
    CGPoint newPoint = CGPointMake(floor(point.x), ceil(point.y));
    NSValue *pointValue = [NSValue valueWithCGPoint:newPoint];
    if ([self.pointsDict count] == 0) {
        [self setStartPoint:point];
    } else if (self.drawMode != drawModeBrush) {
        [self setEndPoint:point];
    } else {
        [self.pointsDict setObject:pointValue forKey:pointValue];
        [self setNeedsDisplay];
    }
    [self.pointsArray addObject:pointValue];
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

- (CGRect) insideRectForRect:(CGRect)outsideRect
{
    CGRect insideRect = outsideRect;
    insideRect.origin.x += self.lineSize;
    insideRect.origin.y += self.lineSize;
    insideRect.size.width -= 2* self.lineSize;
    insideRect.size.height -= 2*self.lineSize;
    
    return insideRect;
}

@end
