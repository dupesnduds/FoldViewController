//
//  SampleTableViewController.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "SampleTableViewController.h"

@interface SampleTableViewController ()
@property (nonatomic, strong) NSArray * sampleItems;
@end

@implementation SampleTableViewController
@synthesize sampleItems;

- (void) awakeFromNib
{
    self.sampleItems = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.sampleItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"SampleCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = [self.sampleItems objectAtIndex:indexPath.row];

    return cell;
}

- (IBAction) revealMenu:(id)sender
{
    [self.foldingViewController animateLeftView];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
