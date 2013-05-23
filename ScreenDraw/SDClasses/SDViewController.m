//
//  SDViewController.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDViewController.h"
#import "UserPrefs.h"
#import "SDColorsPaletteVC.h"
#import "ISColorWheel.h"
#import "UIView+ScreenDraw.h"

NSString *const KEY_DRAW_VIEWS = @"Draw_Views";
NSString *const KEY_COLOR_DICT = @"Color_Dictionary";

@interface SDViewController () <SDColorsPickerDelegate>

@end

@implementation SDViewController
@synthesize canvas;
@synthesize drawViews;
@synthesize redoDrawViews;
@synthesize shareButton, toolButton, colorButton;
@synthesize undoBarButton, redoBarButton, clearBarButton;
@synthesize toolActionSheet, mainColorPalette;
@synthesize isShowingColorPicker;
@synthesize lineSize, colors;
@synthesize currentDrawMode = _currentDrawMode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
            
        NSObject *tempObject = [UserPrefs getObjectForKey:KEY_DRAW_VIEWS];
        if (tempObject && [tempObject isKindOfClass:[NSMutableArray class]]) {
            self.drawViews = (NSMutableArray *)tempObject;
        } else {
            self.drawViews = [NSMutableArray arrayWithCapacity:2];
        }
        self.redoDrawViews = [NSMutableArray arrayWithCapacity:2];
        self.isShowingColorPicker = NO;
        self.currentDrawMode = [UserPrefs getDrawMode];
        
        self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed)];
        
        self.toolButton = [[UIBarButtonItem alloc] initWithTitle:@"Tool" style:UIBarButtonItemStylePlain target:self action:@selector(toolButtonPressed)];
        self.undoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(undoButtonPressed)];
        self.redoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(redoButtonPressed)];
        self.clearBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearButtonPressed)];
        self.colorButton = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStylePlain target:self action:@selector(colorButtonPressed)];
        
        self.lineSize = [UserPrefs getLineSize];
        
        tempObject = [UserPrefs getObjectForKey:KEY_COLOR_DICT];
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
    
    self.canvas = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:self.canvas];
    self.toolActionSheet = [[UIActionSheet alloc] initWithTitle:@"Draw Mode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Line", @"Rectangle", @"Elipse", @"Brush", nil];
    NSObject *tempObject = [UserPrefs getObjectForKey:KEY_COLORPICKER];
    if (tempObject && [tempObject isKindOfClass:[SDColorsPaletteVC class]]) {
        self.mainColorPalette = (SDColorsPaletteVC *)tempObject;
    } else {
        self.mainColorPalette = [[SDColorsPaletteVC alloc] init];
    }
    [self.mainColorPalette setDelegate:self];
    [self addChildViewController:self.mainColorPalette];
    [self.view addSubview:self.mainColorPalette.view];
    self.OBLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 30)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCanvas];
    if ([self.drawViews count] > 0) {
        for (SDDrawView *drawView in self.drawViews) {
            [self.view addSubview:drawView];
            [self.view bringSubviewToFront:drawView];
        }
    } else {
        [self.OBLabel setText:@"Touch the screen to draw"];
        [self.OBLabel setTextAlignment:NSTextAlignmentCenter];
        [self.OBLabel setTextColor:[UIColor grayColor]];
        [self.OBLabel setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.OBLabel];
    }

    if (self.navigationController) {
        [self updateBarButtons];
    }
    [self.mainColorPalette hide];
    
    
    UIView* statusBarInterceptView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    statusBarInterceptView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapped)];
    [statusBarInterceptView addGestureRecognizer:tapRecognizer];
    [[[UIApplication sharedApplication].delegate window] addSubview:statusBarInterceptView];
}

