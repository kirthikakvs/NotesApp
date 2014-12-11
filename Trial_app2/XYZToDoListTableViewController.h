//
//  XYZToDoListTableViewController.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userAlertView.h"
#import "UICKeyChainStore.h"

@interface XYZToDoListTableViewController : UITableViewController
{
}
@property int tapCount;

@property NSTimer *tapTimer;

@property int tappedRow;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
- (void)tapTimerFired:(NSTimer *)aTimer;
+ (void) noteEdit;

//retain vs strong



@end
