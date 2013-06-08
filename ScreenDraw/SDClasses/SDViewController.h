//
//  SDViewController.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDDrawView.h"

FOUNDATION_EXPORT NSString *const KEY_DRAW_VIEWS;
FOUNDATION_EXPORT NSString *const KEY_COLOR_DICT;

@class SDToolPaletteVC;
@class SDColorsPaletteVC;

@interface SDViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) UIView *drawStack;
@property (nonatomic, strong) UIView *backgroundImage;
@property (nonatomic, strong) UIView *canvas;
@property (nonatomic, strong) NSMutableArray *redoDrawViews;
@property (nonatomic, strong) SDDrawView *currentDrawView;
@property (nonatomic) SDDrawMode currentDrawMode;

@property (nonatomic, strong) UIBarButtonItem *shareButton;
@property (nonatomic, strong) UIBarButtonItem *toolButton;
@property (nonatomic, strong) UIBarButtonItem *colorButton;
@property (nonatomic, strong) UIBarButtonItem *undoBarButton;
@property (nonatomic, strong) UIBarButtonItem *redoBarButton;
@property (nonatomic, strong) UIBarButtonItem *clearBarButton;

@property (nonatomic, strong) UILabel *OBLabel;

@property (nonatomic, strong) UIActionSheet *toolActionSheet;

@property (nonatomic, strong) NSMutableDictionary *colors;
@property (nonatomic, strong) SDColorsPaletteVC *mainColorPalette;
@property (nonatomic) BOOL isShowingColorPalette;

@property (nonatomic) CGFloat lineSize;
@property (nonatomic, strong) SDToolPaletteVC *mainToolPalette;
@property (nonatomic) BOOL isShowingToolPalette;

@end
