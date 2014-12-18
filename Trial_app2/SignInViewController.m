//
//  SignInViewController.m
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "SignInViewController.h"
#import "userAlertView.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize userNameText=_userNameText;
@synthesize passwordText=_passwordText;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"0210.jpg"];
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
    [self.view addSubview:backgroundView];
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
    }

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)signInAction:(id)sender {
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ac.center = self.view.center;
    [self.view addSubview:ac];
    [ac startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"signin started");
        NSString *email = self.userNameText.text;
        NSString *pass = self.passwordText.text;
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/signin.json?email=%@&password=%@",email,pass];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"GET"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                if ([httpResponse statusCode] == 200){
                    dispatch_sync(dispatch_get_main_queue(),^{
                        NSString *accessToken=[json valueForKey:@"access_token"];
                        NSString *userID=[[json valueForKey:@"user_id"] description];
                        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
                        store[@"ACCESS_TOKEN"] = accessToken;
                        store[@"USER_ID"] = userID;
                        [store synchronize];
                        NSLog(@"from keychain : %@",[store stringForKey:@"ACCESS_TOKEN"]);
                        [ac stopAnimating];
                        [self performSegueWithIdentifier:@"success_path" sender:self];
                    });
                }else{
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Username or password." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                    });
                }
            }
        }];
        
        [dataTask resume];
    });
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
