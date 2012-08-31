//
//  TFoldViewController.m
//  FoldViewController
//
//  Created by Cleave Pokotea on 30/06/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "TFoldViewController.h"
#import "TFoldLayer.h"
#import "UIView+Threadsafe.h"
#import "TTimer.h"

#define kTriggerWidth 50

@interface TFoldViewController ()
{
    BOOL _created;
    BOOL _peekAhBoo;
}

@property (nonatomic, strong) UIImage *menuImage;
@property (nonatomic, strong) TFoldLayer * foldingLayer;
@property (nonatomic, strong) CALayer * mainLayer;
@property (nonatomic, unsafe_unretained) TFoldStruct fold;
@property (nonatomic, unsafe_unretained) CGFloat initialTouchPositionX;
@property (nonatomic, unsafe_unretained) CGFloat currentTouchPositionX;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic, unsafe_unretained) BOOL underLeftShowing;
@property (nonatomic, unsafe_unretained) BOOL underRightShowing;
@property (nonatomic, unsafe_unretained) BOOL topViewIsOffScreen;

- (void) setTopViewController:(UIViewController *)theTopViewController;
- (void) setUnderLeftViewController:(UIViewController *)theUnderLeftViewController;
- (void) setUnderLeftWidthLayout:(TWidthLayout)underLeftWidthLayout;
- (UIView *) topView;
- (UIView *) underLeftView;
- (void) addFoldLayerToUnderLeftView;
- (void) resetUnderLeftViewLayer;
- (void) handlePan:(UIPanGestureRecognizer *)recognizer;
- (void) handleGesture:(UIGestureRecognizer *)gesture withVeloctiy:(CGPoint)speed andScale:(float)scale;
- (void) play;
- (NSUInteger) autoResizeToFillScreen;
- (void) adjustLayout;
- (void) updateUnderLeftLayout;
- (BOOL) underLeftShowing;
- (BOOL) topViewIsOffScreen;

@end

@implementation UIViewController (FoldingViewExtension)

- (TFoldViewController *) foldingViewController
{
    UIViewController * viewController = self.parentViewController;
    
    while (!(viewController == nil || [viewController isKindOfClass:[TFoldViewController class]]))
    {
        viewController = viewController.parentViewController;
    }
    
    return (TFoldViewController *) viewController;
}

@end

@implementation TFoldViewController

@synthesize underLeftViewController = _underLeftViewController;
@synthesize topViewController = _topViewController;
@synthesize peekAmount;
@synthesize revealAmount;
@synthesize underLeftWidthLayout = _underLeftWidthLayout;
@synthesize shouldAllowUserInteractionsWhenAnchored;
@synthesize foldingLayer = _foldingLayer;
@synthesize mainLayer = _mainLayer;
@synthesize fold = _fold;
@synthesize initialTouchPositionX;
@synthesize currentTouchPositionX;
@synthesize panGesture = _panGesture;
@synthesize underLeftShowing   = _underLeftShowing;
@synthesize underRightShowing  = _underRightShowing;
@synthesize topViewIsOffScreen = _topViewIsOffScreen;
@synthesize delegate;

#pragma  mark - Lifecycle
- (void) viewDidLoad
{
    [super viewDidLoad];
    _fold.state = TUnknown;
    self.shouldAllowUserInteractionsWhenAnchored = NO;
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.topView.layer.shadowOffset = CGSizeZero;
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    [self adjustLayout];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.topView.layer.shadowPath = nil;
    self.topView.layer.shouldRasterize = YES;

    [self adjustLayout];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    self.topView.layer.shouldRasterize = NO;
}

