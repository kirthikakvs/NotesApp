//
//  AppDelegate.m
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "NotesViewController.h"
#import "UICKeyChainStore.h"
#import "SignInViewController.h"
#import "Mobihelp.h"
#import "NotesConstants.h"
#import "NetworkCalls.h"
#import "userAlertView.h"


@interface AppDelegate ()
{
    BOOL isConnected;
NSString *user_id;
NSString *access_token;
NSDictionary *json;
NSHTTPURLResponse *httpResponse;
NSDictionary *resp;
}
@end

@implementation AppDelegate

@synthesize splashView;

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{   // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [NSThread sleepForTimeInterval:5.0];
    [self mobihelpConfig];
    [self getFromKeychain];
    if (user_id && access_token)
    {
        [self alreadySignedIn];
    }
    else
    {
        [self signIn];
    }
    return YES;
}

- (void) getFromKeychain
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
    user_id = [store stringForKey:@"USER_ID"];
    access_token = [store stringForKey:@"ACCESS_TOKEN"];
}

-(void) mobihelpConfig{
    MobihelpConfig *config = [[MobihelpConfig alloc]initWithDomain:@"rexinc.freshdesk.com" withAppKey:@"notesapp-2-2cc34b4abbc4644a11e678e95570c719" andAppSecret:@"7cbe1bf637c70519f9f96a29d0985be8a7285566"];
    config.launchCountForAppReviewPrompt = 10;
    config.feedbackType = FEEDBACK_TYPE_NAME_REQUIRED_AND_EMAIL_OPTIONAL;
    [[Mobihelp sharedInstance]initWithConfig:config];
    [[Mobihelp sharedInstance] leaveBreadcrumb:@"Notes App started"];
}

- (void) alreadySignedIn{
    dispatch_async(dispatch_get_main_queue(),^{
    NSLog(@"Verifying Credentials");
    NSString *str = [NSString stringWithFormat:GET_USER,user_id];
    NetworkCalls *call = [NetworkCalls sharedNetworkCall];
    [call sendRequestWithoutData:str REQ_TYPE:GET ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
        if(!error)
        {
            resp = response;
            [self processResponse];
        }
        else
        {
            UIViewController *signin = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInNavigation"];
            self.window.rootViewController = signin;
            [self.window makeKeyAndVisible];
        }
    }];
    });
}

- (void) processResponse
{   
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ([httpResponse statusCode] == 200)
    {
        [self parseData];
    }
    else
    {
        UIViewController *signin = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInNavigation"];
        self.window.rootViewController = signin;
        [self.window makeKeyAndVisible];
        
    }
}

- (void) parseData
{
    dispatch_sync(dispatch_get_main_queue(),^{
        [[Mobihelp sharedInstance] leaveBreadcrumb:@"Already signed in."];
        NSString *accessToken=[json valueForKey:@"access_token"];
        NSString *userID=[[json valueForKey:@"user_id"] description];
        NSString *userName = [json valueForKey:@"user_name"];
        NSString *userEmail = [json valueForKey:@"user_email"];
        [[Mobihelp sharedInstance] setUserName:userName];
        [[Mobihelp sharedInstance] setEmailAddress:userEmail];
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        store[@"ACCESS_TOKEN"] = accessToken;
        store[@"USER_ID"] = userID;
        [store synchronize];
        NSLog(@"from keychain : %@",[store stringForKey:@"ACCESS_TOKEN"]);
        UIViewController *notesController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotesNavigationController"];
        self.window.rootViewController = notesController;
        [self.window makeKeyAndVisible];
    });
}

-(void) signIn{
    UIViewController *signin = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInNavigation"];
    self.window.rootViewController = signin;
    [self.window makeKeyAndVisible];
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Inside clicked at button");
}




@end
