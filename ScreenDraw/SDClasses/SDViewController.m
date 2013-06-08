//
//  SDViewController.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDViewController.h"
#import "UserPrefs.h"
#import "SDToolPaletteVC.h"
#import "SDColorsPaletteVC.h"
#import "ISColorWheel.h"
#import "UIView+ScreenDraw.h"
#import "UIImage+ScreenDraw.h"

NSString *const KEY_TOOLPALETTE = @"Tool_Palette";
NSString *const KEY_COLORPALETTE = @"Color_Palette";
NSString *const KEY_DRAW_VIEWS = @"Draw_Views";
NSString *const KEY_COLOR_DICT = @"Color_Dictionary";
NSString *const KEY_BACKGROUND_IMAGE = @"Background_Image";

@interface SDViewController () <SDToolPaletteDelegate, SDColorsPaletteDelegate>

@end

@implementation SDViewController
@synthesize backgroundImage;
@synthesize canvas;
@synthesize redoDrawViews;
@synthesize shareButton, toolButton, colorButton;
@synthesize undoBarButton, redoBarButton, clearBarButton;
@synthesize mainToolPalette, mainColorPalette;
@synthesize isShowingColorPalette;
@synthesize lineSize, colors;
@synthesize currentDrawMode = _currentDrawMode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.redoDrawViews = [NSMutableArray arrayWithCapacity:2];
        self.isShowingColorPalette = NO;
        self.currentDrawMode = [UserPrefs getDrawMode];
        
        self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed)];
        
        self.toolButton = [[UIBarButtonItem alloc] initWithTitle:@"Tool" style:UIBarButtonItemStylePlain target:self action:@selector(toolButtonPressed)];
        self.undoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(undoButtonPressed)];
        self.redoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(redoButtonPressed)];
        self.clearBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearButtonPressed)];
        self.colorButton = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStylePlain target:self action:@selector(colorButtonPressed)];
        
        self.lineSize = [UserPrefs getLineSize];
        
        NSObject *tempObject = [UserPrefs getObjectForKey:KEY_COLOR_DICT];
        if (tempObject && [tempObject isKindOfClass:[NSMutableDictionary class]]) {
            self.colors = (NSMutableDictionary *)tempObject;
        } else {
            self.colors = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [UIColor whiteColor], KEY_BACKGROUND_COLOR,
                           [UIColor blackColor], KEY_FILL_COLOR,
                           [UIColor blackColor], KEY_STROKE_COLOR, nil];
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.shareButton, self.toolButton, nil];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.colorButton, self.clearBarButton, self.redoBarButton, self.undoBarButton, nil];
    }
    
    self.drawStack = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.canvas = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSObject *tempObject = [UserPrefs getObjectForKey:KEY_DRAW_VIEWS];
    if (tempObject && [tempObject isKindOfClass:[NSArray class]]) {
        NSArray *tempArray = (NSArray *)tempObject;
        for (NSObject *tempArrayObject in tempArray) {
            if ([tempArrayObject isKindOfClass:[UIView class]]) {
                [self.canvas addSubview:(UIView *)tempArrayObject];
            }
        }
    }
    
    [self.drawStack addSubview:self.canvas];
    
    tempObject = [UserPrefs getObjectForKey:KEY_BACKGROUND_IMAGE];
    if (tempObject && [tempObject isKindOfClass:[UIView class]]) {
        self.backgroundImage = (UIView *)tempObject;
    } else {
        self.backgroundImage = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    
    [self.drawStack addSubview:self.backgroundImage];
    [self.drawStack sendSubviewToBack:self.backgroundImage];
    
    [self.view addSubview:self.drawStack];
    
    tempObject = [UserPrefs getObjectForKey:KEY_TOOLPALETTE];
    if (tempObject && [tempObject isKindOfClass:[SDToolPaletteVC class]]) {
        self.mainToolPalette = (SDToolPaletteVC *)tempObject;
    } else {
        self.mainToolPalette = [[SDToolPaletteVC alloc] init];
    }
    [self.mainToolPalette setDelegate:self];
    [self addChildViewController:self.mainToolPalette];
    [self.mainToolPalette hideWithCompletion:^{
        [self.mainToolPalette.view removeFromSuperview];
    }];
    [self.mainToolPalette highlightButtonAtIndex:self.currentDrawMode];
    [self.mainToolPalette setLineSize:self.lineSize];
    
    tempObject = [UserPrefs getObjectForKey:KEY_COLORPALETTE];
    if (tempObject && [tempObject isKindOfClass:[SDColorsPaletteVC class]]) {
        self.mainColorPalette = (SDColorsPaletteVC *)tempObject;
    } else {
        self.mainColorPalette = [[SDColorsPaletteVC alloc] init];
    }
    [self.mainColorPalette setDelegate:self];
    [self addChildViewController:self.mainColorPalette];
    [self.mainColorPalette hideWithCompletion:^{
        [self.mainColorPalette.view removeFromSuperview];
    }];
    self.OBLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 30)];
    
    if ([self.canvas.subviews count] < 1) {
        [self.OBLabel setText:@"Touch the screen to draw"];
        [self.OBLabel setTextAlignment:NSTextAlignmentCenter];
        [self.OBLabel setTextColor:[UIColor grayColor]];
        [self.OBLabel setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.OBLabel];
    }
    
    if (self.navigationController) {
        [self updateBarButtons];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCanvasColor];

    UIView* statusBarInterceptView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    statusBarInterceptView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapped)];
    [statusBarInterceptView addGestureRecognizer:tapRecognizer];
    [[[UIApplication sharedApplication].delegate window] addSubview:statusBarInterceptView];
}

