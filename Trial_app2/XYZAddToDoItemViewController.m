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
        if ([self.taps isEqualToNumber:[NSNumber numberWithInt:2]])
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                self.toDotem.content = self.textField.text;
                UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
                NSString *user_id = [store stringForKey:@"USER_ID"];
                NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
                NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes/%@.json",[self.toDotem.note_id description]];
                NSURL *u = [NSURL URLWithString:str ];
                NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
                [req setHTTPMethod:@"PUT"];
                [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
                [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                NSString *stringData = [NSString stringWithFormat:@"{ \"note\" : { \"content\":\"%@\", \"status\":\"%@\" } }",self.toDotem.content,self.toDotem.status];
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
        }
        else
        {
        self.toDotem = [[XYZToDoList alloc]init];
        self.toDotem.content = self.textField.text;
        self.toDotem.status = @"Pending";
        self.toDotem.created = [NSDate date];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"com.notes.app"];
        NSString *user_id = [store stringForKey:@"USER_ID"];
        NSString *access_token = [store stringForKey:@"ACCESS_TOKEN"];
        NSString *str = [NSString stringWithFormat:@"http://192.168.5.179:3000/notes.json?content=%@",self.toDotem.content];
        NSURL *u = [NSURL URLWithString:str ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:@"POST"];
        [req setValue:access_token forHTTPHeaderField:@"X-Api-Key"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"JSON RESPONSE => %@ ", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                if ([httpResponse statusCode] == 401){
                        dispatch_sync(dispatch_get_main_queue(),^{
                            userAlertView *alertView = [[userAlertView alloc] initWithTitle:@"Notes App" message:@"Invalid Update." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                            [alertView showWithCompletion:NULL];
                        });
                }
                else
                {
                    //NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    //[f setNumberStyle:NSNumberFormatterDecimalStyle];
                    self.toDotem.note_id = [[json valueForKey:@"id"] description];
                    NSLog(@"NOTE_ID => %@",self.toDotem.note_id);
                }
            }}];
            [dataTask resume];
        });}
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"0210.jpg"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
    CGRect scaledImageRect = CGRectMake( backgroundView.frame.origin.x - 18.0 ,backgroundView.frame.origin.y - 15.0, backgroundView.image.size.width + 10.0 , backgroundView.image.size.width + 10.0);
    backgroundView.frame = scaledImageRect;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    [self.view addSubview:backgroundView];
    UIInterpolatingMotionEffect *verticalMotionEffect= [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-30);
    verticalMotionEffect.maximumRelativeValue = @(30);
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-30);
    horizontalMotionEffect.maximumRelativeValue =@(30);
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[horizontalMotionEffect,verticalMotionEffect];
    [backgroundView addMotionEffect:effectGroup];
    if(self.send)
    {
        self.textField.text = self.toDotem.content;
    }
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
