//
//  AppDelegate.m
//  TFoldViewController
//
//  Created by Cleave Pokotea on 30/06/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    TFoldViewController * foldingViewController = (TFoldViewController *) self.window.rootViewController;
    UIStoryboard * storyboard;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    }

    foldingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"FirstTop"];

    return YES;
}

@end
