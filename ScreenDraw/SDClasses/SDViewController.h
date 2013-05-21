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

@class SDColorsPaletteVC;

@interface SDViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIView *canvas;
@property (nonatomic, strong) NSMutableArray *drawViews;
@property (nonatomic, strong) NSMutableArray *redoDrawViews;
@property (nonatomic, strong) SDDrawView *currentDrawView;
@property (nonatomic) SDDrawMode currentDrawMode;

@property (nonatomic, strong) UIBarButtonItem *toolButton;
@property (nonatomic, strong) UIBarButtonItem *colorButton;
@property (nonatomic, strong) UIBarButtonItem *undoBarButton;
@property (nonatomic, strong) UIBarButtonItem *redoBarButton;
@property (nonatomic, strong) UIBarButtonItem *clearBarButton;

@property (nonatomic, strong) UILabel *OBLabel;

@property (nonatomic, strong) UIActionSheet *toolActionSheet;

@property (nonatomic) CGFloat lineSize;
@property (nonatomic, strong) NSMutableDictionary *colors;
@property (nonatomic, strong) SDColorsPaletteVC *mainColorPalette;
@property (nonatomic) BOOL isShowingColorPicker;

@end