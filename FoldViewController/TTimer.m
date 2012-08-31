//
//  TTimer.m
//  FoldViewController
//
//  Created by Cleave Pokotea on 20/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//
// http://stackoverflow.com/questions/5161465/how-to-create-custom-easing-function-with-core-animation

#import "TTimer.h"


ParametricBlock openFunction = ^double (double time) {
    return sin (time * M_PI_2);
};
ParametricBlock closeFunction = ^double (double time) {
    return -cos (time * M_PI_2) + 1;
};

@interface TTimer ()
{
    CGFloat elapsed;
    CGFloat interval;
    CGFloat dt;
    BOOL _isAnimating;
    CADisplayLink * _displayLink;
    CFTimeInterval lastDisplayTime;
    NSTimeInterval animationInterval;
    BOOL nextDeltaTimeZero;
    struct timeval lastUpdate;
    BOOL _linear;
}

@property (nonatomic) NSUInteger numberOfTicks;
@property (nonatomic) NSUInteger tick;
@property (nonatomic) NSTimeInterval totalDuration;
@property (nonatomic, copy) ParametricTick parametricTickBlock;
@property (nonatomic, copy) ParametricCompletion parametricCompletionBlock;
@property (nonatomic, copy) LinearTick linearTickBlock;
@property (nonatomic, copy) LinearCompletion linearCompletionBlock;
@property (nonatomic, retain) NSArray * tickTimings;
@property (nonatomic, readwrite, assign) CGFloat interval;
@property (nonatomic, readwrite, assign) NSTimeInterval animationInterval;
@property (nonatomic, readonly) BOOL isAnimating;

- (void) update:(CGFloat)dt;

@end

@implementation TTimer


@synthesize numberOfTicks;
@synthesize tick;
@synthesize totalDuration;
@synthesize parametricTickBlock;
@synthesize parametricCompletionBlock;
@synthesize linearTickBlock;
@synthesize linearCompletionBlock;
@synthesize tickTimings;
@synthesize interval;
@synthesize animationInterval = _animationInterval;
@synthesize isAnimating = _isAnimating;

- (id) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (id) initWithDuration:(NSTimeInterval)duration
   tickTask:(LinearTick)doBlock
   completion:(LinearCompletion)theCompletionBlock
{
    self = [super init];
    if (self)
    {
        self.totalDuration = duration;
        self.linearTickBlock = doBlock;
        self.linearCompletionBlock = theCompletionBlock;
        interval = duration;
        _linear = YES;
    }
    return self;
}

- (id) initWithTicks:(NSUInteger)tickCount
   totalDuration:(NSTimeInterval)duration
   direction:(BOOL)open
   fromValue:(double)fromValue
   toValue:(double)toValue
   tickTask:(ParametricTick)doBlock
   completion:(ParametricCompletion)theCompletionBlock
{
    self = [super init];
    if (self)
    {
        self.numberOfTicks = tickCount / 6;
        self.totalDuration = duration;
        self.parametricTickBlock = doBlock;
        self.parametricCompletionBlock = theCompletionBlock;
        self.tickTimings = [self parameteric:open fromValue:fromValue toValue:toValue];

        elapsed = -1;
        interval = duration;
        animationInterval = interval / kDefaultFPS;
        _linear = NO;
    }
    return self;
}

+ (id) parametericWithTicks:(NSUInteger)tickCount
   totalDuration:(NSTimeInterval)duration
   direction:(BOOL)open
   fromValue:(double)fromValue
   toValue:(double)toValue
   tickTask:(ParametricTick)doBlock
   completion:(ParametricCompletion)completionBlock
{
    return [[self alloc] initWithTicks:(NSUInteger) tickCount
                         totalDuration:(NSTimeInterval) duration
                             direction:(BOOL) open
                             fromValue:(double) fromValue
                               toValue:(double) toValue
                              tickTask:(ParametricTick) doBlock
                            completion:(ParametricCompletion) completionBlock];
}

+ (id) linearWithDuration:(CGFloat)duration
   tickTask:(LinearTick)doBlock
   completion:(LinearCompletion)completionBlock
{
    return [[self alloc] initWithDuration:(NSTimeInterval) duration
                                 tickTask:(LinearTick) doBlock
                               completion:(LinearCompletion) completionBlock];
}

- (void) run
{
    self.tick = 0;
    [self startAnimation];
}

- (void) ticker
{
    BOOL animationCompleted = (self.tick == self.numberOfTicks - 1);

    if (animationCompleted)
    {
        self.parametricCompletionBlock();
        [self stopAnimation];
    }
    else
    {
        if (self.tick != self.numberOfTicks)
        {
            self.parametricTickBlock([[self.tickTimings objectAtIndex:self.tick] doubleValue]);
            self.tick++;
        }
    }
}

//
- (id) parameteric:(BOOL)open fromValue:(double)fromValue toValue:(double)toValue
{
    NSUInteger steps = self.numberOfTicks - 1;
    NSMutableArray * values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0;
    double timeStep = 1.0 / (double) (steps - 1);
    double value;

    for (NSUInteger i = 0; i < steps; i++)
    {
        if (open)
        {
            value = fromValue + (openFunction(time) * (toValue - fromValue));
        }
        else if (!open)
        {
            value = fromValue + (closeFunction(time) * (toValue - fromValue));
        }

        [values addObject:[NSNumber numberWithDouble:value]];
        time += timeStep;
    }

    return [NSArray arrayWithArray:values];
}

//
- (void) move:(CGFloat)delta
{
    self.linearTickBlock(delta * interval);
}

//
- (void) update:(CGFloat)delta
{
    if ( elapsed == -1)
    {
        elapsed = 0;
    }
    else
    {
        elapsed += delta;
        if (_linear)
        {
            [self move:delta];
        }
        else
        {
            [self ticker];
        }

        if ( elapsed >= interval )
        {
            elapsed = 0;
        }
    }
}

- (void) calculateDeltaTime
{
    if ( nextDeltaTimeZero || lastDisplayTime == 0 )
    {
        dt = 0;
        nextDeltaTimeZero = NO;
    }
    else
    {
        dt = _displayLink.timestamp - lastDisplayTime;
        dt = MAX(0, dt);
    }
    lastDisplayTime = _displayLink.timestamp;
}

- (void) mainLoop:(id)sender
{
    [self calculateDeltaTime];
    [self update:dt];
}

- (void) setAnimationInterval:(NSTimeInterval)i
{
    _animationInterval = i;
    if (_displayLink)
    {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void) startAnimation
{
    if (_isAnimating)
    {
        return;
    }

    int frameInterval = (int) floor(animationInterval * 60.0f);
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];
    [_displayLink setFrameInterval:frameInterval];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _isAnimating = YES;
}

- (void) stopAnimation
{
    if (!_isAnimating)
    {
        return;
    }

    [_displayLink invalidate];
    _displayLink = nil;
    _isAnimating = NO;
}

@end
