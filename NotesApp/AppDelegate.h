//
//  AppDelegate.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkCalls.h"
#import "Reachability.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UIStoryboard *storyboard;
@property (nonatomic) Reachability *reachability;
@property (nonatomic) BOOL monitoringReachability;
@property (nonatomic, strong) UIImageView *splashView;

-(void) checkReachability;
- (void) getFromKeychain;
- (void) signIn;
- (void) alreadySignedIn;
- (void) mobihelpConfig;
- (void) parseData;
- (void) processResponse;

@end

