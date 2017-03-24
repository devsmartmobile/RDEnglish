//
//  RDStoryTableViewCell.h
//  ReadingEnglish
//
//  Created by Tran Han on 3/23/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDStoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storyLabel;
@property (strong , nonatomic) NSString *storyDetailLabel;
@end
