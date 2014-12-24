//
//  NotesViewController.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userAlertView.h"
#import "UICKeyChainStore.h"
#import "SimpleTableCell.h"
#import "toDoItem.h"
#import "NSDate+NVTimeAgo.h"
#import "Mobihelp.h"

@interface NotesViewController : UITableViewController <SimpleTableCellDelegate>
{
    NSTimer *tapTimer;
    int tappedRow, doubleTapRow;

    UITapGestureRecognizer *tapGesture;
}

- (IBAction)logout:(id)sender;
- (void) reloadData;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
- (void)tapTimerFired:(NSTimer *)aTimer;
+ (void) noteEdit;
- (void) showSupport;

@property (nonatomic,strong) NSNumber * isConnected;
@property (nonatomic,strong) UIActivityIndicatorView *ac;
@property (nonatomic,strong) NSNumber * tapCount;
@property (nonatomic,strong) toDoItem *editItem;
@property (nonatomic, strong) NSString *var2;
@property (nonatomic,strong) NSIndexPath *path;
//retain vs strong



@end
