//
//  SignInViewController.m
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "SignInViewController.h"
#import "userAlertView.h"
#import "NetworkCalls.h"
#import "NotesConstants.h"
#import "UIView+ParallaxEffect.h"
#import "Reachability.h"

@interface SignInViewController ()
{
    NSString *user_id;
    NSString *access_token;
    NSDictionary *json;
    NSHTTPURLResponse *httpResponse;
    NSDictionary *resp;
}
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkReachability];
    [[Mobihelp sharedInstance] leaveBreadcrumb:@"Sign in"];
    [self.view setParallaxEffect:[UIImage imageNamed:@"0210.jpg"]];
    [self initSetup];
    }



- (void) initSetup
{
    self.ac = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.ac.center=self.view.center;
    self.passwordText.secureTextEntry = YES;
}



- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)signInAction:(id)sender {
    __block NSString *email = self.userNameText.text;
    __block NSString *pass = self.passwordText.text;
    if ([email isEqualToString:@""] || [pass isEqualToString:@""]) {
        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Do not leave the Email/Password fields blank." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        
        [alertView showWithCompletion:NULL];
    }
    else{
        [self.view addSubview:self.ac];
        [self.ac startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"signin started");
        email = self.userNameText.text;
        pass = self.passwordText.text;
        NSString *str = [NSString stringWithFormat:USER_SIGNIN,email,pass];
        NetworkCalls *call = [NetworkCalls sharedNetworkCall];
        [call sendRequestWithoutAccessToken:str REQ_TYPE:GET completion:^(NSDictionary *response, NSError *error) {
            resp = response;
            [self processResponse];
        }];
    });
    [self.ac stopAnimating];
    }
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
        [self handleError];
    }
    
}

- (void) handleError
{
    userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Username or password." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    
    [alertView showWithCompletion:NULL];
}

- (void) parseData
{
    dispatch_sync(dispatch_get_main_queue(), ^{
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
    [self.ac stopAnimating];
    [self performSegueWithIdentifier:@"success_path" sender:self];
    });
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) checkReachability
{
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    reach.reachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isConnected = [NSNumber numberWithBool:YES];
            NSLog(@"REACHABLE!");
        });
    };
    reach.unreachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isConnected=[NSNumber numberWithBool:NO];
            NSLog(@"NOT REACHABLE!");
        });
    };
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.isConnected,@"reachabilityStatus", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
}

-(void) reachabilityChanged:(NSNotification*)notice
{
    Reachability *reachability = (Reachability *)[notice object];
    if ([reachability isReachable]) {
        NSLog(@"Reachable");
        self.SignIn.enabled=TRUE;
    } else {
        NSLog(@"Unreachable");
        self.SignIn.enabled = FALSE;
    }
}

@end
