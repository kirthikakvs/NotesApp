//
//  NotesViewController.m
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "NotesViewController.h"
#import "toDoItem.h"
#import "toDoItemViewController.h"
#import "SimpleTableCell.h"
#import "NotesConstants.h"
#import "NetworkCalls.h"
#import "Reachability.h"

@interface NotesViewController ()
{
    NSString *user_id;
    NSString *access_token;
    NSDictionary *json;
    NSHTTPURLResponse *httpResponse;
    NSDictionary *resp;
}

@property NSMutableArray *toDoItems;

- (BOOL)canBecomeFirstResponder ;

@end

@implementation NotesViewController

//View controller life cycle


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self showSupport];
    } 
}

- (void) showSupport
{
    
    [[Mobihelp sharedInstance] presentSupport:self];
}

-(IBAction)showAlert
{
    [[Mobihelp sharedInstance] presentSupport:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLoad];
    [self getFromKeyChain];
    [self checkReachability];
}

-(void) initLoad
{
    [[Mobihelp sharedInstance] leaveBreadcrumb:@"Viewing Notes"];
    NSLog(@"Loaded view");
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    self.toDoItems = [[NSMutableArray alloc]init];
    NSLog(@"Loaded Items");
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];

}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Inside viewdidappear");
    [super viewDidAppear:animated];
    NSLog(@"After animation");
    [self checkReachability];
    [[self navigationController] setNavigationBarHidden:NO];
    [self initSetup];
}

-(void) initSetup
{
    NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    [self.toDoItems sortUsingDescriptors:[NSArray arrayWithObject:d]];
    self.ac = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.ac.center=self.view.center;
    [self.view addSubview:self.ac];
    [self.ac startAnimating];
    NSString *str = [NSString stringWithFormat:GET_NOTES];
    NetworkCalls *call = [NetworkCalls sharedNetworkCall];
    [call sendRequestWithoutData:str REQ_TYPE:GET ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
        resp = response;
        [self processResponse];
    }];
}

-(void) getFromKeyChain
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
    user_id = [store stringForKey:ID];
    access_token = [store stringForKey:TOKEN];
    NSLog(@"USER_ID => %@, ACCESS_TOKEN => %@",user_id,access_token);
}

- (void) reloadData
{
    self.toDoItems = nil;
    self.toDoItems = [[NSMutableArray alloc]init];
    [self getFromKeyChain];
    NSString *str = [NSString stringWithFormat:GET_NOTES];
    NetworkCalls *call=[NetworkCalls sharedNetworkCall];
    self.ac = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.ac.center=self.view.center;
    [self.view addSubview:self.ac];
    [self.ac startAnimating];
    [call sendRequestWithoutData:str REQ_TYPE:GET ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
        resp = response;
        [self processResponse];
    }];
    
}

-(void) processResponse
{
    dispatch_async(dispatch_get_main_queue(), ^{
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ([httpResponse statusCode] == 401){
        [self handleError];
    }else{
        [self parseData];
    }
        });
}

-(void) parseData
{
    if ([json isKindOfClass:[NSDictionary class]]){
        [self setData];
    }
    
}




-(void) handleError
{
    dispatch_sync(dispatch_get_main_queue(),^{
        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Not Authorized." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView showWithCompletion:NULL];
    });
}

-(void)setData
{
    NSMutableArray *notesArray = json[@"notes"];
    if ([notesArray isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dict in notesArray)
        {
            NSLog(@"Processing %@", dict);
            toDoItem *item = [[toDoItem alloc]init];
            item.content = [dict valueForKey:CONTENT];
            item.status = [dict valueForKey:STATUS];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:DATE_FORMAT];
            item.created = [formatter dateFromString:dict[CREATED]];
            item.updated = [formatter dateFromString:dict[UPDATED]];
            NSLog(@"%@",[[dict valueForKey:@"id"] class]);
            item.note_id = [dict valueForKey:@"id"];
            [self.toDoItems addObject:item];
        }
            [self.ac stopAnimating];
        [self.ac removeFromSuperview];
            [self refreshData];
        
    }
}



