//
//  SignInViewController.h
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <security/security.h>


@interface SignInViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *SignIn;


@property (weak, nonatomic) IBOutlet UITextField *userNameText;

@property (nonatomic,strong) NSNumber * isConnected;

@property (nonatomic,strong) UIActivityIndicatorView *ac;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)backgroundTap:(id)sender;
- (void) initSetup;
- (IBAction)signInAction:(id)sender;



@end
