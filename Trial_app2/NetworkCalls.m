//
//  NetworkCalls.m
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "NetworkCalls.h"
#import "NotesConstants.h"
#import "userAlertView.h"

static NetworkCalls *sharedNetworkCall = nil;


@implementation NetworkCalls

+ (NetworkCalls*)sharedNetworkCall {
    	    if (sharedNetworkCall == nil) {
        	        sharedNetworkCall = [[NetworkCalls alloc]init];
                	    // initialize your variables here
        	    }
    	    return sharedNetworkCall;
    	}

- (void) sendRequestWithoutData:(NSString *)url REQ_TYPE:(NSString*)reqType ACCESS_TOKEN:(NSString*)access
                                      completion:(void(^)(NSDictionary *responseObject, NSError *error))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
    __block NSDictionary *resp;
        NSLog(@"string for URL => %@",url);
    NSURL *u = [NSURL URLWithString:url];
        NSLog(@"URL => %@",[u description]);
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
    [req setHTTPMethod:reqType];
    [req setValue:access forHTTPHeaderField:API_KEY];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Accept"];
    //[req setValue:URL_CONTENT forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if(error)
        {
            completion(nil,error);
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", json);
        if( [response isKindOfClass:[NSHTTPURLResponse class]]){
            resp = [NSDictionary dictionaryWithObjectsAndKeys:json,@"json",httpResponse,@"response",nil];
            if(!resp)
            {
                resp=nil;
            }
            completion(resp, nil);
        }
    }];
    [dataTask resume];
    });
}


- (void) sendRequest:(NSString *)url REQ_TYPE:(NSString *)reqType  DATA:(NSString *)data ACCESS_TOKEN:(NSString*)access completion:(void(^)(NSDictionary *responseObject, NSError *error))completion{
    __block NSDictionary *resp;
    NSURL *u = [NSURL URLWithString:url ];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
    [req setHTTPMethod:reqType];
    [req setValue:access forHTTPHeaderField:API_KEY];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Accept"];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Content-Type"];
    NSString *stringData = [NSString stringWithFormat:data];
    NSLog(@"HTTP BODY => %@",stringData);
    [req setHTTPBody:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", json);
        if( [response isKindOfClass:[NSHTTPURLResponse class]]){
            resp = [NSDictionary dictionaryWithObjectsAndKeys:json,@"json",httpResponse,@"response",nil];
            completion(resp, nil);
        }
    }];
    [dataTask resume];
}

- (void) sendRequestWithoutAccessToken:(NSString *)url REQ_TYPE:(NSString*)reqType
                            completion:(void(^)(NSDictionary *responseObject, NSError *error))completion
{
    __block NSDictionary *resp;
    NSURL *u = [NSURL URLWithString:url ];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
    [req setHTTPMethod:reqType];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Accept"];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", json);
        if( [response isKindOfClass:[NSHTTPURLResponse class]]){
            resp = [NSDictionary dictionaryWithObjectsAndKeys:json,@"json",httpResponse,@"response",nil];
            completion(resp, nil);
        }
    }];
    [dataTask resume];
}

- (void) sendRequestWithData:(NSString *)url REQ_TYPE:(NSString *)reqType  DATA:(NSString *) data completion:(void(^)(NSDictionary *responseObject, NSError *error))completion
{
    __block NSDictionary *resp;
    NSURL *u = [NSURL URLWithString:url ];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
    [req setHTTPMethod:reqType];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Accept"];
    [req setValue:URL_CONTENT forHTTPHeaderField:@"Content-Type"];
    NSString *stringData = [NSString stringWithFormat:data];
    NSLog(@"HTTP BODY => %@",stringData);
    [req setHTTPBody:[stringData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", json);
        if( [response isKindOfClass:[NSHTTPURLResponse class]]){
            resp = [NSDictionary dictionaryWithObjectsAndKeys:json,@"json",httpResponse,@"response",nil];
            completion(resp, nil);
        }
    }];
    [dataTask resume];
}



@end
