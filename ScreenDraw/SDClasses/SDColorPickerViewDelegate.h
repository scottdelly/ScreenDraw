//
//  SDColorPickerViewDelegate.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/20/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SDColorPickerView;
@protocol SDColorPickerViewDelegate <NSObject>
@required
- (void)SDColorPickerDidChangeColor:(SDColorPickerView *)pickerView;
- (void)SDColorPickerDidClearColor:(SDColorPickerView *)pickerView;
- (void)SDColorPickerIsMasterPicker:(SDColorPickerView *)masterPickerView;
@end