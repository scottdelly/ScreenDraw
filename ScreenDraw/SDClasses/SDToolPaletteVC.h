//
//  SDToolPaletteVC.h
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDMenuViewController.h"

@interface SDToolPaletteVC : SDMenuViewController

@property (nonatomic, strong) NSArray *toolButtons;
@property (nonatomic, strong) UIButton *brushButton;
@property (nonatomic, strong) UIButton *elipseButton;
@property (nonatomic, strong) UIButton *rectButton;
@property (nonatomic, strong) UIButton *lineButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UISlider *brushSize;
@property (nonatomic, strong) UIView *brushPreview;

@end
