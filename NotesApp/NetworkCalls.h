//
//  NetworkCalls.h
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkCalls : NSObject


+ (NetworkCalls *)sharedNetworkCall;


- (void) sendRequestWithoutData:(NSString *)url REQ_TYPE:(NSString*)reqType ACCESS_TOKEN:(NSString*)access
                                      completion:(void(^)(NSDictionary *responseObject, NSError *error))completion;

- (void) sendRequest:(NSString *)url REQ_TYPE:(NSString *)reqType  DATA:(NSString *) data ACCESS_TOKEN:(NSString*)access completion:(void(^)(NSDictionary *responseObject, NSError *error))completion;

- (void) sendRequestWithData:(NSString *)url REQ_TYPE:(NSString *)reqType  DATA:(NSString *) data completion:(void(^)(NSDictionary *responseObject, NSError *error))completion;

- (void) sendRequestWithoutAccessToken:(NSString *)url REQ_TYPE:(NSString*)reqType 
                     completion:(void(^)(NSDictionary *responseObject, NSError *error))completion;


@end
