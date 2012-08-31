//
//  UIView+Threadsafe.m
//  FoldViewController
//
//  Created by Cleave Pokotea on 25/07/12.
//  Copyright (c) 2012 Tumunu. All rights reserved.
//

#import "UIView+Threadsafe.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIView (Threadsafe)

CG_INLINE CGContextRef CGContextCreate(CGSize size)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(nil, size.width, size.height, 8, size.width * (CGColorSpaceGetNumberOfComponents(space) + 1), space, kCGImageAlphaPremultipliedLast);

    CGColorSpaceRelease(space);

    return ctx;
}

CG_INLINE UIImage * UIGraphicsGetImageFromContext(CGContextRef ctx)
{
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage * image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];

    CGImageRelease(cgImage);

    return image;
}

+ (UIImage *) imageFromView:(UIView *)view 
                   withClip:(CGFloat)clip 
       andTransparentInsets:(UIEdgeInsets)insets 
                 onComplete:(CompletionBlock)onComplete
{
    CGRect frame = view.frame;
    frame.size.width = view.frame.size.width - clip;

    CGSize imageSizeWithBorder = CGSizeMake (frame.size.width + insets.left + insets.right, frame.size.height + insets.top + insets.bottom);

    CGContextRef ctx = CGContextCreate (imageSizeWithBorder);
    CGContextClipToRect (ctx, (CGRect) { { insets.left, insets.top }, frame.size });
    CGAffineTransform flipVertical = CGAffineTransformMake (
           1, 0, 0, -1, 0, view.frame.size.height
           );
    CGContextConcatCTM (ctx, flipVertical);

    [view.layer renderInContext:ctx];
    UIImage * img = UIGraphicsGetImageFromContext (ctx);
    CGContextRelease (ctx);

    dispatch_async (dispatch_get_main_queue (), ^{
                       onComplete (img);
                   });
    
    return nil;
}

@end
