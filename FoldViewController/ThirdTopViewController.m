//
//  ThirdTopViewController.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "ThirdTopViewController.h"

@implementation ThirdTopViewController

- (void) awakeFromNib
{

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![self.foldingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        self.foldingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }


    [self.view addGestureRecognizer:self.foldingViewController.panGesture];
}

- (IBAction) revealMenu:(id)sender
{
    [self.foldingViewController animateLeftView];
}

// foldingViewController notification
- (void) underLeftWillAppear:(NSNotification *)notification
{
    NSLog(@"under left will appear");
}

- (void) topDidAnchorRight:(NSNotification *)notification
{
    NSLog(@"top did anchor right");
}

- (void) underRightWillAppear:(NSNotification *)notification
{
    NSLog(@"under right will appear");
}

- (void) topDidAnchorLeft:(NSNotification *)notification
{
    NSLog(@"top did anchor left");
}

- (void) topDidReset:(NSNotification *)notification
{
    NSLog(@"top did reset");
}

@end
