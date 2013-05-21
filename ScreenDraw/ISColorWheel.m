
#import "ISColorWheel.h"

typedef struct
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    
} PixelRGB;

float ISColorWheel_PointDistance (CGPoint p1, CGPoint p2)
{
    return sqrtf((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}


PixelRGB ISColorWheel_HSBToRGB (float h, float s, float v)
{
    h *= 6.0f;
    int i = floorf(h);
    float f = h - (float)i;
    float p = v *  (1.0f - s);
    float q = v * (1.0f - s * f);
    float t = v * (1.0f - s * (1.0f - f));
    
    float r;
    float g;
    float b;
    
    switch (i)
    {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:        // case 5:
            r = v;
            g = p;
            b = q;
            break;
    }
    
    PixelRGB pixel;
    pixel.r = r * 255.0f;
    pixel.g = g * 255.0f;
    pixel.b = b * 255.0f;
    
    return pixel;
}

@interface ISColorWheel ()

- (PixelRGB)colorAtPoint:(CGPoint)point;

- (CGPoint)viewToImageSpace:(CGPoint)point;


@end

NSString *const KEY_FRAME = @"FRAME";
NSString *const KEY_TOUCH_POINT = @"Touch_Point";

@implementation ISColorWheel
@synthesize radius;
@synthesize cursorRadius;
@synthesize brightness = _brightness;
@synthesize delegate;
@synthesize touchPoint = _touchPoint;
@synthesize continuous;
@synthesize showReticule = _showReticule;
@synthesize reticuleColor;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _brightness = 1.0;
        self.cursorRadius = 8;
        self.backgroundColor = [UIColor clearColor];
        _touchPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        self.continuous = false;
        self.radius = (MIN(self.frame.size.width, self.frame.size.height) / 2.0) - 1.0;
        self.radialImage = nil;
        self.showReticule = YES;
        [self postInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    CGRect frame = [aDecoder decodeCGRectForKey:KEY_FRAME];
    if (self = [self initWithFrame:frame]) {
        _touchPoint = [aDecoder decodeCGPointForKey:KEY_TOUCH_POINT];
        [self postInit];
    }
    return self;
}

- (void)postInit
{
    [self setReticuleColor];
    [self updateImage];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGRect:self.frame forKey:KEY_FRAME];
    [aCoder encodeCGPoint:self.touchPoint forKey:KEY_TOUCH_POINT];
}

- (PixelRGB)colorAtPoint:(CGPoint)point
{
    CGPoint center = CGPointMake(self.radius, self.radius);
    
    float angle = atan2(point.x - center.x, point.y - center.y) + M_PI;
    float dist = ISColorWheel_PointDistance(point, CGPointMake(center.x, center.y));
    
    float hue = angle / (M_PI * 2.0f);
    
    hue = MIN(hue, 1.0f - .0000001f);
    hue = MAX(hue, 0.0f);
    
    float sat = dist / (self.radius);
    
    sat = MIN(sat, 1.0f);
    sat = MAX(sat, 0.0f);
    
    return ISColorWheel_HSBToRGB(hue, sat, self.brightness);
}

- (CGPoint)viewToImageSpace:(CGPoint)point
{    
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    
    point.y = height - point.y;
        
    CGPoint min = CGPointMake(width / 2 - self.radius, height / 2 - self.radius);
    
    point.x = point.x - min.x;
    point.y = point.y - min.y;
    
    return point;
}

- (void)setBrightness:(float)brightness
{
    _brightness = brightness;
    self.radialImage = nil;
    [self updateImage];
    [self setReticuleColor];
    if (self.showReticule) {
        [self.delegate colorWheelDidChangeColor:self];
    }
}

- (void)updateImage
{
    if (self.radialImage) {
        return;
    }

    int width = self.radius *2;
    int height = self.radius *2;
    
    int dataLength = sizeof(PixelRGB) * width * height;
    self.pixelData = [NSMutableData dataWithLength:dataLength];
    PixelRGB* data = [self.pixelData mutableBytes];//malloc(dataLength);
    
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            data[x + y * width] = [self colorAtPoint:CGPointMake(x, y)];
        }
    }
    
    CGBitmapInfo bitInfo = kCGBitmapByteOrderDefault;
    
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	CGImageRef iref = CGImageCreate (width,
                                     height,
                                     8,
                                     24,
                                     width * 3,
                                     colorspace,
                                     bitInfo,
                                     ref,
                                     NULL,
                                     true,
                                     kCGRenderingIntentDefault
                                     );
    
    self.radialImage = [UIImage imageWithCGImage:iref];
    
    
    CGImageRelease(iref);
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(ref);
    
    [self setNeedsDisplay];
}

