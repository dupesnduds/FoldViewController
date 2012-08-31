//
//  SecondTopViewController.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "SecondTopViewController.h"

@implementation SecondTopViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![self.foldingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        self.foldingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }

    [self.view addGestureRecognizer:self.foldingViewController.panGesture];
}

- (IBAction) revealMenu:(id)sender
{
    [self.foldingViewController animateLeftView];
}

@end
