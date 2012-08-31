//
//  CAKeyframeAnimation+Parametric.m
//  CarnivalFold
//
//  Created by Cleave Pokotea on 20/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "CAKeyframeAnimation+Parametric.h"

@implementation CAKeyframeAnimation (Parametric)

+ (id) animationWithKeyPath:(NSString *)path
   function:(KeyframeParametricBlock)block
   fromValue:(double)fromValue
   toValue:(double)toValue
{
    // get a keyframe animation to set up
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:path];
    // break the time into steps (the more steps, the smoother the animation)
    NSUInteger steps = 100;
    NSMutableArray * values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0;
    double timeStep = 1.0 / (double) (steps - 1);

    for (NSUInteger i = 0; i < steps; i++)
    {
        double value = fromValue + (block(time) * (toValue - fromValue));
        [values addObject:[NSNumber numberWithDouble:value]];
        time += timeStep;

        NSLog(@"%@", [NSNumber numberWithDouble:value]);
    }

    // we want linear animation between keyframes, with equal time steps
    animation.calculationMode = kCAAnimationLinear;
    // set keyframes and we're done
    [animation setValues:values];
    return (animation);
}

@end