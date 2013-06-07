//
//  SDToolPaletteVC.h
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDMenuViewController.h"
#import "SDDrawView.h"

@protocol SDToolPaletteDelegate <NSObject>
@required
- (void)changeToTool:(SDDrawMode)mode;
- (void)changeLineSize:(CGFloat)size;
@end

@interface SDToolPaletteVC : SDMenuViewController <NSCoding>

@property (nonatomic, weak) id<SDToolPaletteDelegate>delegate;

- (void)highlightButtonAtIndex:(NSInteger)index;
- (void)setLineSize:(CGFloat)size;

@end