- (void)updateCanvasColor
{
    [self.canvas setBackgroundColor:[self.colors objectForKey:KEY_BACKGROUND_COLOR]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] > 1) {
        return [super touchesBegan:touches withEvent:event];
    }
    if (self.isShowingToolPalette) {
        if ([event touchesForView:self.mainToolPalette.view]) {
            return [super touchesBegan:touches withEvent:event];
        } else {
            [self toggleToolPalette];
        }
    }
    if (self.isShowingColorPalette) {
        if ([event touchesForView:self.mainColorPalette.view]) {
            return [super touchesBegan:touches withEvent:event];
        } else {
            [self toggleColorPalette];
        }
    }
    NSLog(@"Touches began");
    if (self.OBLabel.superview) {
        [self.OBLabel removeFromSuperview];
    }
    self.currentDrawView = [[SDDrawView alloc] initWithFrame:self.view.frame];
    [self.currentDrawView setBackgroundColor:[UIColor clearColor]];
    [self.currentDrawView setDrawMode:self.currentDrawMode];
    [self.currentDrawView setFillColor:[self.colors objectForKey:KEY_FILL_COLOR]];
    [self.currentDrawView setStrokeColor:[self.colors objectForKey:KEY_STROKE_COLOR]];
    [self.currentDrawView setLineSize:self.lineSize];
    [self.canvas addSubview:self.currentDrawView];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView addPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] > 1) {
        return [super touchesBegan:touches withEvent:event];
    }
    if (self.isShowingToolPalette || self.isShowingColorPalette) {
        return [super touchesBegan:touches withEvent:event];
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView addPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] > 1) {
        return [super touchesBegan:touches withEvent:event];
    }
    if (self.isShowingToolPalette || self.isShowingColorPalette) {
        return [super touchesBegan:touches withEvent:event];
    }
    NSLog(@"touches ended");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView setEndPoint:point];
    [self updateBarButtons];
    
    [UserPrefs storeObject:self.canvas.subviews forKey:KEY_DRAW_VIEWS];
}

- (void)updateBarButtons
{
    BOOL hasSubviews = ([self.canvas.subviews count] > 0);
    BOOL hasRedoViews = ([self.redoDrawViews count] > 0);
    
    [self.undoBarButton setEnabled:hasSubviews];
    [self.redoBarButton setEnabled:hasRedoViews];
    [self.clearBarButton setEnabled:(hasSubviews || hasRedoViews)];
}

- (void)shareButtonPressed
{
    NSLog(@"Share Button pressed");
    UIImage *flattenedImage = [UIView imageFromView:self.drawStack];
    [self flashScreen];
    
    UIImageWriteToSavedPhotosAlbum(flattenedImage, nil, nil, nil);
}

-(void) flashScreen {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView* wholeScreen = [[UIView alloc] initWithFrame: CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    [keyWindow addSubview: wholeScreen];
    wholeScreen.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:1.0 animations:^{
        wholeScreen.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [wholeScreen removeFromSuperview];
    }];
}

- (void)toolButtonPressed
{
    NSLog(@"Tool Button Pressed");
    [self toggleToolPalette];
}

- (void)colorButtonPressed
{
    NSLog(@"Color Button Pressed");
    [self toggleColorPalette];
}

- (void)toggleToolPalette
{
    if (self.isShowingToolPalette) {
        [self setIsShowingToolPalette:NO];
        [self.mainToolPalette hideWithCompletion:^{
            [self.mainToolPalette.view removeFromSuperview];
        }];
    } else {
        [self.view addSubview:self.mainToolPalette.view];
        [self.view bringSubviewToFront:self.mainToolPalette.view];
        [self setIsShowingToolPalette:YES];
        [self.mainToolPalette show];
    }
}

