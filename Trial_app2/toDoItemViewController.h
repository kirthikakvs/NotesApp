//
//  toDoItemViewController.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "toDoItem.h"

@interface toDoItemViewController : UIViewController

{
    NSManagedObjectContext *managedObjectContext;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic,strong)toDoItem *toDotem;
@property (nonatomic,strong) id send;
@property (nonatomic,strong) toDoItem *editedItem;
@property (nonatomic,strong) NSNumber *taps;



@end
