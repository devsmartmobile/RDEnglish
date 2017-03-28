//
//  PhoneticLabel.m
//  ReadingEnglish
//
//  Created by Tran Han on 3/24/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import "PhoneticLabel.h"
@interface PhoneticLabel ()<UITextFieldDelegate>
@end
@implementation PhoneticLabel
-(void)initPhoneticLabel
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestTap = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(didTapOnWord:)];
    [self addGestureRecognizer:gestTap];

}
-(void)didTapOnWord:(UITapGestureRecognizer*)tap
{
    [self updatePhonetic];
    
}
-(void)updatePhonetic
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Phonetic"
                                                    message:@"Input Phonetic To Update"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text= self.text;
    [alert textFieldAtIndex:0].delegate = self;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.text = [alertView textFieldAtIndex:0].text;
    CGSize sizePhonetic = [self.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[RDConstant sharedRDConstant].fontSizeView] }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizePhonetic.width, sizePhonetic.height);
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isShouldChangeChar = NO;
    CGSize sizePhonetic = [[NSString stringWithFormat:textField.text,string] sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[RDConstant sharedRDConstant].fontSizeView] }];
    if (sizePhonetic.width<=_maxWidth || [string isEqualToString:@""]) {
        isShouldChangeChar = YES;
    }
    return isShouldChangeChar;
}
-(void)hightLightTextlabel
{
    //rgb(52, 152, 219)
    self.backgroundColor = [UIColor colorWithRed:52/255 green:152/255 blue:219/255 alpha:0.6];
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:([RDConstant sharedRDConstant].fontSizeView + 15)];
    CGSize sizeZoom = [self.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:[UtilsXML utilXMLInstance].fontNames[0] size:[RDConstant sharedRDConstant].fontSizeView + 15] }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeZoom.width, sizeZoom.height);
    [self.superview bringSubviewToFront:self];
}
-(void)unhightLightTextlabel
{
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithRed:230/255. green:126/255. blue:34/255. alpha:1.];
    self.font = [UIFont systemFontOfSize:([RDConstant sharedRDConstant].fontSizeView -2)];
    CGSize sizeZoom = [self.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:[UtilsXML utilXMLInstance].fontNames[0] size:[RDConstant sharedRDConstant].fontSizeView] }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeZoom.width, sizeZoom.height);
}

@end
