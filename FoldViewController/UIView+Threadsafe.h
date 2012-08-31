//
//  UIView+Threadsafe.h
//  FoldViewController
//
//  Created by Cleave Pokotea on 25/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(UIImage *image);

@interface UIView (Threadsafe)
+ (UIImage *) imageFromView:(UIView *)view 
                   withClip:(CGFloat)clip 
       andTransparentInsets:(UIEdgeInsets)insets
                 onComplete:(CompletionBlock)onComplete;
@end
