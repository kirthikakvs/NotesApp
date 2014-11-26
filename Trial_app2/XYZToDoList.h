//
//  XYZToDoList.h
//  Trial_app2
//
//  Created by kirthikas on 24/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYZToDoList : NSObject

@property NSString *itemName;
@property BOOL completed;
@property (readonly) NSDate *created;


@end
