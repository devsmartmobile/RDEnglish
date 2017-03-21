//
//  EdictTextView.m
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//

#import "EdictTextView.h"
#import "EDictLabel.h"
#import "KLCPopup.h"
#import "EdictDatabase.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMenu.h"
#import "MBProgressHUD.h"
@interface EdictTextView ()<EDictLabelDelegate,KLCPopupDelegate>
{
    KLCPopup *popUp;
    AVSpeechUtterance *utterance;
    AVSpeechSynthesizer *synthesizer;
    CGFloat xOriginal;
    CGFloat yOriginal ;
    CGFloat maxWidth ;
    CGFloat maxHeight ;

}
@end


@implementation EdictTextView
-(void)setupEdictTextViewWithFrame:(CGRect)framePaper
{
    xOriginal = 3.0f;
    yOriginal = 0.0f;
    maxWidth = 0.0f;
    maxHeight = 0.0f;
    self.totalLine = 0;
    // loop for with array word
        for (int i =0; i < self.arrWord.count; i++) {
            // get key object
            NSString *key =  [self.arrWord objectAtIndex:i];
            //get object from key
            NSString *phonetic = [self.arrPhonetic objectAtIndex:i];
            if ([key containsString:@"\n"]) {
                goto break_line;
            }
            [self addSubviewWithKey:key withPhonetic:phonetic withTag:i];
            // calcule origin of text view when need to break line
            if ((xOriginal + 3.0f + maxWidth) < (framePaper.size.width  - ((self.totalLine == 0 || self.totalLine == 1) ? 50 : 0.0f) - (maxWidth + 10.0))) {
                xOriginal += maxWidth + 3.0f ;
            }else
            {
            break_line:
                xOriginal = 3.0f;
                yOriginal += maxHeight - 5.f ;
                self.totalHeight = yOriginal;
                maxWidth = 0.0f;
                maxHeight = 0.0f;
                ++self.totalLine;
            }

        }
    //Change frame after setup view finished
    self.contentSize = CGSizeMake(self.frame.size.width,100 + self.totalHeight);
}
-(void)addSubviewWithKey :(NSString*)key withPhonetic:(NSString*)phonetic withTag:(NSInteger)tag
{
    UIFont *fontForlable = [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView];
    // get frame size for key string
    CGSize sizeKey = [key sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
    // get frame size for value string
    CGSize sizePhonetic = [phonetic sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
    
    maxWidth =MAX(sizeKey.width,sizePhonetic.width);
    maxHeight = MAX(maxHeight, sizePhonetic.height+sizeKey.height);
    
    // creat UIlabel with key size
    EDictLabel *labelPhonetic = [[EDictLabel alloc] init];
    labelPhonetic.backgroundColor = [UIColor clearColor];
    labelPhonetic.font = fontForlable;
    UIFontDescriptor * fontD = [labelPhonetic.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    labelPhonetic.font = [UIFont fontWithDescriptor:fontD size:[RDConstant sharedRDConstant].fontSizeView-2];
    labelPhonetic.text = phonetic;
    //            rgb(192, 57, 43)
    labelPhonetic.textColor = [UIColor colorWithRed:230/255. green:126/255. blue:34/255. alpha:1.];
    labelPhonetic.frame = CGRectMake(xOriginal, yOriginal, sizePhonetic.width, sizePhonetic.height);
    labelPhonetic.userInteractionEnabled = NO;
    
    // creat UIlabel with key size
    EDictLabel *labelKey = [[EDictLabel alloc] init];
    labelKey.backgroundColor = [UIColor clearColor];
    labelKey.font = fontForlable;
    labelKey.text = key;
    //            rgb(44, 62, 80)
    labelKey.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    labelKey.frame = CGRectMake(xOriginal, yOriginal + sizePhonetic.height - 5, sizeKey.width, sizeKey.height);
    labelKey.delegate = self;
    labelKey.tag = tag;
    [labelKey initLabel];
    labelKey.userInteractionEnabled = YES;
    
    // add key and phonetic on text view
    [self addSubview:labelPhonetic];
    [self addSubview:labelKey];

}
-(void)setupEdictTextViewWithFrameForPrint:(CGRect)framePaper withCompleteBlock:(void (^)(NSArray *arrPaper))completion
{
    NSMutableArray *arrPaper = [NSMutableArray array];
    xOriginal = 3.0f;
    yOriginal = 0.0f;
    maxWidth = 0.0f;
    maxHeight = 0.0f;
    self.totalLine = 0;
    EdictTextView *textToPrint = [[EdictTextView alloc]  initWithFrame:CGRectMake(0.0, 0.0, 598, 842)];
    textToPrint.totalHeight = 0.0f;
    // loop for with array word
    for (int i =0; i < self.arrWord.count; i++) {
        // get key object
        NSString *key =  [self.arrWord objectAtIndex:i];
        //get object from key
        NSString *phonetic = [self.arrPhonetic objectAtIndex:i];
        
        if ([key isEqualToString:@"\n"]) {
            goto line_break;
        }
        [self addSubviewWithKey:key withPhonetic:phonetic withTextView:textToPrint withTag:i];
        // calcule origin of text view when need to break line
        if ((xOriginal + 3.0 + maxWidth) < (framePaper.size.width - (maxWidth + 10.0))) {
            xOriginal += maxWidth + 3.0;
        }else
        {
        line_break:
            xOriginal= 10.0f;
            yOriginal +=maxHeight - 5.f;
            textToPrint.totalHeight = yOriginal;
            maxWidth = 0.0f;
            maxHeight = 0.0f;
            ++textToPrint.totalLine;
        }
        if (textToPrint.totalHeight >= (842 - maxHeight)) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [arrPaper addObject:[self getImageFromView:textToPrint]];
//            });

            for (UILabel *label in textToPrint.subviews) {
                [label removeFromSuperview];
            }
            textToPrint = nil;
            textToPrint = [[EdictTextView alloc]  initWithFrame:CGRectMake(0.0, 0.0, 598, 842)];
            textToPrint.totalHeight = 0.0f;
            xOriginal = 3.0f;
            yOriginal = 0.0f;
            maxWidth = 0.0f;
            maxHeight = 0.0f;

        }else
        {
            if (i == self.arrWord.count -1) {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [arrPaper addObject:[self getImageFromView:textToPrint]];
//                });
                
            }
        }
    }
    completion (arrPaper);
}
-(void)addSubviewWithKey :(NSString*)key withPhonetic:(NSString*)phonetic withTextView:(EdictTextView*)textview withTag:(NSInteger)tag
{
    UIFont *fontForlable = [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView];
    // get frame size for key string
    CGSize sizeKey = [key sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
    // get frame size for value string
    CGSize sizePhonetic = [phonetic sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
    
    maxWidth =MAX(sizeKey.width,sizePhonetic.width);
    maxHeight = MAX(maxHeight, sizePhonetic.height+sizeKey.height);
    
    // creat UIlabel with key size
    //        rgb(230, 126, 34)
    EDictLabel *labelPhonetic = [[EDictLabel alloc] init];
    labelPhonetic.backgroundColor = [UIColor clearColor];
    labelPhonetic.font = fontForlable;
    UIFontDescriptor * fontD = [labelPhonetic.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    labelPhonetic.font = [UIFont fontWithDescriptor:fontD size:[RDConstant sharedRDConstant].fontSizeView-2];
    labelPhonetic.text = phonetic;
    labelPhonetic.textColor = [UIColor colorWithRed:230/255. green:126/255. blue:34/255. alpha:1.];
    labelPhonetic.frame = CGRectMake(xOriginal, yOriginal, sizePhonetic.width, sizePhonetic.height);
    
    // creat UIlabel with key size
    //        rgb(127, 140, 141)
    EDictLabel *labelKey = [[EDictLabel alloc] init];
    labelKey.backgroundColor = [UIColor clearColor];
    labelKey.font = fontForlable;
    labelKey.text = key;
    labelKey.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    labelKey.frame = CGRectMake(xOriginal, yOriginal + sizePhonetic.height -5, sizeKey.width, sizeKey.height);
    
    // add key and phonetic on text view
    [textview addSubview:labelPhonetic];
    [textview addSubview:labelKey];

}
-(void)showDetailVocabolaryWithTag:(NSInteger)tag
{
    [self resignFirstResponder];
    [self showMenu:[self viewWithTag:tag]];

}
//Arabic (Saudi Arabia) - ar-SA
//Chinese (China) - zh-CN
//Chinese (Hong Kong SAR China) - zh-HK
//Chinese (Taiwan) - zh-TW
//Czech (Czech Republic) - cs-CZ
//Danish (Denmark) - da-DK
//Dutch (Belgium) - nl-BE
//Dutch (Netherlands) - nl-NL
//English (Australia) - en-AU
//English (Ireland) - en-IE
//English (South Africa) - en-ZA
//English (United Kingdom) - en-GB
//English (United States) - en-US
//French (Canada) - fr-CA
//French (France) - fr-FR
//Finnish (Finland) - fi-FI
//German (Germany) - de-DE
//Hindi (India) - hi-IN
//Hungarian (Hungary) - hu-HU
//Indonesian (Indonesia) - id-ID
//Italian (Italy) - it-IT
//Japanese (Japan) - ja-JP
//Korean (South Korea) - ko-KR
//Norwegian (Norway) - no-NO
//Romanian (Romania) - ro-RO
//Russian (Russia) - ru-RU
//Slovak (Slovakia) - sk-SK
//Spanish (Mexico) - es-MX
//Swedish (Sweden) - sv-SE
//Turkish (Turkey) - tr-TR
-(void)playAudio:(UIButton*)obj
{
    UILabel *label = [self viewWithTag:obj.tag];
    synthesizer = [[AVSpeechSynthesizer alloc]init];
    utterance = [AVSpeechUtterance speechUtteranceWithString:label.text];
    [utterance setRate:0.5f];
    [synthesizer speakUtterance:utterance];
}
-(void)didFinishDismissingKpopup
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
}
- (void) imageWithView:(UIView *)view withCompleteBlock:(void (^)(NSArray *arrPaper))completion
{
     [self setupEdictTextViewWithFrameForPrint:CGRectMake(0.0, 0.0, 598, 842) withCompleteBlock:^(NSArray *arrPaper) {
        if (arrPaper) {
            
            completion(arrPaper);

        }
    }];
}
-(UIImage*)getImageFromView:(EdictTextView*)view
{
    view.hidden = YES;
    UIView * imageRenderbackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 598, 842)];
    imageRenderbackground.backgroundColor = [UIColor whiteColor];
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(598, 842), view.opaque, 0.0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        [imageRenderbackground.layer renderInContext:UIGraphicsGetCurrentContext()];
        for (UILabel *label in view.subviews) {
//            [label  drawViewHierarchyInRect:label.frame afterScreenUpdates:YES];
//            [label.layer drawInContext:UIGraphicsGetCurrentContext()];
            [label drawTextInRect:label.frame];
        }
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        view.hidden = NO;
    
    return img;

}
-(UIImage*)crop:(CGRect)frame withImage:(UIImage*)image
{
    // Find the scalefactors  UIImageView's widht and height / UIImage width and height
    CGFloat widthScale = 1;
    CGFloat heightScale = 1;
    
    // Calculate the right crop rectangle
    frame.origin.x = frame.origin.x * (1 / widthScale);
    frame.origin.y = frame.origin.y * (1 / heightScale);
    frame.size.width = frame.size.width * (1 / widthScale);
    frame.size.height = frame.size.height * (1 / heightScale);
    
    // Create a new UIImage
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (void)showMenu:(UILabel *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"ACTION MENU 1234456"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"Share this"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Check this menu"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Reload page"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Search"
                     image:[UIImage imageNamed:@"search_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Go home"
                     image:[UIImage imageNamed:@"home_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    if (self.superview.frame.size.height > 736) {
        menuItems =
        @[
          
          [KxMenuItem menuItem:@"ACTION MENU 1234456 1234456 1234456"
                         image:nil
                        target:nil
                        action:NULL],
          
          [KxMenuItem menuItem:@"Share this"
                         image:[UIImage imageNamed:@"action_icon"]
                        target:self
                        action:@selector(pushMenuItem:)],
          
          [KxMenuItem menuItem:@"Check this menu"
                         image:nil
                        target:self
                        action:@selector(pushMenuItem:)],
          
          [KxMenuItem menuItem:@"Reload page"
                         image:[UIImage imageNamed:@"reload"]
                        target:self
                        action:@selector(pushMenuItem:)],
          
          [KxMenuItem menuItem:@"Search"
                         image:[UIImage imageNamed:@"search_icon"]
                        target:self
                        action:@selector(pushMenuItem:)],
          
          [KxMenuItem menuItem:@"Go home"
                         image:[UIImage imageNamed:@"home_icon"]
                        target:self
                        action:@selector(pushMenuItem:)],
          [KxMenuItem menuItem:@"Go home"
                         image:[UIImage imageNamed:@"home_icon"]
                        target:self
                        action:@selector(pushMenuItem:)],
          [KxMenuItem menuItem:@"Go home"
                         image:[UIImage imageNamed:@"home_icon"]
                        target:self
                        action:@selector(pushMenuItem:)]

          ];

    }
    if (self.superview.frame.size.height <586) {
        menuItems =
        @[
          
          [KxMenuItem menuItem:@"ACTION MENU 1234456 "
                         image:nil
                        target:nil
                        action:NULL],
          
          [KxMenuItem menuItem:@"ACTION MENU 1234456"
                         image:nil
                        target:nil
                        action:NULL],
          
          [KxMenuItem menuItem:@"ACTION MENU 1234456"
                         image:nil
                        target:nil
                        action:NULL],
          
          [KxMenuItem menuItem:@"ACTION MENU 1234456"
                         image:nil
                        target:nil
                        action:NULL],
          
          ];
        
    }

    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    NSString *detail = [[EdictDatabase database].strDetail objectAtIndex:sender.tag];
    [KxMenu sharedMenu].htmlString = detail;
    [KxMenu sharedMenu].textAudio = ([sender isKindOfClass:[UILabel class]]) ? sender.text : @"";
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_DETAIL_DICTIONARY;
    [KxMenu showMenuInView:self
                  fromRect:CGRectMake(sender.frame.origin.x, sender.frame.origin.y - (self.contentOffset.y > 0 ? self.contentOffset.y :0.0f), sender.frame.size.width, sender.frame.size.height)
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
}

@end
