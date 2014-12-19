//
//  NetworkCalls.m
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "NetworkCalls.h"
#import "NotesConstants.h"

static NSHTTPURLResponse *resp;

@implementation NetworkCalls



+ (NSHTTPURLResponse *) sendRequestWithoutData:(NSString *)url REQ_TYPE:(NSString*)req ACCESS_TOKEN:(NSString*)access
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURL *u = [NSURL URLWithString:url ];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:u];
        [req setHTTPMethod:req];
        [req setValue:access forHTTPHeaderField:API_KEY];
        [req setValue:URL_CONTENT forHTTPHeaderField:@"Accept"];
        [req setValue:URL_CONTENT forHTTPHeaderField:@"Content-Type"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", json);
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                resp = (NSHTTPURLResponse*) response;
            }
        }];
        [dataTask resume];
    });
    return resp;
}

+ (NSHTTPURLResponse *) sendRequest:(NSString *) URL:(NSString *) REQ_TYPE:(NSData *) DATA{
    
    return resp;
}

@end
