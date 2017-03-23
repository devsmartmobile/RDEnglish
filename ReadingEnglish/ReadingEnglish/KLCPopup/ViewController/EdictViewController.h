//
//  EdictViewController.h
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//
//https://github.com/mysterioustrousers/MTPDF

#import <UIKit/UIKit.h>
#import "EdictTextView.h"
#import "EdictDatabase.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <TesseractOCR/TesseractOCR.h>
@interface EdictViewController : UIViewController <UITextViewDelegate,G8TesseractDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textViewInput;
@end
