//
//  SignInViewController.h
//  Trial_app2
//
//  Created by kirthikas on 02/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <security/security.h>
#import "XYZToDoListTableViewController.h"
#import "Mobihelp.h"
#import "UICKeyChainStore.h"

@interface SignInViewController : UIViewController<UITextFieldDelegate>



@property (weak, nonatomic) IBOutlet UITextField *userNameText;



@property (weak, nonatomic) IBOutlet UITextField *passwordText;


- (IBAction)backgroundTap:(id)sender;


- (IBAction)signInAction:(id)sender;



@end
