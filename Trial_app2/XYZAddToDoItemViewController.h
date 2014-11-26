//
//  XYZAddToDoItemViewController.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYZToDoList.h"
#import <CoreData/CoreData.h>

@interface XYZAddToDoItemViewController : UIViewController

{
    NSManagedObjectContext *managedObjectContext;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property XYZToDoList *toDotem;






@end
