//
//  XYZAddToDoItemViewController.m
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "XYZAddToDoItemViewController.h"
#import "XYZToDoListTableViewController.h"
#import "Note.h"
#import <CoreData/CoreData.h>


@interface XYZAddToDoItemViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation XYZAddToDoItemViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender!= self.doneButton)
    {
        return;
    }
    if(self.textField.text.length >0)
    {
        self.toDotem = [[XYZToDoList alloc]init];
        self.toDotem.itemName = self.textField.text;
        self.toDotem.completed = NO;
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        [newNote setValue:self.textField.text forKey:@"note"];
        [newNote setValue:[NSDate date] forKey:@"createdAt"];
        [newNote setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