- (void)updateCanvas
{
    [self.canvas setBackgroundColor:[self.colors objectForKey:KEY_BACKGROUND_COLOR]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] > 1) {
        return [super touchesBegan:touches withEvent:event];
    }
    if (self.isShowingColorPicker) {
        if ([event touchesForView:self.mainColorPalette.view]) {
            return [super touchesBegan:touches withEvent:event];
        } else {
            [self toggleColorPickers];
        }
    }
    NSLog(@"Touches began");
    //Create a new SDDrawView
    if (self.OBLabel.superview) {
        [self.OBLabel removeFromSuperview];
    }
    self.currentDrawView = [[SDDrawView alloc] initWithFrame:self.view.frame];
    [self.currentDrawView setBackgroundColor:[UIColor clearColor]];
    [self.currentDrawView setDrawMode:self.currentDrawMode];
    [self.currentDrawView setFillColor:[self.colors objectForKey:KEY_FILL_COLOR]];
    [self.currentDrawView setStrokeColor:[self.colors objectForKey:KEY_STROKE_COLOR]];
    [self.currentDrawView setLineSize:self.lineSize];
    [self.view addSubview:self.currentDrawView];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView addPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] > 1) {
        return [super touchesBegan:touches withEvent:event];
    }
    if (self.isShowingColorPicker) {
        return [super touchesBegan:touches withEvent:event];
    }
    //Update current SDDrawView
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView addPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] > 1) {
        return [super touchesBegan:touches withEvent:event];
    }
    if (self.isShowingColorPicker) {
        return [super touchesBegan:touches withEvent:event];
    }
    NSLog(@"touches ended");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView setEndPoint:point];
    UIImage *drawnImage = [UIView imageFromView:self.currentDrawView];
    UIImageView *drawnImageView = [[UIImageView alloc] initWithImage:drawnImage];
    [self.drawViews addObject:drawnImageView];
    [self.view addSubview:drawnImageView];
    [self.currentDrawView removeFromSuperview];
    [self updateBarButtons];
    self.currentDrawView = nil;
    
    [UserPrefs storeObject:self.drawViews forKey:KEY_DRAW_VIEWS];
}

- (void)updateBarButtons
{
    BOOL hasViews = ([self.drawViews count] > 0);
    BOOL hasRedoViews = ([self.redoDrawViews count] > 0);
    
    [self.undoBarButton setEnabled:hasViews];
    [self.redoBarButton setEnabled:hasRedoViews];
    [self.clearBarButton setEnabled:hasViews];
}

- (void)shareButtonPressed
{
    NSLog(@"Share Button pressed");
    UIImage *flattenedImage = [UIView imageFromView:self.view];
    UIImageWriteToSavedPhotosAlbum(flattenedImage, nil, nil, nil);
}

- (void)toolButtonPressed
{
    NSLog(@"Tool Button Pressed");
    [self.toolActionSheet showInView:self.view];
}

- (void)colorButtonPressed
{
    NSLog(@"Color Button Pressed");
    [self toggleColorPickers];
}

- (void)toggleColorPickers
{
    if (self.isShowingColorPicker) {
        [self.mainColorPalette hide];
        [self setIsShowingColorPicker:NO];
    } else {
        [self.view bringSubviewToFront:self.mainColorPalette.view];
        [self.mainColorPalette show];
        [self setIsShowingColorPicker:YES];
    }
}

- (void)undoButtonPressed
{
    NSLog(@"Undo Button Pressed");
    NSInteger drawViewsCount = [self.drawViews count];
    if (drawViewsCount > 0) {
        NSObject *tempObject = [self.drawViews objectAtIndex:drawViewsCount-1];
        if (tempObject && [tempObject isKindOfClass:[UIImageView class]]) {
            UIImageView *drawView = (UIImageView *)tempObject;
            [self.redoDrawViews addObject:drawView];
            [self.drawViews removeObject:drawView];
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
        if (tempObject && [tempObject isKindOfClass:[UIImageView class]]) {
            UIImageView *drawView = (UIImageView *)tempObject;
            [self.drawViews addObject:drawView];
            [self.redoDrawViews removeObject:drawView];
            [self.view addSubview:drawView];
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
}

#pragma mark - AlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"User cancelled clear");
    } else {
        NSLog(@"User sleceted clear button");
        for (NSObject *tempObject in self.drawViews) {
            if (tempObject && [tempObject isKindOfClass:[UIImageView class]]) {
                UIImageView *drawView = (UIImageView *)tempObject;
                [drawView removeFromSuperview];
            }
        }
        [self.drawViews removeAllObjects];
        [self.redoDrawViews removeAllObjects];
        [self.view setNeedsDisplay];
        [UserPrefs clearDataForKey:KEY_DRAW_VIEWS];
        [self updateBarButtons];
    }
}

#pragma mark - ActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Action sheet dismissed with button at index: %i", buttonIndex);
    if (buttonIndex < numModes) {
        [self setCurrentDrawMode:buttonIndex];
    }
}

#pragma mark - SDColorPickerDelegate Methods
-(void)colorsDidChange
{
    [self updateCanvas];
}

-(void)changeToColor:(UIColor *)color forKey:(NSString *)key
{
    [self.colors setObject:color forKey:key];
    [self updateCanvas];
    [UserPrefs storeObject:self.colors forKey:KEY_COLOR_DICT];
    [UserPrefs storeObject:self.mainColorPalette forKey:KEY_COLORPICKER];
}

@end
