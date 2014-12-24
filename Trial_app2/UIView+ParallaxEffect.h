//
//  UIView+ParallaxEffect.h
//  Trial_app2
//
//  Created by kirthikas on 22/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ParallaxEffect)

@property (nonatomic,strong) UIActivityIndicatorView *ac;

-(void) setParallaxEffect:(UIImage*)image;
-(void) startActivityIndicator;
-(void) stopActivityIndicator;
-(void) initActivityIndicator;
@end
