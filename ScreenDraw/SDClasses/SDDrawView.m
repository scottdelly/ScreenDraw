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
{
    uint ctr;
}
@end

@implementation SDDrawView

@synthesize title;
@synthesize lineSize;
//@synthesize pointsDict;
@synthesize strokeColor, fillColor;
@synthesize mainPath;

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
        [self setUserInteractionEnabled:NO];
        self.title = [NSString stringWithFormat:@"%i", [SDDrawView getViewNumber]];
        NSLog(@"New view with title: %@", self.title);
        _pointsArray = malloc(4*sizeof(CGPoint));
        self.mainPath = [UIBezierPath bezierPath];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setTitle:[aDecoder decodeObject]];
        [self setMainPath:[aDecoder decodeObject]];
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
    [aCoder encodeObject:self.mainPath];
    [aCoder encodeInteger:self.drawMode forKey:KEY_DRAW_MODE];
    [aCoder encodeInteger:self.lineSize forKey:KEY_LINE_SIZE];
    [aCoder encodeObject:self.strokeColor];
    [aCoder encodeObject:self.fillColor];
}

- (void)drawRect:(CGRect)rect {
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, self.lineSize);
    
    CGContextSetFillColorWithColor(context, [self.fillColor CGColor]);
    CGContextSetStrokeColorWithColor(context, [self.strokeColor CGColor]);
    
    CGContextAddPath(context, self.mainPath.CGPath);
    CGPathDrawingMode mode = kCGPathFillStroke;
    if (self.drawMode == drawModeBrush || self.fillColor == [UIColor clearColor]) {
        mode = kCGPathStroke;
    }
    CGContextClosePath(context);
    CGContextDrawPath(context, mode);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //set start point
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    _pointsArray[0]=touchPoint;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //set end point
    UITouch *currentTouch = [touches anyObject];
    
    CGPoint startPoint = _pointsArray[0];
    CGPoint currentPoint = [currentTouch locationInView:self];
    if (self.drawMode == drawModeLine) {
        CGMutablePathRef linePath = CGPathCreateMutable();
        CGPathMoveToPoint(linePath, NULL, startPoint.x, startPoint.y);
        CGPathAddLineToPoint(linePath, NULL, currentPoint.x, currentPoint.y);
        self.mainPath = [UIBezierPath bezierPathWithCGPath:linePath];
        CGPathRelease(linePath);
    } else if (self.drawMode == drawModeRect){
        CGRect newRect = CGRectMake(startPoint.x, startPoint.y, currentPoint.x - startPoint.x, currentPoint.y - startPoint.y);
        self.mainPath = [UIBezierPath bezierPathWithRect:newRect];
    } else if (self.drawMode == drawModeElipse){
        CGRect newRect = CGRectMake(startPoint.x, startPoint.y, currentPoint.x - startPoint.x, currentPoint.y - startPoint.y);
        self.mainPath = [UIBezierPath bezierPathWithOvalInRect:newRect];
    } else if (self.drawMode == drawModeBrush){ 
        CGPoint previousPoint = [currentTouch previousLocationInView:self];
        CGPoint mid1 = midPoint(previousPoint, _pointsArray[0]);
        CGPoint mid2 = midPoint(currentPoint, previousPoint);
        CGMutablePathRef brushPath = CGPathCreateMutable();
        CGPathMoveToPoint(brushPath, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(brushPath, NULL, previousPoint.x, previousPoint.y, mid2.x, mid2.y);
        
        CGPathAddPath(self.mainPath.CGPath, NULL, brushPath);
        _pointsArray[0] = previousPoint;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
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