#pragma mark - Setup
- (void) setTopViewController:(UIViewController *)theTopViewController
{
    [_topViewController.view removeFromSuperview];
    [_topViewController willMoveToParentViewController:nil];
    [_topViewController removeFromParentViewController];

    _topViewController = theTopViewController;

    [self addChildViewController:self.topViewController];
    [self.topViewController didMoveToParentViewController:self];

    [_topViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
    [_topViewController.view setFrame:self.view.bounds];
    _topViewController.view.layer.shadowOffset = CGSizeZero;
    _topViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;

    [self.view addSubview:_topViewController.view];
}

- (void) setUnderLeftViewController:(UIViewController *)theUnderLeftViewController
{
    [_underLeftViewController.view removeFromSuperview];
    [_underLeftViewController willMoveToParentViewController:nil];
    [_underLeftViewController removeFromParentViewController];

    _underLeftViewController = theUnderLeftViewController;

    if (_underLeftViewController)
    {
        [self addChildViewController:self.underLeftViewController];
        [self.underLeftViewController didMoveToParentViewController:self];

        [self updateUnderLeftLayout];

        [self.view insertSubview:_underLeftViewController.view atIndex:0];
    }
}

- (void) setUnderLeftWidthLayout:(TWidthLayout)underLeftWidthLayout
{
    if (underLeftWidthLayout == TVariableViewRevealWidth && self.peekAmount <= 0)
    {
        [NSException raise:@"Invalid Width Layout" format:@"peekAmount must be set"];
    }
    else if (underLeftWidthLayout == TFixedViewRevealWidth && self.revealAmount <= 0)
    {
        [NSException raise:@"Invalid Width Layout" format:@"revealAmount must be set"];
    }

    _underLeftWidthLayout = underLeftWidthLayout;
}

- (UIView *) topView
{
    return self.topViewController.view;
}

- (UIView *) underLeftView
{
    return self.underLeftViewController.view;
}

- (void) addFoldLayerToUnderLeftView
{
    [self addSnapshot];

    if (![self.underLeftView superview])
    {
        [[self.topView superview] insertSubview:self.underLeftView belowSubview:self.topView];
    }
    
    if (![self.foldingLayer superlayer] || !self.foldingLayer)
    {
        CGFloat leftWidth;
        CGFloat clipAmount;
        
        if (_peekAhBoo)
        {
            leftWidth = self.underLeftView.frame.size.width - self.peekAmount;
            clipAmount = self.peekAmount;
        }
        else if (!_peekAhBoo)
        {
            leftWidth = self.revealAmount;
            clipAmount = self.view.frame.size.width - leftWidth;
        }
        
        self.foldingLayer = [TFoldLayer layer];
        self.foldingLayer.delegate = (id) self;
        self.foldingLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        self.foldingLayer.maxWidth = leftWidth - 1;
        
        CGRect frame = CGRectMake(0, 0, self.fold.CurrentSize.width, self.underLeftView.frame.size.height);
        self.foldingLayer.frame = frame;
        self.foldingLayer.image = self.menuImage;
        [self.foldingLayer setupPlayers];
        [self.underLeftView.layer addSublayer:self.foldingLayer];
        
        //
        if (self.fold.state == TUnknown)
        {
            _fold.InitialSize = self.foldingLayer.frame.size;
            _fold.CurrentSize = self.fold.LastSize;
            _fold.LastSize = self.fold.InitialSize;
            _fold.InitialTopPosition = CGPointMake(self.topView.frame.size.width / 2, self.topView.frame.size.height / 2);
            _fold.LastPosition = self.fold.InitialTopPosition;
            _fold.CurrentPosition = self.fold.LastPosition;
            _fold.OpenTopPosition.x = self.fold.InitialTopPosition.x + self.foldingLayer.maxWidth;
        }
        else if (self.fold.state == CLOpen || self.fold.state == TClosed)
        {
            _fold.CurrentSize = self.fold.LastSize;
            _fold.CurrentPosition = self.fold.LastPosition;
        }
    }
    else
    {
        self.foldingLayer.image = self.menuImage;
    }
}

- (void) resetUnderLeftViewLayer
{
    [self.foldingLayer removeFromSuperlayer];
}

#pragma mark - Gestures
- (UIPanGestureRecognizer *) panGesture
{
    return _panGesture;
}

- (void) handlePan:(UIPanGestureRecognizer *)pan
{
    CGFloat translation = [pan translationInView:self.view].x;
    float frameMinusPeek = self.view.frame.size.width - self.foldingLayer.maxWidth;
    CGFloat scale = translation / frameMinusPeek;

    [self handleGesture:pan withVeloctiy:[pan velocityInView:self.view] andScale:scale];
}

- (void) handleGesture:(UIGestureRecognizer *)gesture withVeloctiy:(CGPoint)speed andScale:(float)scale
{
    CGPoint currentTouchPoint = [gesture locationInView:self.view];

    self.currentTouchPositionX = currentTouchPoint.x;

    switch ( gesture.state )
    {
        case UIGestureRecognizerStateBegan:
        {
            if (![self.foldingLayer superlayer])
            {
                [self addFoldLayerToUnderLeftView];
            }

            self.initialTouchPositionX = self.currentTouchPositionX;
            [self.foldingLayer setValue:[NSNumber numberWithBool:NO] forKey:@"folding"];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (!self.foldingLayer)
            {
                break;
            }

            CGFloat width = self.currentTouchPositionX - self.underLeftView.frame.origin.x;
            CGFloat panAmount = self.currentTouchPositionX - self.initialTouchPositionX;
            [self.foldingLayer setValue:[NSNumber numberWithBool:YES] forKey:@"folding"];

            // direction
            if (panAmount > 0)
            {
                // finger touch went rightwards
            }
            else if (panAmount < 0)
            {
                // finger touch went leftwards
                if (self.fold.state == TClosed)
                {
                    // prevent unwanted artifacts
                    return;
                }
            }

            // animate
            if (self.fold.CurrentSize.width > self.foldingLayer.maxWidth)
            {
                width = self.foldingLayer.maxWidth;
            }
            else if (self.fold.CurrentSize.width < 0)
            {
                width = 0;
            }

            [self animateLeftView:width onComplete:nil];

            _fold.CurrentSize = self.foldingLayer.frame.size;
            _fold.CurrentPosition = self.topView.layer.position;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (!self.foldingLayer)
            {
                break;
            }

            [self.foldingLayer setValue:[NSNumber numberWithBool:NO] forKey:@"folding"];

            if (self.fold.CurrentSize.width == self.foldingLayer.maxWidth || self.fold.CurrentSize.width == 0)
            {
                _fold.LastSize = self.fold.CurrentSize;
                _fold.LastPosition = self.fold.CurrentPosition;
                [self resetUnderLeftViewLayer];

                if (self.fold.CurrentSize.width == 0)
                {
                    _fold.FoldDirection = TFoldViewLeftToRight;
                }
                else if (self.fold.CurrentSize.width == self.foldingLayer.maxWidth)
                {
                    _fold.FoldDirection = TFoldViewRightToLeft;
                }
            }
            else
            {
                [self play];
            }

            break;
        }

        default:
            NSLog(@"Unexpected gesture recognizer %@ state %d", gesture, gesture.state);
    }
}

#pragma mark - Animations
- (void) animateLeftView
{
    [self addFoldLayerToUnderLeftView];
    _fold.state = CLMenu;
    [self play];
}

- (void) animateLeftView:(CGFloat)width onComplete:(void (^)())complete
{
    double shadowMaxLeft = 0.5f;
    double shadowMaxRight = 1.0f;

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
         if (complete)
         {
             complete ();
         }
     }];
    [CATransaction setDisableActions:YES];

    // shadow
    CGFloat percentOfwidth = (self.foldingLayer.frame.size.width / self.foldingLayer.maxWidth);
    self.foldingLayer.shadowLayerOpacityLeft = shadowMaxLeft - percentOfwidth;
    self.foldingLayer.shadowLayerOpacityRight = shadowMaxRight - percentOfwidth;

    // layer.position
    CGPoint position = self.topView.layer.position;

    if (width >= self.foldingLayer.maxWidth)
    {
        width = self.foldingLayer.maxWidth;
    }

    //
    position.x = self.fold.InitialTopPosition.x + width;

    // check
    if (position.x > self.fold.OpenTopPosition.x)
    {
        position.x = self.fold.OpenTopPosition.x;
    }
    else if (position.x < self.fold.InitialTopPosition.x)
    {
        position.x = self.fold.InitialTopPosition.x;
    }
    self.topView.layer.position = position;

    // fold frame width
    CGRect menuFrame = self.foldingLayer.frame;
    menuFrame.size.width = self.topView.frame.origin.x;
    self.foldingLayer.frame = menuFrame;

    [CATransaction commit];
}

