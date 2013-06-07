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

@property (nonatomic, strong) NSMutableArray *toolButtons;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UISlider *lineSizeSlider;
@property (nonatomic, strong) UIView *lineSizePreview;

@end

@implementation SDToolPaletteVC
@synthesize delegate;
@synthesize toolButtons;
@synthesize cameraButton;
@synthesize lineSizeSlider;
@synthesize lineSizePreview;

-(id) init
{
    if (self = [super init]) {
        self.toolButtons = [NSMutableArray arrayWithCapacity:4];
        self.lineSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 16)];
        [self.lineSizeSlider setMaximumValue:100.0f];
        [self.lineSizeSlider setValue:50.0f];
        self.lineSizePreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
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
    
    CGFloat contentY = 50.0f;
    CGFloat verticalPadding = 8.0f;
    
    CGFloat buttonWidth = 100.0f;
    CGFloat buttonX = (self.view.frame.size.width - buttonWidth)/2;
    CGFloat buttonHeight = 30.0f;
    CGFloat buttonSpacer = -1.0f;
    
    UIColor *normalTopColor = [UIColor grayColor];
    UIColor *normalBottomColor = [UIColor darkGrayColor];
    UIColor *selectedTopColor = [UIColor lightGrayColor];
    UIColor *selectedBottomColor = [UIColor grayColor];
    
    CGRect labelFrame = CGRectMake(0, contentY, self.view.frame.size.width, 16);
    UILabel *toolLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [toolLabel setBackgroundColor:[UIColor clearColor]];
    [toolLabel setTextColor:[UIColor whiteColor]];
    [toolLabel setFont:[UIFont systemFontOfSize:14]];
    [toolLabel setTextAlignment:NSTextAlignmentCenter];
    [toolLabel setText:@"Tool:"];
    [self.view addSubview:toolLabel];
    contentY+= toolLabel.frame.size.height + verticalPadding;
    
    for (int i=0; i < numModes; i++) {
        UIButton *toolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.toolButtons addObject:toolButton];
        [toolButton setFrame:CGRectMake(buttonX, contentY, buttonWidth, buttonHeight)];
        [toolButton setTitle:[SDDrawView nameForDrawMode:[self.toolButtons indexOfObject:toolButton]] forState:UIControlStateNormal];
        [toolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIRectCorner roundedCorners = 0;
        if (i==0) {
            roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
        } else if (i==(numModes-1)){
            roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
        }
        
        UIImage *buttonBack = [UIImage roundedRectWithTopFillColor:normalTopColor bottomFillColor:normalBottomColor strokeColor:[UIColor whiteColor] inRect:CGRectMake(0, 0, buttonWidth, buttonHeight) roundedCorners:roundedCorners];
        UIImage *buttonBackSelected = [UIImage roundedRectWithTopFillColor:selectedTopColor bottomFillColor:selectedBottomColor strokeColor:[UIColor whiteColor] inRect:CGRectMake(0, 0, buttonWidth, buttonHeight) roundedCorners:roundedCorners];
        
        [toolButton setBackgroundImage:buttonBack forState:UIControlStateNormal];
        [toolButton setBackgroundImage:buttonBackSelected forState:UIControlStateHighlighted];
        [toolButton setBackgroundImage:buttonBackSelected forState:UIControlStateSelected];
        [toolButton setBackgroundImage:buttonBackSelected forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [toolButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [toolButton.titleLabel setShadowOffset:CGSizeMake(0, -.5)];

        [toolButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:toolButton];
        contentY+= toolButton.frame.size.height + buttonSpacer;
    }
    contentY += verticalPadding;
    
    labelFrame = CGRectMake(0, contentY, self.view.frame.size.width, 16);
    UILabel *lineSizeLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [lineSizeLabel setBackgroundColor:[UIColor clearColor]];
    [lineSizeLabel setTextColor:[UIColor whiteColor]];
    [lineSizeLabel setFont:[UIFont systemFontOfSize:14]];
    [lineSizeLabel setTextAlignment:NSTextAlignmentCenter];
    [lineSizeLabel setText:@"Line Size:"];
    [self.view addSubview:lineSizeLabel];
    contentY+= lineSizeLabel.frame.size.height + verticalPadding;
    
    CGRect lineSizePreviewFrame = self.lineSizePreview.frame;
    lineSizePreviewFrame.origin.x = (self.view.frame.size.width - lineSizePreviewFrame.size.width)/2;
    lineSizePreviewFrame.origin.y = contentY;
    [self.lineSizePreview setFrame:lineSizePreviewFrame];
    [self updateLineSizePreview];
    
    contentY+=self.lineSizePreview.frame.size.height;
    CGRect lineSizeFrame = self.lineSizeSlider.frame;
    lineSizeFrame.origin.x = (self.view.frame.size.width - lineSizeFrame.size.width)/2;
    lineSizeFrame.origin.y = contentY;
    [self.lineSizeSlider setFrame:lineSizeFrame];
    [self.lineSizeSlider addTarget:self action:@selector(lineSizeDidChange) forControlEvents:UIControlEventAllEvents];
    [self.lineSizeSlider setContinuous:YES];
    [self.view addSubview:self.lineSizeSlider];
    
}

- (void)setLineSize:(CGFloat)size
{
    if (size >= 0 && size <= self.lineSizeSlider.maximumValue) {
        [self.lineSizeSlider setValue:size];
        [self updateLineSizePreview];
    }
}

- (void)updateLineSizePreview
{
    [self.lineSizePreview removeFromSuperview];
    [[self.lineSizePreview subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat lineSize = self.lineSizeSlider.value;
    if (lineSize >0) {
        UIColor *blackColor = [UIColor blackColor];
        UIImage *previewImage = [UIImage elipseWithTopFillColor:blackColor bottomFillColor:blackColor strokeColor:[UIColor clearColor] inRect:CGRectMake(0, 0, lineSize, lineSize)];
        UIImageView *previewImageView = [[UIImageView alloc] initWithImage:previewImage];
        CGFloat imageViewX = (self.lineSizePreview.frame.size.width - previewImage.size.width)/2;
        [previewImageView setFrame:CGRectMake(imageViewX, imageViewX, previewImageView.frame.size.width, previewImageView.frame.size.height)];
        [self.lineSizePreview addSubview:previewImageView];
    }
    [self.view addSubview:self.lineSizePreview];
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

- (void)lineSizeDidChange
{
    [self updateLineSizePreview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLineSize:)]){
        [self.delegate changeLineSize:[self.lineSizeSlider value]];
    }
}

@end
