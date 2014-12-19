//
//  AppDelegate.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkCalls.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UIStoryboard *storyboard;

- (void) signIn;
- (void) alreadySignedIn;
- (void) mobihelpConfig;

@end

