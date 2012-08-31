//
//  SampleTableViewController.h
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFoldViewController.h"

@interface SampleTableViewController : UITableViewController <UITableViewDataSource, UITabBarControllerDelegate>
- (IBAction) revealMenu:(id) sender;
@end