- (void) animateReset
{
    [self animateReset:nil];
}

- (void) animateReset:(void (^)())complete
{
    [self addFoldLayerToUnderLeftView];
    
    _fold.state = CLMenu;
    [self play];

    if (complete)
    {
        complete();
    }
}

- (void) animateOffscreen:(void (^)())complete
{
    if (complete)
    {
        complete();
    }
}

#pragma mark - Animation timer
#pragma mark Start/Stop fold
- (void) play
{
    CGFloat currentWidth = _fold.CurrentSize.width;
    CGFloat duration = 0.8;
    CGFloat tick = self.view.frame.size.width / 100;

    _fold.NumberOfSteps = self.foldingLayer.maxWidth / tick;
    _fold.IndexStep = 0;
    BOOL animate = NO;
    BOOL open = NO;

    if (![self.foldingLayer superlayer])
    {
        [self addFoldLayerToUnderLeftView];
        if (self.fold.state == TUnknown)
        {
            _fold.InitialSize = self.foldingLayer.frame.size;
            _fold.InitialTopPosition = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
            _fold.OpenTopPosition.x = self.fold.InitialTopPosition.x + self.foldingLayer.maxWidth;
        }
        else if (self.fold.state == CLOpen || self.fold.state == TClosed)
        {
            _fold.CurrentSize = self.fold.LastSize;
            _fold.CurrentPosition = self.fold.LastPosition;
        }
    }

    if (self.fold.state != CLMenu)
    {
        if (self.fold.startX == 0) {
            if (currentWidth < kTriggerWidth)
            {
                _fold.NumberOfSteps = 44;
                animate = YES;
                open = NO;
            }
            else
            {
                _fold.NumberOfSteps = 44;
                animate = YES;
                open = YES;
            }
        }
        else if (self.fold.startX == self.foldingLayer.maxWidth)
        {
            if (currentWidth >= (self.foldingLayer.maxWidth - kTriggerWidth))
            {
                _fold.NumberOfSteps = 44;
                animate = YES;
                open = YES;
            }
            else
            {
                _fold.NumberOfSteps = 44;
                animate = YES;
                open = NO;
            }
        }
    }
    else if (self.fold.state == CLMenu)
    {
        _fold.NumberOfSteps = 160;
        if (self.fold.startX == 0)
        {
            _fold.CurrentSize.width = 0;
            animate = YES;
            open = YES;
        }
        else if (self.fold.startX == self.foldingLayer.maxWidth)
        {
            _fold.CurrentSize.width = self.foldingLayer.maxWidth;
            animate = YES;
            open = NO;
        }
    }

    if (animate)
    {
        if (open)
        {
            ParametricTick animateBlock = ^(double position) {
                [self animateLeftView:position onComplete:^{
                     _fold.IndexStep++;
                     _fold.CurrentSize = self.fold.InitialSize;
                     _fold.CurrentPosition = self.fold.InitialTopPosition;
                 }];
            };

            ParametricCompletion resetBlock = ^{
                _fold.state = CLOpen;
                [self resetUnderLeftViewLayer];
            };

            [[TTimer parametericWithTicks:self.fold.NumberOfSteps
                             totalDuration:duration
                                 direction:open
                                 fromValue:self.fold.CurrentSize.width
                                   toValue:self.foldingLayer.maxWidth
                                  tickTask:animateBlock
                                completion:resetBlock] run];
        }
        else if (!open)
        {
            // close
            ParametricTick animateBlock = ^(double position) {
                [self animateLeftView:position onComplete:^{
                     _fold.IndexStep++;
                     _fold.CurrentSize = self.fold.InitialSize;
                     _fold.CurrentPosition = self.fold.InitialTopPosition;
                 }];
            };

            ParametricCompletion resetBlock = ^{
                _fold.state = TClosed;
                [self resetUnderLeftViewLayer];
            };

            [[TTimer parametericWithTicks:self.fold.NumberOfSteps
                             totalDuration:duration
                                 direction:!open
                                 fromValue:self.fold.CurrentSize.width
                                   toValue:0
                                  tickTask:animateBlock
                                completion:resetBlock] run];
        }
    }
}

