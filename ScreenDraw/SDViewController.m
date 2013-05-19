//
//  SDViewController.m
//  ScreenDraw
//
//  Created by Scott Delly on 5/17/13.
//  Copyright (c) 2013 Scott Delly. All rights reserved.
//

#import "SDViewController.h"
#import "UserPrefs.h"
#import "SDColorsPicker.h"
#import "ISColorWheel.h"

@interface SDViewController () <SDColorsPickerDelegate>

@end

@implementation SDViewController
@synthesize acceptTouches;
@synthesize canvas;
@synthesize drawViews;
@synthesize redoDrawViews;
@synthesize toolButton, colorButton;
@synthesize undoBarButton, redoBarButton, clearBarButton;
@synthesize toolActionSheet, mainColorPicker;
@synthesize isShowingColorPicker;
@synthesize currentDrawMode = _currentDrawMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.acceptTouches = YES;
        if (!(self.drawViews = [UserPrefs getDrawViews])) {
            self.drawViews = [NSMutableArray arrayWithCapacity:2];
        }
        self.redoDrawViews = [NSMutableArray arrayWithCapacity:2];
        self.isShowingColorPicker = NO;
        self.currentDrawMode = [UserPrefs getDrawMode];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    CGFloat canvasHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    CGRect fullScreen = CGRectMake(0, 0, self.view.frame.size.width, canvasHeight);
    self.canvas = [[UIView alloc] initWithFrame:fullScreen];
    [self.view addSubview:self.canvas];
    self.toolActionSheet = [[UIActionSheet alloc] initWithTitle:@"Draw Mode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Line", @"Rectangle", @"Elipse", @"Brush", nil];
    self.mainColorPicker = [[SDColorsPicker alloc] initWithNibName:nil bundle:nil];
    [self.mainColorPicker setDelegate:self];
    [self addChildViewController:self.mainColorPicker];
    [self.view addSubview:self.mainColorPicker.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCanvas];
    for (SDDrawView *drawView in self.drawViews) {
        [self.view addSubview:drawView];
        [self.view bringSubviewToFront:drawView];
    }
    if (self.navigationController) {
        self.toolButton = [[UIBarButtonItem alloc] initWithTitle:@"Tool" style:UIBarButtonItemStylePlain target:self action:@selector(toolButtonPressed)];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.toolButton, nil];
        
        self.undoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(undoButtonPressed)];
        self.redoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(redoButtonPressed)];
        self.clearBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearButtonPressed)];
        self.colorButton = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStylePlain target:self action:@selector(colorButtonPressed)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.colorButton, self.clearBarButton, self.redoBarButton, self.undoBarButton, nil];

        [self updateBarButtons];
    }
}

- (void)updateCanvas
{
    [self.canvas setBackgroundColor:[UserPrefs getBackgroundColor]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.acceptTouches) {
        return [super touchesBegan:touches withEvent:event];
    }
    NSLog(@"Touches began");
    //Create a new SDDrawView
    self.currentDrawView = [[SDDrawView alloc] initWithFrame:self.view.frame drawMode:self.currentDrawMode];
    [self.currentDrawView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.currentDrawView];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView addPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.acceptTouches) {
        return [super touchesBegan:touches withEvent:event];
    }
//    NSLog(@"touches moved");
    //Update current SDDrawView
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView addPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.acceptTouches) {
        return [super touchesBegan:touches withEvent:event];
    }
    NSLog(@"touches ended");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.currentDrawView];
    [self.currentDrawView setEndPoint:point];
    [self.drawViews addObject:self.currentDrawView];
    [self updateBarButtons];
    self.currentDrawView = nil;
    
    [UserPrefs storeDrawViews:self.drawViews];
    //Close SDDrawView
}

- (void)updateBarButtons
{
    BOOL hasViews = ([self.drawViews count] > 0);
    BOOL hasRedoViews = ([self.redoDrawViews count] > 0);
    
    [self.undoBarButton setEnabled:hasViews];
    [self.redoBarButton setEnabled:hasRedoViews];
    [self.clearBarButton setEnabled:hasViews];

}

- (void)toolButtonPressed
{
    NSLog(@"Tool Button Pressed");
    [self.toolActionSheet showInView:self.view];
}

- (void)colorButtonPressed
{
    NSLog(@"Color Button Pressed");
    if (self.isShowingColorPicker) {
        [self.mainColorPicker hide];
        [self setAcceptTouches:YES];
    } else {
        [self.view bringSubviewToFront:self.mainColorPicker.view];
        [self.mainColorPicker show];
        [self setAcceptTouches:NO];
    }
    self.isShowingColorPicker = !self.isShowingColorPicker;
}

- (void)undoButtonPressed
{
    NSLog(@"Undo Button Pressed");
    NSInteger drawViewsCount = [self.drawViews count];
    if (drawViewsCount > 0) {
        NSObject *tempObject = [self.drawViews objectAtIndex:drawViewsCount-1];
        if (tempObject && [tempObject isKindOfClass:[SDDrawView class]]) {
            SDDrawView *drawView = (SDDrawView *)tempObject;
            [self.redoDrawViews addObject:drawView];
            [self.drawViews removeObject:drawView];
            [drawView removeFromSuperview];
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
        if (tempObject && [tempObject isKindOfClass:[SDDrawView class]]) {
            SDDrawView *drawView = (SDDrawView *)tempObject;
            [self.drawViews addObject:drawView];
            [self.redoDrawViews removeObject:drawView];
            [self.view addSubview:drawView];
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

#pragma mark - AlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"User cancelled clear");
    } else {
        NSLog(@"User sleceted clear button");
        for (NSObject *tempObject in self.drawViews) {
            if (tempObject && [tempObject isKindOfClass:[SDDrawView class]]) {
                SDDrawView *drawView = (SDDrawView *)tempObject;
                [drawView removeFromSuperview];
            }
        }
        [self.drawViews removeAllObjects];
        [self.redoDrawViews removeAllObjects];
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

@end