- (void)toggleColorPalette
{
    if (self.isShowingColorPalette) {
        [self setIsShowingColorPalette:NO];
        [self.mainColorPalette hideWithCompletion:^{
            [self.mainColorPalette.view removeFromSuperview];
        }];
    } else {
        [self.view addSubview:self.mainColorPalette.view];
        [self.view bringSubviewToFront:self.mainColorPalette.view];
        [self setIsShowingColorPalette:YES];
        [self.mainColorPalette show];
    }
}

- (void)undoButtonPressed
{
    NSLog(@"Undo Button Pressed");
    NSInteger drawViewsCount = [self.canvas.subviews count];
    if (drawViewsCount > 0) {
        NSObject *tempObject = [self.canvas.subviews objectAtIndex:drawViewsCount-1];
        if (tempObject && [tempObject isKindOfClass:[UIView class]]) {
            UIView *drawView = (UIView *)tempObject;
            [self.redoDrawViews addObject:drawView];
            [drawView removeFromSuperview];
            [self.view setNeedsDisplay];
        }
    }
    [self updateBarButtons];
}

- (void)redoButtonPressed
{
    NSLog(@"Redo Button Pressed");
    NSInteger redoDrawViewsCount = [self.redoDrawViews count];
    if (redoDrawViewsCount > 0) {
        NSObject *tempObject = [self.redoDrawViews objectAtIndex:redoDrawViewsCount-1];
        if (tempObject && [tempObject isKindOfClass:[UIView class]]) {
            UIView *drawView = (UIView *)tempObject;
            [self.canvas addSubview:drawView];
            [self.redoDrawViews removeObject:drawView];
            [self.view setNeedsDisplay];
        }
    }
    [self updateBarButtons];
}

- (void)clearButtonPressed
{
    NSLog(@"Clear Button Pressed");
    UIAlertView *clearAlert = [[UIAlertView alloc] initWithTitle:@"Clear Canvas?" message:@"Are you sure you want to clear the canvas?" delegate:self cancelButtonTitle:@"Don't Clear" otherButtonTitles:@"Clear", nil];
    [clearAlert show];
}

- (void)setCurrentDrawMode:(SDDrawMode)currentDrawMode
{
    _currentDrawMode = currentDrawMode;
    [UserPrefs setDrawMode:currentDrawMode];
}

- (void)statusBarTapped
{
    NSLog(@"Status bar tapped");
    BOOL navBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!navBarHidden animated:YES];
    if (self.isShowingToolPalette) {
        [self toggleToolPalette];
    }
    if (self.isShowingColorPalette) {
        [self toggleColorPalette];
    }
}

#pragma mark - AlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"User cancelled clear");
    } else {
        NSLog(@"User sleceted clear button");
        [[self.canvas subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.redoDrawViews removeAllObjects];
        [self.view setNeedsDisplay];
        [UserPrefs clearDataForKey:KEY_DRAW_VIEWS];
        [self updateBarButtons];
    }
}

#pragma mark - SDToolPaletteDelegate Methods
- (void)changeToTool:(SDDrawMode)mode
{
    if (mode < numModes) {
        [self setCurrentDrawMode:mode];
    }
}

- (void)changeLineSize:(CGFloat)size
{
    [self setLineSize:size];
    [UserPrefs storeLineSize:size];
}

- (void)changeBackgroundImage:(UIImage *)image
{
    [[self.backgroundImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *scaledIamge = [UIImage rescaleImage:image scaledToRect:self.backgroundImage.frame];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:scaledIamge];
    [self.backgroundImage addSubview:backgroundImageView];
    [self.mainColorPalette clearBackgroundColor];
    [UserPrefs storeObject:self.backgroundImage forKey:KEY_BACKGROUND_IMAGE];
}

#pragma mark - SDColorPaletteDelegate Methods
- (void)previewColor:(UIColor *)color forKey:(NSString *)key
{
    if (key == KEY_BACKGROUND_COLOR) {
        [self.colors setObject:color forKey:key];
        [self updateCanvasColor];
    }
}

-(void)setColor:(UIColor *)color forKey:(NSString *)key
{
    [self.colors setObject:color forKey:key];
    [self updateCanvasColor];
    [UserPrefs storeObject:self.colors forKey:KEY_COLOR_DICT];
    [UserPrefs storeObject:self.mainColorPalette forKey:KEY_COLORPALETTE];
}

@end
