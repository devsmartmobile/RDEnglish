//
//  PhoneticTextView.m
//  SmartEdict
//
//  Created by Han Tran on 3/16/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import "PhoneticTextView.h"
@interface PhoneticTextView () <UITextViewDelegate>
@end

@implementation PhoneticTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self resignFirstResponder];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self resignFirstResponder];

    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self resignFirstResponder];

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self resignFirstResponder];

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self resignFirstResponder];

    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self resignFirstResponder];

}

@end
