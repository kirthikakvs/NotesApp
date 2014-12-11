//
//  User.m
//  Trial_app2
//
//  Created by kirthikas on 09/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "User.h"



@implementation User

@synthesize access_token;
@synthesize remember_token;
@synthesize user_id;

+ (id) sharedUser
{
    static User *sharedMyUser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyUser = [[self alloc] init];
    });
    return sharedMyUser;
}

- (id) init
{
    if(self = [super init])
    {
        access_token= @"450461847a6c150257e0d583d68ffd9f";
        remember_token=nil;
        user_id=nil;
    }
    return self;
}

- (void) dealloc
{
    access_token=nil;
    remember_token=nil;
    user_id=nil;
}

@end
