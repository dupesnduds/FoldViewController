//
//  FirstTopViewController.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "FirstTopViewController.h"

@implementation FirstTopViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // shadowPath, shadowOffset, and rotation is handled by TFoldViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;

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


@end