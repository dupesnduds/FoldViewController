//
//  CALayer+Hierarchy.m
//  ECSlidingViewController
//
//  Created by Cleave Pokotea on 2/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "CALayer+Hierarchy.h"

@implementation CALayer (Hierarchy)

- (void) bringSublayerToFront:(CALayer *)layer
{
    [layer removeFromSuperlayer];
    [self insertSublayer:layer atIndex:[self.sublayers count] - 1];
}

- (void) sendSublayerToBack:(CALayer *)layer
{
    [layer removeFromSuperlayer];
    [self insertSublayer:layer atIndex:0];
}

@end
