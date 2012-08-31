//
//  MenuViewController.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()
@property (nonatomic, strong) NSArray * menuItems;
@end

@implementation MenuViewController
@synthesize menuItems;

- (void) awakeFromNib
{
    self.menuItems = [NSArray arrayWithObjects:@"First", @"Second", @"Third", @"Navigation", nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self.foldingViewController setRevealAmount:280.0f];
    self.foldingViewController.underLeftWidthLayout = CLFullViewWidth;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"MenuItemCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = [NSString stringWithFormat:@"%@Top", [self.menuItems objectAtIndex:indexPath.row]];

    UIViewController * newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];

     CGRect frame = self.foldingViewController.topViewController.view.frame;
     self.foldingViewController.topViewController = newTopViewController;
     self.foldingViewController.topViewController.view.frame = frame;
     [self.foldingViewController animateReset];
}

@end
