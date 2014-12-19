//
//  NetworkCalls.h
//  Trial_app2
//
//  Created by kirthikas on 19/12/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkCalls : NSObject



+ (NSHTTPURLResponse *) sendRequestWithoutData:(NSString *)url REQ_TYPE:(NSString*)req ACCESS_TOKEN:(NSString*)access;
+ (NSHTTPURLResponse *) sendRequest:(NSString *)url REQ_TYPE:(NSString *)req  DATA:(NSData *) data ACCESS_TOKEN:(NSString*)access;

@end
