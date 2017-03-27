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
-(void)hightLightTextlabel
{
    //rgb(52, 152, 219)
    self.backgroundColor = [UIColor colorWithRed:52/255 green:152/255 blue:219/255 alpha:1];
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:([RDConstant sharedRDConstant].fontSizeView + 4)];
    CGSize sizeZoom = [self.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:[UtilsXML utilXMLInstance].fontNames[0] size:[RDConstant sharedRDConstant].fontSizeView + 4] }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeZoom.width, sizeZoom.height);
    [self.superview bringSubviewToFront:self];
}
-(void)unhightLightTextlabel
{
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    self.font = [UIFont systemFontOfSize:([RDConstant sharedRDConstant].fontSizeView)];
    CGSize sizeZoom = [self.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:[UtilsXML utilXMLInstance].fontNames[0] size:[RDConstant sharedRDConstant].fontSizeView] }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeZoom.width, sizeZoom.height);
}
@end
