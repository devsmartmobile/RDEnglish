//
//  EDictLabel.m
//  EdictFRD
//
//  Created by Tran Han on 3/15/17.
//
//

#import "EDictLabel.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@implementation EDictLabel 
-(void)initLabel
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestTap = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(didTapOnWord:)];
    [self addGestureRecognizer:gestTap];

}
-(void)didTapOnWord:(UITapGestureRecognizer*)tap
{
    [self.delegate showDetailVocabolaryWithTag:self.tag];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
