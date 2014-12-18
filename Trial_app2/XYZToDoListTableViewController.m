//
//  XYZToDoListTableViewController.m
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "XYZToDoListTableViewController.h"
#import "XYZToDoList.h"
#import "XYZAddToDoItemViewController.h"
#import "Note.h"
#import "SimpleTableCell.h"


@interface XYZToDoListTableViewController ()

@property NSMutableArray *toDoItems;

- (BOOL)canBecomeFirstResponder ;

@end

@implementation XYZToDoListTableViewController

//View controller life cycle

- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context= nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

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
    //userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Hello World" message:@"This is my first app!" delegate:nil cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
    
    //[alertView show];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Inside viewdidappear");
    [super viewDidAppear:animated];
    NSLog(@"After animation");
    [[self navigationController] setNavigationBarHidden:NO];
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ac.center = self.view.center;
    [self.view addSubview:ac];
    [ac startAnimating];
    NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    [self.toDoItems sortUsingDescriptors:[NSArray arrayWithObject:d]];
    [self.tableView reloadData];
    [ac stopAnimating];
}

- (void) reloadData
{
    self.toDoItems = [[NSMutableArray alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSLog(@"USER_ID => %@, ACCESS_TOKEN => %@",user_id,access_token);
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes.json"];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"GET"];
        [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                
                if ([httpResponse statusCode] == 401){
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Not Authorized." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                    });
                }else{
                    if ([json isKindOfClass:[NSDictionary class]])
                    {
                        NSMutableArray *notesArray = json[@"notes"];
                        if ([notesArray isKindOfClass:[NSArray class]])
                        {
                            for (NSDictionary *dict in notesArray)
                            {
                                NSLog(@"Processing %@", dict);
                                
                                XYZToDoList *item = [[XYZToDoList alloc]init];
                                item.content = [dict valueForKey:@"content"];
                                item.status = [dict valueForKey:@"status"];
                                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
                                item.created = [formatter dateFromString:dict[@"created_at"]];
                                item.updated = [formatter dateFromString:dict[@"updated_at"]];
                                NSLog(@"%@",[[dict valueForKey:@"id"] class]);
                                item.note_id = [dict valueForKey:@"id"];
                                [self.toDoItems addObject:item];
                            }
                        }
                    }
                    dispatch_sync(dispatch_get_main_queue(),^{
                        NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
                        [self.toDoItems sortUsingDescriptors:[NSArray arrayWithObject:d]];
                        [self.tableView reloadData];
                        if (self.refreshControl) {
                            
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"MMM d, h:mm a"];
                            NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                                        forKey:NSForegroundColorAttributeName];
                            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                            self.refreshControl.attributedTitle = attributedTitle;
                            
                            [self.refreshControl endRefreshing];
                        }
                    });
                }
            }
        }];
        [dataTask resume];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Loaded view");
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    self.toDoItems = [[NSMutableArray alloc]init];
        NSLog(@"Loaded Items");
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ac.center = self.view.center;
    [self.view addSubview:ac];
    [ac startAnimating];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSLog(@"USER_ID => %@, ACCESS_TOKEN => %@",user_id,access_token);
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes.json"];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"GET"];
        [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                
                if ([httpResponse statusCode] == 401){
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Not Authorized." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                    });
                }else{
                    if ([json isKindOfClass:[NSDictionary class]])
                    {
                        NSMutableArray *notesArray = json[@"notes"];
                        if ([notesArray isKindOfClass:[NSArray class]])
                        {
                            for (NSDictionary *dict in notesArray)
                            {
                                NSLog(@"Processing %@", dict);
                                XYZToDoList *item = [[XYZToDoList alloc]init];
                                item.content = [dict valueForKey:@"content"];
                                item.status = [dict valueForKey:@"status"];
                                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
                                item.created = [formatter dateFromString:dict[@"created_at"]];
                                item.updated = [formatter dateFromString:dict[@"updated_at"]];
                                NSLog(@"%@",[[dict valueForKey:@"id"] class]);
                                item.note_id = [dict valueForKey:@"id"];
                                [self.toDoItems addObject:item];
                            }
                        }
                    }
                    dispatch_sync(dispatch_get_main_queue(),^{
                        NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
                        [self.toDoItems sortUsingDescriptors:[NSArray arrayWithObject:d]];
                        [self.tableView reloadData];
                        [ac stopAnimating];
                    });
                }
            }
        }];
        [dataTask resume];
    });
        NSLog(@"Initialized items");
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
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"There are currently no Notes to display. Please click on \"+\" to Add a Note.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}


