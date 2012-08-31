//
//  UnderRightViewController.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "UnderRightViewController.h"

@interface UnderRightViewController ()
@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;
@end

@implementation UnderRightViewController
@synthesize peekLeftAmount;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.peekLeftAmount = 40.0f;
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGRect frame = self.view.frame;

    frame.origin.x = 0.0f;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        frame.size.width = [UIScreen mainScreen].bounds.size.height;
    }
    else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    self.view.frame = frame;
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{

}

@end
