//
//  SignUpViewController.m
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "SignUpViewController.h"
#import "UIView+ParallaxEffect.h"
#import "NetworkCalls.h"
#import "NotesConstants.h"

@interface SignUpViewController ()
{
    NSDictionary *json;
    NSHTTPURLResponse *httpResponse;
    NSDictionary *resp;
}
@end

@implementation SignUpViewController

@synthesize scrollView;
@synthesize nameText=_nameText;
@synthesize emailText=_emailText;
@synthesize passwordText=_passwordText;
@synthesize confirmPasswordText=_confirmPasswordText;


- (void)viewDidLoad {
    [super viewDidLoad];
    NetworkCalls *call = [NetworkCalls sharedNetworkCall];
    [[Mobihelp sharedInstance] leaveBreadcrumb:@"Sign Up"];
    [self.view setParallaxEffect:[UIImage imageNamed:@"0210.jpg"]];
    [self initSetup];
    // Do any additional setup after loading the view.
}

-(void) initSetup
{
    self.passwordText.secureTextEntry = YES;
    self.confirmPasswordText.secureTextEntry = YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)signUp:(id)sender {
    NSString *nam = self.nameText.text;
    NSString *email = self.emailText.text;
    NSString *pass = self.passwordText.text;
    NSString *confirm = self.confirmPasswordText.text;
    NSString *str = [NSString stringWithFormat:CREATE_USER];
    NSString *stringData = [NSString stringWithFormat:@"{ \"user\":{ \"name\":\"%@\", \"email\":\"%@\", \"password\":\"%@\", \"password_confirmation\":\"%@\" }}",nam,email,pass,confirm];
    NetworkCalls *call = [NetworkCalls sharedNetworkCall];
    [call sendRequestWithData:str REQ_TYPE:POST DATA:stringData completion:^(NSDictionary *response, NSError *error) {
        resp = response;
        [self processResponse];
    }];
}

- (void) processResponse
{
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ( [httpResponse statusCode] == 400 )
    {
        [self handleError];
    }
    else
    {
        [self parseData];
    }
}

-(void) handleError
{
    dispatch_sync(dispatch_get_main_queue(),
                  ^{
                      NSArray *errorMsg = [json valueForKey:@"error"];
                      NSString *err_msg = [errorMsg componentsJoinedByString:@"= "];
                      NSLog(@"ERROR_MESSAGE :%@", err_msg);
                      NSLog(@"ERROR_MESSAGE => %@",errorMsg);
                      userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:[NSString stringWithFormat:@"%@",err_msg] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                      [alertView showWithCompletion:NULL];
                  });
}

-(void) parseData
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        NSString *accessToken=[json valueForKey:@"access_token"];
        NSString *userID=[[json valueForKey:@"user_id"] description];
        NSLog(@"%@,%@ ",accessToken,userID);
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        store[@"ACCESS_TOKEN"] = accessToken;
        store[@"USER_ID"] = userID;
        [store synchronize];
        NSLog(@"from keychain : %@",[store stringForKey:@"ACCESS_TOKEN"]);
    });
    dispatch_sync(dispatch_get_main_queue(),
                  ^{
                      userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"You have successfully signed up." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                      [alertView showWithCompletion:NULL];
                      [self performSegueWithIdentifier:@"sign_up_completion" sender:self];
                  });
}

- (IBAction)backToSignIn:(id)sender {
    [self performSegueWithIdentifier:@"signInPath" sender:self];
}
@end
