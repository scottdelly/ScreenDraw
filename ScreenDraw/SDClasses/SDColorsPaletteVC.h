//
//  SDColorsPaletteVC.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDMenuViewController.h"
#import "SDColorPickerView.h"
#import "ISColorWheel.h"

@protocol SDColorsPaletteDelegate <NSObject>
@required
- (void)previewColor:(UIColor *)color forKey:(NSString *)key;
- (void)setColor:(UIColor *)color forKey:(NSString *)key;
@end

@interface SDColorsPaletteVC : SDMenuViewController <SDColorPickerViewDelegate>

@property (nonatomic, weak) id<SDColorsPaletteDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *colorPickers;

@property (nonatomic, strong) SDColorPickerView *backgroundColorPicker;
@property (nonatomic, strong) SDColorPickerView *fillColorPicker;
@property (nonatomic, strong) SDColorPickerView *strokeColorPicker;

@end
