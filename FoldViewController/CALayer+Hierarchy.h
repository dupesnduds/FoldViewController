//
//  CALayer+Hierarchy.h
//  ECSlidingViewController
//
//  Created by Cleave Pokotea on 2/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Hierarchy)

- (void) bringSublayerToFront:(CALayer *) layer;
- (void) sendSublayerToBack:(CALayer *) layer;

@end
