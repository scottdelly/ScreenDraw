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
@end

@interface SDToolPaletteVC : SDMenuViewController

@property (nonatomic, weak) id<SDToolPaletteDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *toolButtons;
@property (nonatomic, strong) UIButton *brushButton;
@property (nonatomic, strong) UIButton *elipseButton;
@property (nonatomic, strong) UIButton *rectButton;
@property (nonatomic, strong) UIButton *lineButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UISlider *brushSize;
@property (nonatomic, strong) UIView *brushPreview;

- (void)highlightButtonAtIndex:(NSInteger)index;

@end
