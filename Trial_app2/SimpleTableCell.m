//
//  SimpleTableCell.m
//  Trial_app2
//
//  Created by kirthikas on 26/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell


@synthesize noteLabel=_noteLabel;
@synthesize completedLabel=_completedLabel;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
