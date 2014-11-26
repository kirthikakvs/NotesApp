//
//  Note.h
//  Trial_app2
//
//  Created by kirthikas on 25/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSNumber *completed;
@property (nonatomic, retain) NSString *note;

@end
