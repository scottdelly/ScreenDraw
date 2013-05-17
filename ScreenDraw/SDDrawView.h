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
    drawModeLine,
    drawModeRect,
    drawModeElipse,
    numModes
}SDDrawMode;

@interface SDDrawView : UIView

@property (nonatomic) SDDrawMode drawMode;
@property (nonatomic, strong) NSString *title;

- (id)initWithFrame:(CGRect)frame drawMode:(SDDrawMode)mode;
- (void)addPoint:(CGPoint)point;
- (void)setEndPoint:(CGPoint)point;
- (NSString *)nameForMode:(SDDrawMode)mode;

@end
