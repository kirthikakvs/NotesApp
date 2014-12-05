//
//  UserAlertWrapper.h
//  Trial_app2
//
//  Created by kirthikas on 04/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "userAlertView.h"
#import <objc/runtime.h>

@interface UserAlertWrapper : NSObject

@property (copy) void(^completionBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@end
