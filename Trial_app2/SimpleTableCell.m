//
//  SimpleTableCell.m
//  Trial_app2
//
//  Created by kirthikas on 26/11/14.
//  Copyright (c) 2014 kirthikas. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell

-(void) handleSingleTapLocally{
    [self.delegate handleSingleTap];
    //   NSLog(@"Selected row %@",[NSString stringWithFormat:@"%d",tappedRow]);
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    float delay = 0.2;
    
    if(((UITouch *)[touches anyObject]).tapCount == 1){
        [self performSelector:@selector(handleSingleTapLocally) withObject:nil afterDelay:delay];
    }
    
    if(((UITouch *)[touches anyObject]).tapCount == 2){
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.delegate handleDoubleTap];
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
