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

@end

@implementation XYZToDoListTableViewController

//View controller life cycle
@synthesize tapCount;
@synthesize tapTimer;
@synthesize tappedRow;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context= nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Inside viewdidappear");
    [super viewDidAppear:animated];
    NSLog(@"After animation");
    [[self navigationController] setNavigationBarHidden:NO];
    NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    [self.toDoItems sortUsingDescriptors:[NSArray arrayWithObject:d]];
    [self.tableView reloadData];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Loaded view");
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    self.toDoItems = [[NSMutableArray alloc]init];
        NSLog(@"Loaded Items");
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSLog(@"USER_ID => %@, ACCESS_TOKEN => %@",user_id,access_token);
        NSString *str = [NSString stringWithFormat:@"http://0.0.0.0:3000/notes/%@.json",user_id];
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
                    });
                    
                }
            }
        }];
        
        [dataTask resume];
    });
    
    //[self loadInitialData];
        NSLog(@"Initialized items");
     
}


- (void)loadInitialData {
  //  XYZToDoList *item1 = [[XYZToDoList alloc] init];
  //  item1.itemName = @"Buy milk";
   // [self.toDoItems addObject:item1];
   // XYZToDoList *item2 = [[XYZToDoList alloc] init];
   // item2.itemName = @"Buy eggs";
    //[self.toDoItems addObject:item2];
    //XYZToDoList *item3 = [[XYZToDoList alloc] init];
    //item3.itemName = @"Read a book";
    //[self.toDoItems addObject:item3];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.toDoItems count];
}


- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
   XYZAddToDoItemViewController *source = [segue sourceViewController];
    XYZToDoList *item= source.toDotem;
    if(item!=nil)
    {
        [self.toDoItems addObject:item];
        [self.tableView reloadData];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSLog(@"inside cellforrowatindexpath");
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    XYZToDoList *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
   [cell.noteLabel setText:toDoItem.content];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    if([toDoItem.status isEqualToString:@"completed"]) {
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy'-'MM'-'dd''HH':'mm'"];
        cell.completedLabel.text = [@"Completed at:" stringByAppendingString:[format stringFromDate:toDoItem.updated]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if([toDoItem.status isEqualToString:@"Pending"]){
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy'-'MM'-'dd''HH':'mm'"];
        cell.completedLabel.text = [@"Created at:" stringByAppendingString:[format stringFromDate:toDoItem.created]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (void)tapTimerFired:(NSTimer *)aTimer{
    //timer fired, there was a single tap on indexPath.row = tappedRow
    if(tapTimer != nil){
        tapCount = 0;
        tappedRow = -1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSLog(@"inside didselectrowatindexpath");
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        XYZToDoList *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
        
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
        
        NSString *str = [NSString stringWithFormat:@"http://0.0.0.0:3000/notes/%@.json",[toDoItem.note_id description]];
        
        NSURL *u = [NSURL URLWithString:str ];
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        
        [req setHTTPMethod:@"PUT"];
        
        [req setValue:@"450461847a6c150257e0d583d68ffd9f" forHTTPHeaderField:@"X-Api-Key"];
        
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
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    [managedObjectContext deleteObject:[self.toDoItems objectAtIndex:indexPath.row]];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    [self.toDoItems removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
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
