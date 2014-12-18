//
//  SignUpViewController.h
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userAlertView.h"
#import "XYZToDoListTableViewController.h"
#import "UICKeyChainStore.h"

@interface SignUpViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>

{
    NSString *errormessage;
}

@property (weak, nonatomic) IBOutlet UITextField *nameText;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UITextField *emailText;


@property (weak, nonatomic) IBOutlet UITextField *passwordText;

- (IBAction)backToSignIn:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;


- (IBAction)backgroundTap:(id)sender;


- (IBAction)signUp:(id)sender;









@end
