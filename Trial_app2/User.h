//
//  User.h
//  Trial_app2
//
//  Created by kirthikas on 09/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    NSString *access_token;
    NSString *remember_token;
    NSNumber *user_id;
}

@property (nonatomic,retain) NSString *access_token;
@property (nonatomic,retain) NSString *remember_token;
@property (nonatomic,retain) NSNumber *user_id;

+ (id) sharedUser;

@end