#pragma mark - Fold subclass delegate
- (void) setOpen
{
    _fold.state = CLOpen;
    _fold.startX = self.foldingLayer.maxWidth;
}

- (void) setClose
{
    _fold.state = TClosed;
    _fold.startX = 0;
}

#pragma mark - Helpers
- (NSUInteger) autoResizeToFillScreen
{
    return (UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin |
            UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin);
}

- (void) adjustLayout
{
    if ([self underLeftShowing] && ![self topViewIsOffScreen])
    {
        [self updateUnderLeftLayout];
    }
    else if ([self underLeftShowing] && [self topViewIsOffScreen])
    {
        [self updateUnderLeftLayout];
    }
}

- (void) updateUnderLeftLayout
{    
    if (self.underLeftWidthLayout == CLFullViewWidth)
    {
        [self.underLeftView setAutoresizingMask:self.autoResizeToFillScreen];
        [self.underLeftView setFrame:self.view.bounds];
    }
    else if (self.underLeftWidthLayout == TVariableViewRevealWidth && !self.topViewIsOffScreen)
    {
        CGRect frame = self.view.bounds;
        CGFloat newWidth;

        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            newWidth = [UIScreen mainScreen].bounds.size.height - self.peekAmount;
        }
        else
        {
            newWidth = [UIScreen mainScreen].bounds.size.width - self.peekAmount;
        }

        frame.size.width = newWidth;

        self.underLeftView.frame = frame;
    }
    else if (self.underLeftWidthLayout == TFixedViewRevealWidth)
    {
        CGRect frame = self.view.bounds;

        frame.size.width = self.revealAmount;
        self.underLeftView.frame = frame;
    }
    else
    {
        [NSException raise:@"Invalid Width Layout" format:@"underLeftWidthLayout must be a valid CLViewWidthLayout"];
    }

    if (self.peekAmount > 0)
    {
        _peekAhBoo = YES;
    }
    else if (self.revealAmount > 0)
    {
        _peekAhBoo = NO;
    }
}

- (void) addSnapshot
{
    CGFloat leftWidth;
    CGFloat clipAmount;
    
    if (_peekAhBoo) {
        leftWidth = self.underLeftView.frame.size.width - self.peekAmount;
        clipAmount = self.peekAmount;
    } else if (!_peekAhBoo) {
        leftWidth = self.revealAmount;
        clipAmount = self.view.frame.size.width - leftWidth;
    }
    
    [UIView imageFromView:self.underLeftView 
                                  withClip:clipAmount
                      andTransparentInsets:UIEdgeInsetsMake(1, 1, 1, 1) onComplete:^(UIImage *image) {
                          self.menuImage = image;
                      }];
}


@end
