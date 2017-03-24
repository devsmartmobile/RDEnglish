//
//  RDStoryTableViewCell.m
//  ReadingEnglish
//
//  Created by Tran Han on 3/23/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import "RDStoryTableViewCell.h"

@implementation RDStoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.storyLabel 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setStoryDetailLabel:(NSString *)storyDetailLabel
{
    self.storyLabel.text = storyDetailLabel;
    self.storyLabel.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    self.storyLabel.font = [UIFont systemFontOfSize:10];
}
-(void)layoutCell
{
    // Create the next view controller.
    UIView *subView = self.storyLabel;
    UIView *parent=self;
    
    //Trailing
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parent
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Leading
    
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parent
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Bottom
    NSLayoutConstraint *Top =[NSLayoutConstraint
                              constraintWithItem:subView
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:parent
                              attribute:NSLayoutAttributeTop
                              multiplier:1.0f
                              constant:0.0f];
    
    //Height to be fixed for SubView same as AdHeight
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:parent
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1.0f
                                  constant:0.0f];
    
    
    [parent addConstraint:trailing];
    [parent addConstraint:Top];
    [parent addConstraint:leading];
    [parent addConstraint:bottom];

}
@end