- (IBAction)logout:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"inside logout");
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSLog(@"USER_ID => %@, ACCESS_TOKEN => %@",user_id,access_token);
        [store removeItemForKey:@"USER_ID"];
        [store removeItemForKey:@"ACCESS_TOKEN"];
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes/signout.json"];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"DELETE"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                if ([httpResponse statusCode] == 200){
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Successfully logged out." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                    });
                }
            }
        }];
        [dataTask resume];
    });
    [self performSegueWithIdentifier:@"logout_path" sender:self];
    
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
   XYZAddToDoItemViewController *source = [segue sourceViewController];
    XYZToDoList *item= source.toDotem;
    if([source.taps isEqualToNumber:[NSNumber numberWithInt:2]])
    {
        if(item!=nil)
        {
            [self.toDoItems replaceObjectAtIndex:tappedRow withObject:item];
            [self.tableView reloadData];
        }
    }
    else
    {
        if(item!=nil)
        {
            [self.toDoItems addObject:item];
            [self.tableView reloadData];
        }
    }
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
    XYZToDoList *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
   [cell.noteLabel setText:toDoItem.content];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    if([toDoItem.status isEqualToString:@"completed"]) {
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy'-'MM'-'dd''HH':'mm'"];
        cell.completedLabel.text = [@"Completed  " stringByAppendingString:[toDoItem.updated formattedAsTimeAgo]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if([toDoItem.status isEqualToString:@"Pending"]){
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy'-'MM'-'dd''HH':'mm'"];
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

-(void) handleSingleTap{
    NSLog(@"Im currently toggling the completed state !!!");
      NSLog(@"Selected row %@",[NSString stringWithFormat:@"%d",tappedRow]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSLog(@"inside didselectrowatindexpath");
        [self.tableView deselectRowAtIndexPath:self.path animated:YES];
        XYZToDoList *toDoItem=[self.toDoItems objectAtIndex:self.path.row];
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
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes/%@.json",[toDoItem.note_id description]];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"PUT"];
        [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *stringData = [NSString stringWithFormat:@"{ \"note\" : { \"content\":\"%@\", \"status\":\"%@\" } }",toDoItem.content,toDoItem.status];
        NSLog(@"%@",stringData);
        [req setHTTPBody:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                if ([httpResponse statusCode] == 401){
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Update." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                    });
                }
            }
        }];
        [dataTask resume];
    });
    [self.tableView reloadRowsAtIndexPaths:@[self.path] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)handleDoubleTap{
    NSLog(@"Double tapping Now !!!");
    self.tapCount=[NSNumber numberWithInt:2];
    NSLog(@"%@",[NSString stringWithFormat:@"%d",tappedRow]);
    self.editItem = [self.toDoItems objectAtIndex:self.path.row];
    [self performSegueWithIdentifier:@"edit_path" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self.tapCount isEqualToNumber:[NSNumber numberWithInt:2]])
    {
    UINavigationController *nav = [segue destinationViewController];
    XYZAddToDoItemViewController *dest = (XYZAddToDoItemViewController*)nav.topViewController;
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
 

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"inside editingStyleforRowAtIndexPath");
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        XYZToDoList *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSLog(@"NOTE_ID => %@",toDoItem.note_id);
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes/%@.json",toDoItem.note_id];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"DELETE"];
        [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                if ([httpResponse statusCode] == 401){
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Update." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                        });
                    [self.tableView reloadData];
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(),^{
                        userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Successfully deleted note." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                        [alertView showWithCompletion:NULL];
                        [self.toDoItems removeObjectAtIndex:indexPath.row];
                        [self.tableView reloadData];
                    });
                }
            }
        }];
        [dataTask resume];
    });
    
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



@end
