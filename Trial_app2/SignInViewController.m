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
    self.view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"color-theme-blue-green-white-keywords-decorative-backgrounds.jpg"]];
    self.passwordText.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)signInAction:(id)sender {
    NSLog(@"signin started");
    NSString *email = self.userNameText.text;
    NSString *pass = self.passwordText.text;
    //NSString *authStr = [NSString stringWithFormat:@"450461847a6c150257e0d583d68ffd9f"];
    //NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    NSString *str = [NSString stringWithFormat:@"http://0.0.0.0:3000/signin.json?email=%@&password=%@",email,pass];
    NSURL *u = [NSURL URLWithString:str ];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
    [req setHTTPMethod:@"GET"];
    //[req setValue:@"450461847a6c150257e0d583d68ffd9f" forHTTPHeaderField:@"X-Api-Key"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", json);
        for(id key in json) {
            
            id value = [json objectForKey:key];
            
            NSString *keyAsString = (NSString *)key;
            NSString *valueAsString = (NSString *)value;
            
            NSLog(@"key: %@", keyAsString);
            NSLog(@"value: %@", valueAsString);
            NSNumberFormatter *n = [[NSNumberFormatter alloc] init];
            [ n setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *num = [n numberFromString:valueAsString];
            if ([keyAsString isEqualToString:@"status"])
            {
                if ( [num isEqualToNumber:[NSNumber numberWithLong:200]])
                {
                    dispatch_sync(dispatch_get_main_queue(),
                              ^{
                                  userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"You have successfully signed in" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                  [alertView showWithCompletion:NULL];
                                  XYZToDoListTableViewController *tab = [[XYZToDoListTableViewController alloc]init];
                                  [self.navigationController pushViewController:tab animated:YES];
                              });
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(),
                              ^{
                                  userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Username or password." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                                  [alertView showWithCompletion:NULL];
                              });
                }
            }
        }
    }];
    
    [dataTask resume];

}

- (void)sendMessage:(NSString *)status
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        if ([status isEqualToString:@"200"])
        {
            dispatch_sync(dispatch_get_main_queue(),
            ^{
                userAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notes App" message:@"You have successfully signed in" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alertView showWithCompletion:NULL];
        });
        } else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{userAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notes App" message:@"Unsuccessful sign in" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alertView showWithCompletion:NULL];});
        }
    });
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
