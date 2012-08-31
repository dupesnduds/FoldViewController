//
//  TFoldLayer.h
//  FoldViewController
//
//  Created by Cleave Pokotea on 30/06/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol TFoldLayerDelegate;

@interface TFoldLayer : CALayer

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat shadowLayerOpacityLeft;
@property (nonatomic, assign) CGFloat shadowLayerOpacityRight;
@property (nonatomic, strong) UIImage * image;
@property (assign) id <TFoldLayerDelegate> delegate;

- (void) setupPlayers;

@end

//
@protocol TFoldLayerDelegate <NSObject>

@optional
- (void) setClose;
- (void) setOpen;

@required

@end
