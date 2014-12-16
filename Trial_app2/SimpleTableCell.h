//
//  SimpleTableCell.h
//  Trial_app2
//
//  Created by kirthikas on 26/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimpleTableCellDelegate <NSObject>

-(void)handleSingleTap;
-(void)handleDoubleTap;

@end

@interface SimpleTableCell : UITableViewCell

@property (nonatomic,weak) id<SimpleTableCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *noteLabel;
@property (nonatomic, weak) IBOutlet UILabel *completedLabel;

@end
