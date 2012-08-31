//
//  TTimer.h
//  FoldViewController
//
//  Created by Cleave Pokotea on 20/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Def.h"

typedef double (^ ParametricBlock)(double);
typedef void (^ ParametricTick)(double);
typedef void (^ ParametricCompletion)();
typedef void (^ LinearTick)(float);
typedef void (^ LinearCompletion)();

@interface TTimer : NSObject

- (id) initWithTicks:(NSUInteger) tickCount
   totalDuration:(NSTimeInterval) duration
   direction:(BOOL) open
   fromValue:(double) fromValue
   toValue:(double) toValue
   tickTask:(ParametricTick) doBlock
   completion:(ParametricCompletion) theCompletionBlock;

- (id) initWithDuration:(NSTimeInterval) duration
   tickTask:(LinearTick) doBlock
   completion:(LinearCompletion) theCompletionBlock;

+ (id) parametericWithTicks:(NSUInteger) tickCount
   totalDuration:(NSTimeInterval) duration
   direction:(BOOL) open
   fromValue:(double) fromValue
   toValue:(double) toValue
   tickTask:(ParametricTick) doBlock
   completion:(ParametricCompletion) completionBlock;

+ (id) linearWithDuration:(CGFloat) duration
   tickTask:(LinearTick) doBlock
   completion:(LinearCompletion) completionBlock;

- (id) parameteric:(BOOL) open fromValue:(double) fromValue toValue:(double) toValue;
- (void) run;

@end
