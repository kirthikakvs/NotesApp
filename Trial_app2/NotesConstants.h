//
//  NotesConstants.h
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ID @"USER_ID"
#define TOKEN @"ACCESS_TOKEN"
#define API_KEY @"X-Api-Key"
#define URL_CONTENT @"application/json"
#define GET @"GET"
@interface NotesConstants : NSObject
{
    

}

extern NSString * GET_USER;
extern NSString * CREATE_USER;
extern NSString * USER_SIGNIN;
extern NSString * USER_SIGNOUT;
extern NSString * CREATE_NOTE;
extern NSString * UPDATE_NOTE;
extern NSString * DEL_NOTE;
extern NSString * GET_NOTES;

@end
