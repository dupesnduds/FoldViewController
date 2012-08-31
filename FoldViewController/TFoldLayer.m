//
//  TFoldLayer.m
//  FoldViewController
//
//  Created by Cleave Pokotea on 30/06/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "TFoldLayer.h"
#import "Def.h"

@interface TFoldLayer ()
{
    CGPoint _anchorPoint;
    BOOL _imageInserted;
    BOOL _inverse;
}

@property (nonatomic, strong) CALayer * leftHalfLayer;
@property (nonatomic, strong) CALayer * rightHalfLayer;
@property (nonatomic, strong) CALayer * imageLayerLeft;
@property (nonatomic, strong) CALayer * imageLayerRight;
@property (nonatomic, strong) CAGradientLayer * shadowLayerLeft;
@property (nonatomic, strong) CAGradientLayer * shadowLayerRight;
@property (nonatomic, strong) CALayer * lineLayer;

@end

@implementation TFoldLayer


@synthesize leftHalfLayer = _leftHalfLayer;
@synthesize rightHalfLayer = _rightHalfLayer;
@synthesize shadowLayerLeft = _shadowLayerLeft;
@synthesize shadowLayerRight = _shadowLayerRight;
@synthesize lineLayer = _lineLayer;
@synthesize image = _image;
@synthesize maxWidth = _maxWidth;
@synthesize shadowLayerOpacityLeft;
@synthesize shadowLayerOpacityRight;
@synthesize delegate;

@synthesize imageLayerLeft = _imageLayerLeft;
@synthesize imageLayerRight = _imageLayerRight;


- (id) init
{
    self = [super init];
    [self setupPlayers];
    _inverse = NO;
    return self;
}

- (void) setupPlayers
{
    if (!self.leftHalfLayer && !self.rightHalfLayer)
    {
        // ///////////////////////////////
        // NOTE
        //
        // the value of zDistance affects
        // the sharpness of the transform.
        // "sublayerTransform" affect ALL
        // sublayers BUT not the layer it
        // is applied to. "m34" position
        // of the 3D transform matrix is
        // set to -1/<eye distance>
        
        CATransform3D transform = CATransform3DIdentity;
        float zDistance = -1.0 / 2000;
        transform.m34 = zDistance;
        self.sublayerTransform = transform;
        // //////////////////////
        // NOTE
        //
        // -----x-----
        // |         |    LEFT
        // |         | (0.5/1.0)
        // |         |
        // -----------
        //
        //           -----x-----
        //   RIGHT   |         |
        // (0.5/1.0) |         |
        //           |         |
        //           -----------
        _anchorPoint = CGPointMake(0.5, 1.0);
        _imageInserted = NO;
        
        self.leftHalfLayer = [CALayer layer];
        self.leftHalfLayer.anchorPoint = _anchorPoint;
        self.leftHalfLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        [self addSublayer:self.leftHalfLayer];
        
        self.rightHalfLayer = [CALayer layer];
        self.rightHalfLayer.anchorPoint = _anchorPoint;
        self.rightHalfLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        [self addSublayer:self.rightHalfLayer];
        
        [self displayImageContent];
    }
}

- (void) displayImageContent
{
    _imageLayerLeft = [CALayer layer];
    _imageLayerLeft.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    [self.leftHalfLayer addSublayer:_imageLayerLeft];
    
    // subtle shadow
    self.shadowLayerLeft = [CAGradientLayer layer];
    self.shadowLayerLeft.backgroundColor = [UIColor clearColor].CGColor;
    self.shadowLayerLeft.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor,
                                   (id)[UIColor clearColor].CGColor, nil];
    self.shadowLayerLeft.startPoint = CGPointMake(0.5, 0.5);
    self.shadowLayerLeft.endPoint = CGPointMake(0.0, 0.5);
    [self.imageLayerLeft addSublayer:self.shadowLayerLeft];
    
    _imageLayerRight = [CALayer layer];
    _imageLayerRight.contents = (id) self.image.CGImage;
    _imageLayerRight.backgroundColor = [UIColor clearColor].CGColor;
    _imageLayerRight.masksToBounds = NO;
    [self.rightHalfLayer addSublayer:_imageLayerRight];
    
    // Shadow is a solid colour to ensure the effect is realistic
    self.shadowLayerRight = [CALayer layer];
    self.shadowLayerRight.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    [self.imageLayerRight addSublayer:self.shadowLayerRight];
}

- (void) layoutSublayers
{
    [super layoutSublayers];
    
    // Prevent strobe effect by making the adjustments then commiting
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self foldMenu];
    [CATransaction commit];
}

- (void) foldMenu
{
    // /////////////////////////
    // NOTE
    // Layers are animated when
    // dimensions (width) change
    CGRect frame = self.frame;
    CGSize size = frame.size;
    CGRect panel = CGRectMake(0, 0, self.maxWidth - 1, size.height);
    
    self.leftHalfLayer.frame = panel;
    self.rightHalfLayer.frame = panel;
    
    CGPoint midPoint = CGPointMake(0.5 * size.width, size.height);
    self.leftHalfLayer.position = midPoint;
    self.rightHalfLayer.position = midPoint;
    
    self.lineLayer.frame = CGRectMake(size.width - 1, 0, 1, size.height);
    
    //
    _imageLayerLeft.frame = panel;
    _imageLayerRight.frame = panel;
    _imageLayerLeft.contents = (id) self.image.CGImage;
    _imageLayerRight.contents = (id) self.image.CGImage;
    
    //
    self.shadowLayerLeft.frame = panel;
    self.shadowLayerLeft.opacity = shadowLayerOpacityLeft;
    self.shadowLayerRight.frame = panel;
    //self.shadowLayerRight.opacity = shadowLayerOpacityRight;
    
    // ////////////////////////////////////////////
    // NOTE
    // To prevent the flash as the two panels cross
    // the right shadow is reduced by half
    if (size.width < self.maxWidth-10) {
        self.shadowLayerRight.frame = CGRectMake(panel.size.width / 2, 0, panel.size.width, panel.size.height);
        self.shadowLayerRight.opacity = shadowLayerOpacityRight;
    }
    
    
    // /////////////////////////////
    // The math (Basic trigonometry)
    //
    // State can be constructed by
    // translating the left or right
    // layer at its anchor point by
    // [z=w*sin(θ)] and rotating by
    // angle [θ=cos-1(x/w)] where
    // w = ½ the current cell width
    // and x = ½ the original cell width
    CGFloat w = 0.5 * self.maxWidth;
    CGFloat x = 0.5 * size.width;
    
    if (x > w)
    {
        // over-rotation causes unwanted side effects
        x = w;
    }
    
    CGFloat theta = acosf(x / w);
    CGFloat z = sinf(theta) * w;
    CGFloat leftAngle = theta;
    CGFloat rightAngle = theta;
    
    // ////////////////////////////
    // NOTE
    //
    // This required for the pinch
    // otherwise both panels rotate
    // as a single card
    rightAngle *= -1;
    
    // The actual transformation
    CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -z);
    CATransform3D leftTransform = CATransform3DRotate(transform, leftAngle, 0.0, 1.0, 0.0);
    CATransform3D rightTransform = CATransform3DRotate(transform, rightAngle, 0.0, 1.0, 0.0);
    
    self.leftHalfLayer.transform = leftTransform;
    self.rightHalfLayer.transform = rightTransform;
    
    if (x == w && !_inverse)
    {
        _inverse = YES;
        [delegate setOpen];
    }
    else if (x == 0 && _inverse)
    {
        _inverse = NO;
        [delegate setClose];
    }
}

@end


