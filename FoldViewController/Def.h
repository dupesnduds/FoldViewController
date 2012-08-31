//
//  Def.h
//  TFoldViewController
//
//  Created by Cleave Pokotea on 19/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#define kDefaultFPS 60.0                // 60 frames per second

enum
{
    TFoldViewRightToLeft = 0,
    TFoldViewLeftToRight = 1 << 0
};
typedef NSUInteger CLFoldDirection;

enum
{
    TUnknown = 0,
    CLOpen = 1 << 0,
    TClosed = 2 << 0,
    CLMenu = 3 << 0
};
typedef NSUInteger CLState;

typedef enum
{
    CLFullViewWidth,
    TFixedViewRevealWidth,
    TVariableViewRevealWidth
} TWidthLayout;

struct TFoldStruct
{
    //
    CGSize InitialSize;
    CGSize CurrentSize;
    CGSize LastSize;
    CGPoint LastPosition;
    CGPoint CurrentPosition;
    CGPoint InitialTopPosition;
    CGPoint OpenTopPosition;

    //
    CGFloat startX;

    // animation
    int NumberOfSteps;
    int IndexStep;
    CGFloat IncrementAmount;

    // strategy
    CLState state;
    CLFoldDirection FoldDirection;
};
typedef struct TFoldStruct TFoldStruct;
