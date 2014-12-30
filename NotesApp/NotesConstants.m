//
//  NotesConstants.m
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "NotesConstants.h"




@implementation NotesConstants

NSString * GET_USER = @"http://192.168.5.179:3000/users/%@.json";
NSString * CREATE_USER=@"http://192.168.5.179:3000/signup.json";
NSString * USER_SIGNIN=@"http://192.168.5.179:3000/signin.json?email=%@&password=%@";
NSString * USER_SIGNOUT=@"http://192.168.5.179:3000/signout.json";
NSString * CREATE_NOTE=@"http://192.168.5.179:3000/notes.json";
NSString * UPDATE_NOTE=@"http://192.168.5.179:3000/notes/%@.json";
NSString * DEL_NOTE=@"http://192.168.5.179:3000/notes/%@.json";
NSString * GET_NOTES=@"http://192.168.5.179:3000/notes.json";
NSString * USER_FORMAT=@"{ \"user\":{ \"name\":\"%@\", \"email\":\"%@\", \"password\":\"%@\", \"password_confirmation\":\"%@\" }}";
NSString * UPDATE_FORMAT=@"{ \"note\" : { \"content\":\"%@\", \"status\":\"%@\" } }";
NSString * NOTE_FORMAT=@"{ \"content\" : \"%@\" }";

@end
