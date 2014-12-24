//
//  UIView+ParallaxEffect.m
//  Trial_app2
//
//  Created by kirthikas on 22/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "UIView+ParallaxEffect.h"



@implementation UIView (ParallaxEffect)

@dynamic ac;



-(void) setParallaxEffect:(UIImage*)image
{
    if(!image)
    {
        image = [UIImage imageNamed:@"0210.jpg"];
    }
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
    CGRect scaledImageRect = CGRectMake( backgroundView.frame.origin.x - 15.0 ,backgroundView.frame.origin.y - 15.0, backgroundView.image.size.width + 10.0 , backgroundView.image.size.width + 10.0);
    backgroundView.frame = scaledImageRect;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    [self addSubview:backgroundView];
    UIInterpolatingMotionEffect *verticalMotionEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-30);
    verticalMotionEffect.maximumRelativeValue = @(30);
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-30);
    horizontalMotionEffect.maximumRelativeValue =@(30);
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[horizontalMotionEffect,verticalMotionEffect];
    [backgroundView addMotionEffect:effectGroup];
}

-(void) startActivityIndicator
{
    self.ac.center = self.center;
    [self addSubview:self.ac];
    [self.ac startAnimating];
}

-(void) stopActivityIndicator
{
    [self.ac stopAnimating];
    [self.ac removeFromSuperview];
}

-(void) initActivityIndicator
{
    self.ac = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

@end
