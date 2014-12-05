//
//  userAlertView.h
//  Trial_app2
//
//  Created by kirthikas on 04/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userAlertView : UIAlertView

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
