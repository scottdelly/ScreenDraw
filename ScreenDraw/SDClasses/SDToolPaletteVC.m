//
//  SDToolPaletteVC.m
//  ScreenDraw
//
//  Created by Scott Delly on 6/6/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDToolPaletteVC.h"
#import "SDDrawView.h"
#import "UIImage+ScreenDraw.h"

@interface SDToolPaletteVC ()

@end

@implementation SDToolPaletteVC
@synthesize delegate;
@synthesize toolButtons;
@synthesize brushButton;
@synthesize elipseButton;
@synthesize rectButton;
@synthesize lineButton;
@synthesize cameraButton;
@synthesize brushSize;
@synthesize brushPreview;

-(id) init
{
    if (self = [super init]) {

        self.toolButtons = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self = [self init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

}

- (void)loadView
{
    [super loadView];
        
    CGFloat frameWidth = 120.0f;
    CGFloat frameX = 0 - frameWidth;
    
    [self.view setFrame:CGRectMake(frameX, self.view.frame.origin.y, frameWidth, self.view.frame.size.height)];
    
    CGFloat buttonWidth = 100.0f;
    CGFloat buttonX = (self.view.frame.size.width - buttonWidth)/2;
    CGFloat buttonY = 50.0f;
    CGFloat buttonHeight = 30.0f;
    CGFloat buttonSpacer = 10.0f;
    
    UIColor *normalTopColor = [UIColor grayColor];
    UIColor *normalBottomColor = [UIColor darkGrayColor];
    UIColor *selectedTopColor = [UIColor lightGrayColor];
    UIColor *selectedBottomColor = [UIColor grayColor];
    
    UIImage *buttonBack = [UIImage roundedRectWithTopFillColor:normalTopColor bottomFillColor:normalBottomColor strokeColor:[UIColor whiteColor] inRect:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    UIImage *buttonBackSelected = [UIImage roundedRectWithTopFillColor:selectedTopColor bottomFillColor:selectedBottomColor strokeColor:[UIColor whiteColor] inRect:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    
    for (int i=0; i < numModes; i++) {
        UIButton *toolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.toolButtons addObject:toolButton];
        [toolButton setFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
        [toolButton setTitle:[SDDrawView nameForDrawMode:[self.toolButtons indexOfObject:toolButton]] forState:UIControlStateNormal];
        [toolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [toolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [toolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [toolButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [toolButton setBackgroundImage:buttonBack forState:UIControlStateNormal];
        [toolButton setBackgroundImage:buttonBackSelected forState:UIControlStateHighlighted];
        [toolButton setBackgroundImage:buttonBackSelected forState:UIControlStateSelected];
        [toolButton setBackgroundImage:buttonBackSelected forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [toolButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [toolButton.titleLabel setShadowOffset:CGSizeMake(0, -.5)];

        [toolButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:toolButton];
        buttonY+= toolButton.frame.size.height + buttonSpacer;
    }
    
}

- (void)show
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x =  0;
    viewFrame.size.width = self.view.frame.size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)hideWithCompletion:(void(^)(void))block
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    viewFrame.origin.x = 0-viewFrame.size.width;
    viewFrame.size.width = self.view.frame.size.width;
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:viewFrame];
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

- (void)highlightButtonAtIndex:(NSInteger)index
{
    if ([self.toolButtons count] > index && index >= 0) {
        UIButton *buttonAtindex = [self.toolButtons objectAtIndex:index];
        [buttonAtindex setSelected:YES];
        for (UIButton *tempButton in self.toolButtons) {
            if (tempButton != buttonAtindex) {
                [tempButton setSelected:NO];
            }
        }
    }
}

- (void)buttonPressed:(id)sender
{
    NSLog(@"Tool Button pressed");
    if (sender && [sender isKindOfClass:[UIButton class]] && [self.toolButtons containsObject:sender]){
        UIButton *pressedButton = (UIButton *)sender;
        
        [self highlightButtonAtIndex:[self.toolButtons indexOfObject:pressedButton]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeToTool:)]){
            [self.delegate changeToTool:[self.toolButtons indexOfObject:sender]];
        }
    }

}

@end
