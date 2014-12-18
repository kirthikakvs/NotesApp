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

@synthesize scrollView;
@synthesize nameText=_nameText;
@synthesize emailText=_emailText;
@synthesize passwordText=_passwordText;
@synthesize confirmPasswordText=_confirmPasswordText;


- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"0210.jpg"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
    CGRect scaledImageRect = CGRectMake( backgroundView.frame.origin.x - 15.0 ,backgroundView.frame.origin.y - 15.0, backgroundView.image.size.width + 10.0 , backgroundView.image.size.width + 10.0);
    backgroundView.frame = scaledImageRect;
    backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    [self.view addSubview:backgroundView];
    scrollView.contentSize = CGSizeMake(320,750);
    UIInterpolatingMotionEffect *verticalMotionEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-30);
    verticalMotionEffect.maximumRelativeValue = @(30);
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-30);
    horizontalMotionEffect.maximumRelativeValue =@(30);
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[horizontalMotionEffect,verticalMotionEffect];
    [backgroundView addMotionEffect:effectGroup];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/signup.json"];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"POST"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *stringData = [NSString stringWithFormat:@"{ \"user\":{ \"name\":\"%@\", \"email\":\"%@\", \"password\":\"%@\", \"password_confirmation\":\"%@\" }}",nam,email,pass,confirm];
        NSLog(@"HTTP BODY => %@",stringData);
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
                                      NSArray *errorMsg = [json valueForKey:@"error"];
                                      NSString *err_msg = [errorMsg componentsJoinedByString:@"= "];
                                      NSLog(@"ERROR_MESSAGE :%@", err_msg);
                                      NSLog(@"ERROR_MESSAGE => %@",errorMsg);
                                      userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:[NSString stringWithFormat:@"%@",err_msg] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
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
    });
}

- (IBAction)backToSignIn:(id)sender {
    [self performSegueWithIdentifier:@"signInPath" sender:self];
}
@end