-(void) refreshData
{
    NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    [self.toDoItems sortUsingDescriptors:[NSArray arrayWithObject:d]];
    [self.tableView reloadData];
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:REFRESH_FORMAT];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl endRefreshing];
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([self.toDoItems count] != 0)
    {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return [self.toDoItems count];
    }
    else
    {
        [self handleNoItem];
        return 0;
    }
}

-(void) handleNoItem
{
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.text = @"There are currently no Notes to display. Please click on \"+\" to Add a Note.";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void) removeUserInfo
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
    [store removeItemForKey:@"USER_ID"];
    [store removeItemForKey:@"ACCESS_TOKEN"];
    [[Mobihelp sharedInstance] clearUserData];
}

-(void) processLogOut
{
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ([httpResponse statusCode] == 200){
        dispatch_sync(dispatch_get_main_queue(),^{
            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Successfully logged out." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView showWithCompletion:NULL];
            [self performSegueWithIdentifier:@"logout_path" sender:self];
        });
    }
}

- (IBAction)logout:(id)sender {
    NSLog(@"inside logout");
    [self getFromKeyChain];
    [self removeUserInfo];
    NSString *str = [NSString stringWithFormat:USER_SIGNOUT];
    NetworkCalls * call = [NetworkCalls sharedNetworkCall];
    [call sendRequestWithoutData:str REQ_TYPE:DELETE ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
        resp = response;
        [self processLogOut];
    }];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
    toDoItemViewController *source = [segue sourceViewController];
    toDoItem *item= source.toDotem;
    [self.toDoItems removeAllObjects];
    [self.tableView reloadData];
    //if(item!=nil){
    //    if([source.taps isEqualToNumber:[NSNumber numberWithInt:2]]){
    //            [self.toDoItems replaceObjectAtIndex:tappedRow withObject:item];
    //            [self.tableView reloadData];
    //    }
    //    else{
    //            [self.toDoItems addObject:item];
    //            [self.tableView reloadData];
    //    }
    //}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSLog(@"inside cellforrowatindexpath");
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (!cell){
        //All cell initializations should happen here.
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.delegate = self;
    }
    toDoItem *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
   [cell.noteLabel setText:toDoItem.content];
    if([toDoItem.status isEqualToString:@"completed"]) {
        cell.completedLabel.text = [@"Completed  " stringByAppendingString:[toDoItem.updated formattedAsTimeAgo]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if([toDoItem.status isEqualToString:@"Pending"]){
        cell.completedLabel.text = [@"Created  " stringByAppendingString:[toDoItem.created formattedAsTimeAgo]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (void)tapTimerFired:(NSTimer *)aTimer
{
    if (tapTimer != nil)
    {
        self.tapCount = 0;
        tappedRow = -1;
    }
}

-(void) processUpdate
{
    dispatch_sync(dispatch_get_main_queue(), ^{
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ([httpResponse statusCode] == 401){
        dispatch_sync(dispatch_get_main_queue(),^{
            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Update." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView showWithCompletion:NULL];
        });
    }
    [self.tableView reloadRowsAtIndexPaths:@[self.path] withRowAnimation:UITableViewRowAnimationFade];
    });
}


-(void) handleSingleTap{
    if([self.isConnected isEqualToNumber:[NSNumber numberWithBool:NO]])
        {
            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Please check your internet connectivity.You cannot edit/update your notes when you are offline." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView showWithCompletion:NULL];
            
        }
        else
        {
            NSLog(@"Im currently toggling the completed state !!!");
            NSLog(@"Selected row %@",[NSString stringWithFormat:@"%d",tappedRow]);
            [self getFromKeyChain];
            [self.tableView deselectRowAtIndexPath:self.path animated:YES];
            toDoItem *toDoItem=[self.toDoItems objectAtIndex:self.path.row];
            NSLog(@"inside didselectrowatindexpath");
            NSLog(@"before : %@", toDoItem.status);
            [self.tableView deselectRowAtIndexPath:self.path animated:YES];
            NSLog(@"before : %@", toDoItem.status);
            if ([toDoItem.status isEqualToString:@"Pending"])
            {
                toDoItem.status = @"completed";
                toDoItem.updated = [NSDate date];
                NSLog(@"after :%@",toDoItem.status);
            }
            else
            {
                toDoItem.status = @"Pending";
            }
            NSString *stringData = [NSString stringWithFormat:UPDATE_FORMAT,toDoItem.content,toDoItem.status];
            NSString *str = [NSString stringWithFormat:UPDATE_NOTE,[toDoItem.note_id description]];
            NetworkCalls *call = [NetworkCalls sharedNetworkCall];
            [call sendRequest:str REQ_TYPE:PUT DATA:stringData ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
                resp = response;
                [self processUpdate];
            }];
        }
}

-(void)handleDoubleTap{
    if([self.isConnected isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Please check your internet connectivity.You cannot edit/update your notes when you are offline." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView showWithCompletion:NULL];
        
    }
    else{
        NSLog(@"Double tapping Now !!!");
        self.tapCount=[NSNumber numberWithInt:2];
        NSLog(@"%@",[NSString stringWithFormat:@"%d",tappedRow]);
        self.editItem = [self.toDoItems objectAtIndex:self.path.row];
        [self performSegueWithIdentifier:@"edit_path" sender:self];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self.tapCount isEqualToNumber:[NSNumber numberWithInt:2]])
    {
    UINavigationController *nav = [segue destinationViewController];
    toDoItemViewController *dest = (toDoItemViewController*)nav.topViewController;
    NSLog(@"%@",[sender description]);
    dest.send = sender;
    dest.toDotem = self.editItem;
    dest.taps = self.tapCount;
    NSLog(@"Item content to be edited => %@",dest.toDotem.content);
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tappedRow = indexPath.row;
    self.path = indexPath;
    return nil;
}

-(void) processDelete
{
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ([httpResponse statusCode] == 401){
        dispatch_sync(dispatch_get_main_queue(),^{
            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Update." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView showWithCompletion:NULL];
            [self.tableView reloadData];
        });
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(),^{
            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Successfully deleted note." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView showWithCompletion:NULL];
            [self.toDoItems removeObjectAtIndex:self.path.row];
            [self.tableView reloadData];
        });
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.isConnected isEqualToNumber:[NSNumber numberWithBool:NO]]){
        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Please check your internet connectivity.You cannot edit/update your notes when you are offline." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView showWithCompletion:NULL];
    }
    else{
    self.path=indexPath;
    NSLog(@"inside editingStyleforRowAtIndexPath");
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self getFromKeyChain];
    toDoItem *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
    NSString *str = [NSString stringWithFormat:DEL_NOTE,toDoItem.note_id];
    NetworkCalls * call = [NetworkCalls sharedNetworkCall];
    [call sendRequestWithoutData:str REQ_TYPE:DELETE ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
        resp = response;
        [self processDelete];
    }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

-(void) checkReachability
{
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    reach.reachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isConnected = [NSNumber numberWithBool:YES];
            NSLog(@"REACHABLE!");
        });
    };
    reach.unreachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isConnected=[NSNumber numberWithBool:NO];
            NSLog(@"NOT REACHABLE!");
        });
    };
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.isConnected,@"reachabilityStatus", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
}

-(void) reachabilityChanged:(NSNotification*)notice
{
    Reachability *reachability = (Reachability *)[notice object];
    if ([reachability isReachable]) {
        NSLog(@"Reachable");
        [self.navigationItem.leftBarButtonItem setEnabled:TRUE];
        [self.navigationItem.rightBarButtonItem setEnabled:TRUE];
    } else {
        NSLog(@"Unreachable");
        [self.navigationItem.leftBarButtonItem setEnabled:FALSE];
        [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
    }
}



@end
