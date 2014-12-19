//
//  AppDelegate.m
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "XYZToDoListTableViewController.h"
#import "UICKeyChainStore.h"
#import "SignInViewController.h"
#import "Mobihelp.h"
#import "NotesConstants.h"
#import "NetworkCalls.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self mobihelpConfig];
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
    NSString *user_id = [store stringForKey:@"USER_ID"];
    NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
    if (user_id && access_token){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSLog(@"Verifying Credentials");
            NSString *str = [NSString stringWithFormat:GET_USER,user_id];
            NSHTTPURLResponse *response = [NetworkCalls sendRequestWithoutData:str REQ_TYPE:@"GET" ACCESS_TOKEN:access_token];
            NSURL *u = [NSURL URLWithString:str ];
            NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
            [req setHTTPMethod:@"GET"];
            [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSLog(@"%@", json);
                if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                    if ([httpResponse statusCode] == 200){
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
                }
            }];
            [dataTask resume];
        });
    }
    else
    {
        [self signIn];
    }
    return YES;
}

-(void) mobihelpConfig{
    MobihelpConfig *config = [[MobihelpConfig alloc]initWithDomain:@"rexinc.freshdesk.com" withAppKey:@"notesapp-2-2cc34b4abbc4644a11e678e95570c719" andAppSecret:@"7cbe1bf637c70519f9f96a29d0985be8a7285566"];
    config.launchCountForAppReviewPrompt = 10;
    config.feedbackType = FEEDBACK_TYPE_NAME_REQUIRED_AND_EMAIL_OPTIONAL;
    [[Mobihelp sharedInstance]initWithConfig:config];
    [[Mobihelp sharedInstance] leaveBreadcrumb:@"Notes App started"];
}

-(void) signIn{
    UIViewController *signin = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInNavigation"];
    self.window.rootViewController = signin;
    [self.window makeKeyAndVisible];
}

-(void) alreadySignedIn{
    
}

@end
