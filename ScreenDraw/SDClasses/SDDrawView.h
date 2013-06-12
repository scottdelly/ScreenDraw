//
//  SDDrawView.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const KEY_START_POINT;
FOUNDATION_EXPORT NSString *const KEY_END_POINT;

typedef enum SDDrawMode{
    drawModeBrush,
    drawModeLine,
    drawModeRect,
    drawModeElipse,
    numModes
}SDDrawMode;

@interface SDDrawView : UIView <NSCoding>
{
    @private CGPoint *pointsArray[4];
}
@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSMutableDictionary *pointsDict;
@property CGPoint *pointsArray;
@property (nonatomic, strong) UIBezierPath *mainPath;


//Properties from NSUD
@property (nonatomic) SDDrawMode drawMode;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic) NSInteger lineSize;

+ (NSString *)nameForDrawMode:(SDDrawMode)mode;
- (id)initWithFrame:(CGRect)frame;
//- (void)addPoint:(CGPoint)point;
//- (void)setStartPoint:(CGPoint)point;
//- (void)setEndPoint:(CGPoint)point;
- (void)addTouch:(UITouch *)touch;
- (NSString *)nameForMode:(SDDrawMode)mode;

@end
