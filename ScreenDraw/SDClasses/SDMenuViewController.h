//
//  SDMenuViewController.h
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDMenuViewController : UIViewController

- (void)show;
- (void)hideWithCompletion:(void(^)(void))block;

@end