- (UIColor*)currentColor
{
    PixelRGB pixel = [self colorAtPoint:[self viewToImageSpace:self.touchPoint]];
    UIColor *currentColor = [UIColor colorWithRed:pixel.r / 255.0f green:pixel.g / 255.0f blue:pixel.b / 255.0f alpha:1.0];
    return currentColor;
}

- (void)setCurrentColor:(UIColor*)color
{
    
}

- (void)drawRect:(CGRect)rect
{
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    
    CGPoint center = CGPointMake(width / 2.0, height / 2.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState (ctx);
    
    CGContextAddEllipseInRect(ctx, CGRectMake(center.x - self.radius, center.y - self.radius, self.radius * 2.0, self.radius * 2.0));
    CGContextClip(ctx);
    
    CGContextDrawImage(ctx, CGRectMake(center.x - self.radius, center.y - self.radius, self.radius * 2.0, self.radius * 2.0), [self.radialImage CGImage]);
    

    if (self.showReticule) {
        CGContextSetLineWidth(ctx, 2.0);
        CGContextSetStrokeColorWithColor(ctx, [self.reticuleColor CGColor]);
            CGContextAddEllipseInRect(ctx, CGRectMake(self.touchPoint.x - self.cursorRadius, self.touchPoint.y - self.cursorRadius, self.cursorRadius * 2.0, self.cursorRadius * 2.0));
        CGContextStrokePath(ctx);
    }
    CGContextSetLineWidth(ctx, 1.0);
    CGSize shadowOffset = CGSizeMake(0, 0);
    CGContextSetShadowWithColor(ctx, shadowOffset, 3, [[UIColor grayColor] CGColor]);

    CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    CGContextAddEllipseInRect(ctx, CGRectMake(center.x - self.radius, center.y - self.radius, self.radius * 2.0, self.radius * 2.0)); ///This draws a circle around the color picker
    CGContextStrokePath(ctx);

    CGContextRestoreGState(ctx);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateImage];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchPoint:[[touches anyObject] locationInView:self]];
    self.showReticule = YES;
    [self setNeedsDisplay];
    
    if (self.continuous)
    {
        [self.delegate colorWheelDidChangeColor:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchPoint:[[touches anyObject] locationInView:self]];
    [self setNeedsDisplay];
    
    if (self.continuous)
    {
        [self.delegate colorWheelDidChangeColor:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate colorWheelDidChangeColor:self];
}

- (void)setTouchPoint:(CGPoint)point
{
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    
    CGPoint center = CGPointMake(width / 2.0, height / 2.0);
    
    // Check if the touch is outside the wheel
    if (ISColorWheel_PointDistance(center, point) < self.radius)
    {
        _touchPoint = point;
    }
    else
    {
        // If so we need to create a drection vector and calculate the constrained point
        CGPoint vec = CGPointMake(point.x - center.x, point.y - center.y);
        
        float extents = sqrtf((vec.x * vec.x) + (vec.y * vec.y));
        
        vec.x /= extents;
        vec.y /= extents;
        
        _touchPoint = CGPointMake(center.x + vec.x * self.radius, center.y + vec.y * self.radius);
    }
    [self setReticuleColor];
}

- (void)setShowReticule:(BOOL)showReticule
{
    if (showReticule != _showReticule) {
        _showReticule = showReticule;
        [self setNeedsDisplay];
    }
    if (showReticule) {
        [self.delegate colorWheelDidChangeColor:self];
    }
}

- (void)setReticuleColor
{
//    CGFloat RGBColor = 1 - self.brightness; For inverse of brightness

//    //For inverse of current color
//    CGColorRef currentColor = [[self currentColor] CGColor];
//    CGFloat rColor = 1 - CGColorGetComponents(currentColor)[0];
//    CGFloat gColor = 1 - CGColorGetComponents(currentColor)[1];
//    CGFloat bColor = 1 - CGColorGetComponents(currentColor)[2];

    self.reticuleColor = [UIColor whiteColor];
}

@end
