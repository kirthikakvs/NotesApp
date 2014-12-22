//
//  NetworkCalls.h
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkCalls : NSObject

+ (NetworkCalls *)sharedNetworkCall;

- (NSMutableDictionary *) sendRequestWithoutData:(NSString *)url REQ_TYPE:(NSString*)reqType ACCESS_TOKEN:(NSString*)access;
- (NSMutableDictionary *) sendRequest:(NSString *)url REQ_TYPE:(NSString *)reqType  DATA:(NSData *) data ACCESS_TOKEN:(NSString*)access;

@end
