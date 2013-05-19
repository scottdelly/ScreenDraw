

#import <UIKit/UIKit.h>

@class ISColorWheel;

@protocol ISColorWheelDelegate <NSObject>
@required
- (void)colorWheelDidChangeColor:(ISColorWheel*)colorWheel;
@end


@interface ISColorWheel : UIView
{
    UIImage* _radialImage;
    float _radius;
    float _cursorRadius;
//    CGPoint _touchPoint;
    float _brightness;
    bool _continuous;
    id <ISColorWheelDelegate> _delegate;
    
}
@property (nonatomic) CGPoint touchPoint;
@property(nonatomic)float radius;
@property(nonatomic)float cursorRadius;
@property(nonatomic)float brightness;
@property(nonatomic)bool continuous;
@property(nonatomic, weak)id <ISColorWheelDelegate> delegate;

- (void)updateImage;
- (UIColor*)currentColor;
- (void)setCurrentColor:(UIColor*)color;

- (void)setTouchPoint:(CGPoint)point;

@end
