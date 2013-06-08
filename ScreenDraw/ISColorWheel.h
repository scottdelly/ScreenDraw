

#import <UIKit/UIKit.h>

@class ISColorWheel;

@protocol ISColorWheelDelegate <NSObject>
@required
- (void)colorWheelIsChanging:(ISColorWheel*)colorWheel;
- (void)colorWheelDidFinishChanging:(ISColorWheel*)colorWheel;
@end


@interface ISColorWheel : UIView <NSCoding>

@property (nonatomic) CGPoint touchPoint;
@property (nonatomic) float radius;
@property (nonatomic) float cursorRadius;
@property (nonatomic, strong) UIImage* radialImage;

@property (nonatomic) float brightness;
@property (nonatomic) bool continuous;
@property (nonatomic, weak)id <ISColorWheelDelegate> delegate;

@property (nonatomic, strong) NSMutableData *pixelData;

@property (nonatomic) BOOL showReticule;
@property (nonatomic, strong) UIColor *reticuleColor;

- (void)previewBrightness:(float)brightness;
- (void)updateImage;
- (UIColor*)currentColor;
- (void)setCurrentColor:(UIColor*)color;

- (void)setTouchPoint:(CGPoint)point;

@end
