//
//  TFoldViewController.h
//  FoldViewController
//
//  Created by Cleave Pokotea on 30/06/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TFoldLayer.h"
#import "Def.h"


@protocol TFoldViewControllerDelegate;

@interface TFoldViewController : UIViewController
    <TFoldLayerDelegate>
{
    CGPoint startTouchPosition;
    BOOL topViewHasFocus;
}

@property (nonatomic, strong) UIViewController * underLeftViewController;
@property (nonatomic, strong) UIViewController * topViewController;
@property (nonatomic, unsafe_unretained) CGFloat peekAmount;
@property (nonatomic, unsafe_unretained) CGFloat revealAmount;
@property (nonatomic, unsafe_unretained) BOOL shouldAllowUserInteractionsWhenAnchored;
@property (nonatomic, unsafe_unretained) TWidthLayout underLeftWidthLayout;
@property (assign) id <TFoldViewControllerDelegate> delegate;

- (UIPanGestureRecognizer *) panGesture;
- (void) animateLeftView;
- (void) animateLeftView:(CGFloat) width onComplete:(void(^) ())complete;
- (void) animateReset;
- (void) animateReset:(void(^) ())complete;

@end

@interface UIViewController (FoldingViewExtension)
- (TFoldViewController *) foldingViewController;
@end

//
@protocol TFoldViewControllerDelegate <NSObject>

@optional
@required


@end
