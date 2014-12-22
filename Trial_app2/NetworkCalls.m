//
//  NetworkCalls.m
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "NetworkCalls.h"
#import "NotesConstants.h"

static NetworkCalls *sharedNetworkCall = nil;
static NSMutableDictionary *resp;

@implementation NetworkCalls

+ (NetworkCalls*)sharedNetworkCall {
    	    if (sharedNetworkCall == nil) {
        	        sharedNetworkCall = [[NetworkCalls alloc]init];
                	    // initialize your variables here
        	    }
    	    return sharedNetworkCall;
    	}

- (NSMutableDictionary *) sendRequestWithoutData:(NSString *)url REQ_TYPE:(NSString*)reqType ACCESS_TOKEN:(NSString*)access
{
    dispatch_async(dispatch_get_main_queue(),^{
        NSURL *u = [NSURL URLWithString:url ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:reqType];
        [req setValue:access forHTTPHeaderField:API_KEY];
        [req setValue:URL_CONTENT forHTTPHeaderField:@"Accept"];
        [req setValue:URL_CONTENT forHTTPHeaderField:@"Content-Type"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                resp = [NSDictionary dictionaryWithObjectsAndKeys:json,@"json",httpResponse,@"response",nil];
            }
        }];
        [dataTask resume];
    });
    return resp;
}


- (NSMutableDictionary *) sendRequest:(NSString *)url REQ_TYPE:(NSString *)reqType  DATA:(NSData *) data ACCESS_TOKEN:(NSString*)access{
    
    return resp;
}

@end
