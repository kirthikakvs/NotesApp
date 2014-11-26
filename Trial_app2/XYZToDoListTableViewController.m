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

@interface XYZToDoListTableViewController ()

@property NSMutableArray *toDoItems;

@end

@implementation XYZToDoListTableViewController

//View controller life cycle


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
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc]initWithEntityName:@"Note"];
    self.toDoItems = [[managedObjectContext executeFetchRequest:fetch error:nil]mutableCopy];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Loaded view");
    
    self.toDoItems = [[NSMutableArray alloc]init];
        NSLog(@"Loaded Items");
    //[self loadInitialData];
        NSLog(@"Initialized items");
     
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)loadInitialData {
    XYZToDoList *item1 = [[XYZToDoList alloc] init];
    item1.itemName = @"Buy milk";
    [self.toDoItems addObject:item1];
    XYZToDoList *item2 = [[XYZToDoList alloc] init];
    item2.itemName = @"Buy eggs";
    [self.toDoItems addObject:item2];
    XYZToDoList *item3 = [[XYZToDoList alloc] init];
    item3.itemName = @"Read a book";
    [self.toDoItems addObject:item3];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
   // XYZAddToDoItemViewController *source = [segue sourceViewController];
   // XYZToDoList *item= source.toDotem;
   // if(item!=nil)
   // {
   //     [self.toDoItems addObject:item];
    //    [self.tableView reloadData];
    //}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSLog(@"inside cellforrowatindexpath");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    NSManagedObject *Currentnote = [self.toDoItems objectAtIndex:indexPath.row];
    //XYZToDoList *toDoItem=[self.toDoItems objectAtIndex:indexPath.row];
    NSLog(@"%@",[[Currentnote valueForKey:@"completed"] stringValue]);
    [cell.textLabel setText:[NSString stringWithFormat:@"%@",[Currentnote valueForKey:@"note"]]];
    if([[Currentnote valueForKey:@"completed"] boolValue]==YES)
    {
        [Currentnote setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
        NSLog(@"if condition");
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        NSLog(@"else condition");
        [Currentnote setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"inside didselectrowatindexpath");
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObject *selectednote = [self.toDoItems objectAtIndex:indexPath.row];
    
    NSNumber *n= [selectednote valueForKey:@"completed"];
    
    NSLog(@"before : %@", [n stringValue]);
    
    if ( [n isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        [selectednote setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
        NSLog(@"after :%@", [[selectednote valueForKey:@"completed"] stringValue]);
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
    }
    else
    {
        [selectednote setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
        NSLog(@"after :%@", [[selectednote valueForKey:@"completed"] stringValue]);
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
    }
    //XYZToDoList *TappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    //TappedItem.completed = !TappedItem.completed;
    
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

@end
