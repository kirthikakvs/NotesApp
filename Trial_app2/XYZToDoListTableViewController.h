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
#import "SimpleTableCell.h"
#import "XYZToDoList.h"
@interface XYZToDoListTableViewController : UITableViewController <SimpleTableCellDelegate>
{
    NSTimer *tapTimer;
    int tappedRow, doubleTapRow;

    UITapGestureRecognizer *tapGesture;
}

- (IBAction)logout:(id)sender;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
- (void)tapTimerFired:(NSTimer *)aTimer;
+ (void) noteEdit;

@property (nonatomic,strong) NSNumber * tapCount;
@property (nonatomic,strong) XYZToDoList *editItem;
@property (nonatomic, strong) NSString *var2;
@property (nonatomic,strong) NSIndexPath *path;
//retain vs strong



@end
