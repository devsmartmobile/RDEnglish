//
//  EdictViewController.h
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//

#import <UIKit/UIKit.h>
#import "EdictTextView.h"
#import "EdictDatabase.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface EdictViewController : UIViewController <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textViewInput;
@end
