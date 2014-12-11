//
//  SignUpViewController.m
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize nameText=_nameText;
@synthesize emailText=_emailText;
@synthesize passwordText=_passwordText;
@synthesize confirmPasswordText=_confirmPasswordText;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"1916561.jpg"]];
    self.passwordText.secureTextEntry = YES;
    self.confirmPasswordText.secureTextEntry = YES;
    
    // Do any additional setup after loading the view.
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
    
    NSString *str = [NSString stringWithFormat:@"http://0.0.0.0:3000/signup.json"];
    NSURL *u = [NSURL URLWithString:str ];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *stringData = [NSString stringWithFormat:@"{ \"user\":{ \"name\":\"%@\", \"email\":\"%@\", \"password\":\"%@\", \"password_confirmation\":\"%@\" }}",nam,email,pass,confirm];
    [req setHTTPBody:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", json);
        if( [response isKindOfClass:[NSHTTPURLResponse class]]  ){
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
            
            if ( [httpResponse statusCode] == 400 )
                
            {
                
                dispatch_sync(dispatch_get_main_queue(),
                              
                              ^{
                                  
                                  userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Already registered." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                  
                                  [alertView showWithCompletion:NULL];
                                  
                              });
                
                
                
            }
            
            else
                
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
            
        }
        
        
    }];
    
    [dataTask resume];

    
}
@end
