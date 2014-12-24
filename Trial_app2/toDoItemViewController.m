//
//  toDoItemViewController.m
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "toDoItemViewController.h"
#import "NotesViewController.h"
#import <CoreData/CoreData.h>
#import "NetworkCalls.h"
#import "NotesConstants.h"
#import "UIView+ParallaxEffect.h"


@interface toDoItemViewController ()
{
    NSString *user_id;
    NSString *access_token;
    NSDictionary *json;
    NSHTTPURLResponse *httpResponse;
    NSDictionary *resp;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation toDoItemViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void) getFromKeyChain
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
    user_id = [store stringForKey:ID];
    access_token = [store stringForKey:TOKEN];
    NSLog(@"USER_ID => %@, ACCESS_TOKEN => %@",user_id,access_token);
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
    });
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender!= self.doneButton)
    {
        return;
    }
    if(self.textField.text.length >0)
    {
        if ([self.taps isEqualToNumber:[NSNumber numberWithInt:2]])
        {
            [[Mobihelp sharedInstance] leaveBreadcrumb:@"Note edited."];
            self.toDotem.content = self.textField.text;
            [self getFromKeyChain];
            NSString *str = [NSString stringWithFormat:UPDATE_NOTE,[self.toDotem.note_id description]];
            NSString *stringData = [NSString stringWithFormat:UPDATE_FORMAT,self.toDotem.content,self.toDotem.status];
            NetworkCalls* call = [NetworkCalls sharedNetworkCall];
            [call sendRequest:str REQ_TYPE:PUT DATA:stringData ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
                resp = response;
                [self processUpdate];
            }];
        }
        else
        {
            [[Mobihelp sharedInstance] leaveBreadcrumb:@"Note Added."];
        self.toDotem = [[toDoItem alloc]init];
        self.toDotem.content = self.textField.text;
        self.toDotem.status = @"Pending";
        self.toDotem.created = [NSDate date];
        [self getFromKeyChain];
        NSString * stringData = [NSString stringWithFormat:NOTE_FORMAT,self.toDotem.content];
        NSString *str = [NSString stringWithFormat:CREATE_NOTE,self.toDotem.content];
        NetworkCalls * call = [NetworkCalls sharedNetworkCall];
        [call sendRequest:str REQ_TYPE:POST DATA:stringData ACCESS_TOKEN:access_token completion:^(NSDictionary *response, NSError *error) {
                resp = response;
                [self processNoteCreation];
            }];
    }
  }
}

-(void) processNoteCreation{
    json = [resp valueForKey:@"json"];
    NSLog(@" after network call JSON response => %@",json);
    httpResponse = [resp valueForKey:@"response"];
    if ([httpResponse statusCode] == 401){
        dispatch_sync(dispatch_get_main_queue(),^{
            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Update." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView showWithCompletion:NULL];
        });
    }
    else{
        self.toDotem.note_id = [[json valueForKey:@"id"] description];
        NSLog(@"NOTE_ID => %@",self.toDotem.note_id);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NetworkCalls *call = [NetworkCalls sharedNetworkCall];
    [[Mobihelp sharedInstance] leaveBreadcrumb:@"Adding/Editing a note"];
    [self.view setParallaxEffect:[UIImage imageNamed:@"0210.jpg"]];
    [self initSetup];
    // Do any additional setup after loading the view.
}

-(void)initSetup
{
    if(self.send)
    {
        self.textField.text = self.toDotem.content;
        [self.navigationItem setTitle:@"Edit To-Do Item"];
    }
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
