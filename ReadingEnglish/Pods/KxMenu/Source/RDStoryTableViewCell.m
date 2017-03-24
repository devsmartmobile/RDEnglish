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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setStoryDetail:(NSString *)storyDetail
{
    self.storyLabel.text = storyDetail;
    self.storyLabel.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
}
@end
