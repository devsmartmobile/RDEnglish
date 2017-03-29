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
#import "PhoneticLabel.h"
@interface EdictTextView ()<EDictLabelDelegate,KLCPopupDelegate>
{
    KLCPopup *popUp;
    AVSpeechUtterance *utterance;
    AVSpeechSynthesizer *synthesizer;
    CGFloat xOriginal;
    CGFloat yOriginal ;
    CGFloat maxWidth ;
    CGFloat maxHeight ;
    CGSize sizeKey;
    CGSize sizePhonetic;
    CGFloat xOriginalPrint;
    CGFloat yOriginalPrint ;
    CGFloat maxWidthPrint ;
    CGFloat maxHeightPrint ;
    CGSize sizeKeyPrint;
    CGSize sizePhoneticPrint;

    NSInteger location;
    NSInteger sumPreLeghtChar ;
    NSInteger sumPreSpace ;

}

@end


@implementation EdictTextView
-(void)initEdictTextView
{
    xOriginal = 2.0f;
    yOriginal = 0.0f;
    maxWidth = 0.0f;
    maxHeight = 0.0f;
    sizeKey= CGSizeZero;
    sizePhonetic = CGSizeZero;
    location = 0;
    sumPreLeghtChar = 0;
    sumPreSpace = 0;
    self.totalLine = 0;

}
-(void)setupEdictTextViewWithFrame:(CGRect)framePaper
{

    [self initEdictTextView];
    self.totalLine = 0;
    // loop for with array word
        for (int i =0; i < self.arrWord.count; i++) {
            // get key object
            NSString *key =  [self.arrWord objectAtIndex:i];
            //get object from key
            NSString *phonetic = [self.arrPhonetic objectAtIndex:i];
            // get frame size for key string
            sizeKey = [key sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
            // get frame size for value string
            sizePhonetic = [phonetic sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView -2] }];
            
            maxWidth =MAX(sizeKey.width,sizePhonetic.width);
            maxHeight = MAX(maxHeight, sizePhonetic.height+sizeKey.height);
            
            if ([key containsString:@"\n"]) {
                goto break_line;
            }

            // calcule origin of text view when need to break line
//            ((self.totalLine == 0 || self.totalLine == 1) ? 50 : 0.0f)
            if (xOriginal <= (framePaper.size.width  -  (maxWidth))) {
                [self addSubviewWithKey:key withPhonetic:phonetic withSizeKey:sizeKey withSizePhonetic:sizePhonetic withTag:i withLocation:location];
                xOriginal += maxWidth + 2.0f ;
                sumPreSpace      = i  ;
                sumPreLeghtChar  += key.length;
                location = sumPreSpace + sumPreLeghtChar + 1;

            }else
            {
            break_line:
                if ([key containsString:@"\n"]) {
                    xOriginal = 2.0f;
                    yOriginal += sizeKey.height -5.0f ;
                    self.totalHeight = yOriginal;
                    maxWidth = 0.0f;
                    maxHeight = 0.0f;
                    ++self.totalLine;
                }else
                {
                    xOriginal = 2.0f;
                    yOriginal += maxHeight - 5.f ;
                    self.totalHeight = yOriginal;
                    ++self.totalLine;
                    [self addSubviewWithKey:key withPhonetic:phonetic withSizeKey:sizeKey withSizePhonetic:sizePhonetic withTag:i withLocation:location];
                    xOriginal += maxWidth + 2.0f ;
                    sumPreSpace      = i  ;
                    sumPreLeghtChar  += key.length;
                    location = sumPreSpace + sumPreLeghtChar + 1;

                }
            }

        }
    //Change frame after setup view finished
    self.contentSize = CGSizeMake(self.frame.size.width,100 + self.totalHeight);
}
-(void)setupEdictTextViewWithFrame:(CGRect)framePaper forIndex:(NSInteger)index withWord:(NSString*)wordPar withPhonetic:(NSString*)phoneticPar withLocation:(NSInteger)locationPar
{
    
        // loop for with array word
        // get key object
        NSString *key =  wordPar;
        //get object from key
        NSString *phonetic = phoneticPar;

        // get frame size for key string
        sizeKey = [key sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
        // get frame size for value string
        sizePhonetic = [phonetic sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
        
        maxWidth =MAX(sizeKey.width,sizePhonetic.width);
        maxHeight = MAX(maxHeight, sizePhonetic.height+sizeKey.height);
        
        if ([key containsString:@"\n"]) {
            goto break_line;
        }
        
        // calcule origin of text view when need to break line
        //            ((self.totalLine == 0 || self.totalLine == 1) ? 50 : 0.0f)
        if (xOriginal <= (framePaper.size.width  -  (maxWidth))) {
            [self addSubviewWithKey:key withPhonetic:phonetic withSizeKey:sizeKey withSizePhonetic:sizePhonetic withTag:index withLocation:locationPar];
            //
            xOriginal += maxWidth + 2.0f ;
        }else
        {
        break_line:
            if ([key containsString:@"\n"]) {
                xOriginal = 2.0f;
                yOriginal += sizeKey.height -5.0f ;
                self.totalHeight = yOriginal;
                maxWidth = 0.0f;
                maxHeight = 0.0f;
                ++self.totalLine;
                sumPreLeghtChar ++;
            }else
            {
                xOriginal = 2.0f;
                yOriginal += maxHeight - 5.f ;
                self.totalHeight = yOriginal;
                ++self.totalLine;
                [self addSubviewWithKey:key withPhonetic:phonetic withSizeKey:sizeKey withSizePhonetic:sizePhonetic withTag:index withLocation:locationPar];
                //
                xOriginal += maxWidth + 2.0f ;
                
            }
        }
    
//        sumPreSpace      = index  ;
//        sumPreLeghtChar  += key.length;
//        location = sumPreSpace + sumPreLeghtChar +1;
//        NSLog(@"location in view %ld",(long)location);
    

      //Change frame after setup view finished
      self.contentSize = CGSizeMake(self.frame.size.width,100 + self.totalHeight);

}
-(void)addSubviewWithKey :(NSString*)key withPhonetic:(NSString*)phonetic withSizeKey:(CGSize)sizeKeyPar withSizePhonetic:(CGSize)sizePhoneticPar  withTag:(NSInteger)tag withLocation:(NSInteger)localtionPar
{
    UIFont *fontForlable = [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView];
    // creat UIlabel with key size
    PhoneticLabel *labelPhonetic = [[PhoneticLabel alloc] init];
    labelPhonetic.backgroundColor = [UIColor clearColor];
    labelPhonetic.font = fontForlable;
    UIFontDescriptor * fontD = [labelPhonetic.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    labelPhonetic.font = [UIFont fontWithDescriptor:fontD size:[RDConstant sharedRDConstant].fontSizeView-2];
    labelPhonetic.text = phonetic;
    [labelPhonetic initPhoneticLabel];
    labelPhonetic.tag = -1009;
//    NSLog(@"tag is %ld",labelPhonetic.tag);

    //            rgb(192, 57, 43)
    labelPhonetic.textColor = [UIColor colorWithRed:230/255. green:126/255. blue:34/255. alpha:1.];
    labelPhonetic.frame = CGRectMake(xOriginal, yOriginal, maxWidth, sizePhoneticPar.height);
    labelPhonetic.maxWidth = maxWidth;
    labelPhonetic.userInteractionEnabled = YES;
    
    // creat UIlabel with key size
    EDictLabel *labelKey = [[EDictLabel alloc] init];
    labelKey.backgroundColor = [UIColor clearColor];
    labelKey.font = fontForlable;
    labelKey.text = key;
    //            rgb(44, 62, 80)
    labelKey.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    labelKey.frame = CGRectMake(xOriginal, yOriginal + sizePhoneticPar.height - 5, maxWidth, sizeKeyPar.height);
    labelKey.delegate = self;
    labelKey.tag = localtionPar ;
    labelKey.indexLabel = tag;
    [labelKey initLabel:labelPhonetic];
    labelKey.userInteractionEnabled = YES;
    
    // add key and phonetic on text view
    [self addSubview:labelPhonetic];
    [self addSubview:labelKey];
    if (labelKey.frame.origin.y > self.contentOffset.y + self.frame.size.height) {
        
        [self setContentOffset:CGPointMake(self.contentOffset.x, labelKey.frame.origin.y) ];

    }

}
-(void)setupEdictTextViewWithFrameForPrint:(CGRect)framePaper withCompleteBlock:(void (^)(NSArray *arrPaper))completion
{
    NSMutableArray *arrPaper = [NSMutableArray array];
    xOriginalPrint = 2.0f;
    yOriginalPrint = 0.0f;
    maxWidthPrint = 0.0f;
    maxHeightPrint = 0.0f;
    sizeKeyPrint= CGSizeZero;
    sizePhoneticPrint = CGSizeZero;
    self.totalLinePrint = 0;
    EdictTextView *textToPrint = [[EdictTextView alloc]  initWithFrame:framePaper];
    textToPrint.totalHeightPrint = 0.0f;
    // loop for with array word
    for (int i =0; i < self.arrWord.count; i++) {
        // get key object
        NSString *key =  [self.arrWord objectAtIndex:i];
        //get object from key
        NSString *phonetic = [self.arrPhonetic objectAtIndex:i];
        // get frame size for key string
        sizeKeyPrint = [key sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
        // get frame size for value string
        sizePhoneticPrint = [phonetic sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView] }];
        
        maxWidthPrint =  MAX(sizeKeyPrint.width,sizePhoneticPrint.width);
        maxHeightPrint = MAX(maxHeightPrint, sizePhoneticPrint.height+sizeKeyPrint.height);

        if ([key isEqualToString:@"\n"]) {
            goto line_break;
        }
        // calcule origin of text view when need to break line
        if ((xOriginalPrint) < (framePaper.size.width - (maxWidthPrint + framePaper.size.width > 842 ? 600 : 20.0f))) {
            [self addSubviewWithKey:key withPhonetic:phonetic withTextView:textToPrint withSizeKey:sizeKeyPrint withSizePhonetic:sizePhoneticPrint withTag:i];
            xOriginalPrint += maxWidthPrint + 2.0;
        }else
        {
        line_break:
            if ([key containsString:@"\n"]) {
                xOriginalPrint = 2.0f;
                yOriginalPrint += sizeKeyPrint.height - 5.0f ;
                textToPrint.totalHeightPrint = yOriginalPrint + maxHeightPrint;
                maxWidthPrint = 0.0f;
                maxHeightPrint = 0.0f;
                ++self.totalLinePrint;
            }else
            {
                xOriginalPrint = 2.0f;
                yOriginalPrint += maxHeightPrint - 5.f ;
                textToPrint.totalHeightPrint = yOriginalPrint + maxHeightPrint;
                ++self.totalLinePrint;
                [self addSubviewWithKey:key withPhonetic:phonetic withTextView:textToPrint withSizeKey:sizeKeyPrint withSizePhonetic:sizePhoneticPrint withTag:i];
                xOriginalPrint += maxWidthPrint + 2.0f ;
                
            }

        }
        if (textToPrint.totalHeightPrint > (framePaper.size.height -( maxHeightPrint + framePaper.size.width > 842 ? 850.f : 20.0f))) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [arrPaper addObject:[self getImageFromView:textToPrint]];
//            });

            for (UILabel *label in textToPrint.subviews) {
                [label removeFromSuperview];
            }
            textToPrint = nil;
            textToPrint = [[EdictTextView alloc]  initWithFrame:framePaper];
            textToPrint.totalHeightPrint = 0.0f;
            xOriginalPrint = 2.0f;
            yOriginalPrint = 0.0f;
            maxWidthPrint = 0.0f;
            maxHeightPrint = 0.0f;

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
-(void)addSubviewWithKey :(NSString*)key withPhonetic:(NSString*)phonetic withTextView:(EdictTextView*)textview withSizeKey:(CGSize)sizeKeyPar withSizePhonetic:(CGSize)sizePhoneticPar withTag:(NSInteger)tag
{
    UIFont *fontForlable = [UIFont fontWithName:_fontName size:[RDConstant sharedRDConstant].fontSizeView];
    
    // creat UIlabel with key size
    //        rgb(230, 126, 34)
    EDictLabel *labelPhonetic = [[EDictLabel alloc] init];
    labelPhonetic.backgroundColor = [UIColor clearColor];
    labelPhonetic.font = fontForlable;
    UIFontDescriptor * fontD = [labelPhonetic.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    labelPhonetic.font = [UIFont fontWithDescriptor:fontD size:[RDConstant sharedRDConstant].fontSizeView- 2];
    labelPhonetic.text = phonetic;
    labelPhonetic.textColor = [UIColor colorWithRed:230/255. green:126/255. blue:34/255. alpha:1.];
    labelPhonetic.frame = CGRectMake(xOriginalPrint, yOriginalPrint, sizePhoneticPar.width, sizePhoneticPar.height);
    
    // creat UIlabel with key size
    //        rgb(127, 140, 141)
    EDictLabel *labelKey = [[EDictLabel alloc] init];
    labelKey.backgroundColor = [UIColor clearColor];
    labelKey.font = fontForlable;
    labelKey.text = key;
    labelKey.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    labelKey.frame = CGRectMake(xOriginalPrint, yOriginalPrint + sizePhoneticPar.height -5, sizeKeyPar.width, sizeKeyPar.height);
    
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
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[UtilsXML utilXMLInstance].langCodes[[RDConstant sharedRDConstant].langCode]];
    [utterance setRate:0.5f];
    [synthesizer speakUtterance:utterance];
}
-(void)didFinishDismissingKpopup
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
}
- (void) imageWithView:(UIView *)view withFrame:(CGRect)frame withCompleteBlock:(void (^)(NSArray *arrPaper))completion
{
     [self setupEdictTextViewWithFrameForPrint:frame withCompleteBlock:^(NSArray *arrPaper) {
        if (arrPaper) {
            
            completion(arrPaper);

        }
    }];
}
-(UIImage*)getImageFromView:(EdictTextView*)view
{
    view.hidden = YES;
    UIView * imageRenderbackground = [[UIView alloc] initWithFrame:view.frame];
    imageRenderbackground.backgroundColor = [UIColor whiteColor];
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height), view.opaque, 0.0);
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
    NSArray *menuItems = [[UtilsXML utilXMLInstance] getArrayMenuItemForScreenSearchText:(NSInteger)self.superview.frame.size.height];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    EDictLabel *dicLabel = (EDictLabel*)sender;
    NSString *detail = [[EdictDatabase database].strDetail objectAtIndex:dicLabel.indexLabel];
    [KxMenu sharedMenu].htmlString = detail;
    [KxMenu sharedMenu].textAudio = ([sender isKindOfClass:[UILabel class]]) ? sender.text : @"";
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_DETAIL_DICTIONARY;
    [KxMenu showMenuInView:self
                  fromRect:CGRectMake(sender.frame.origin.x, sender.frame.origin.y - (self.contentOffset.y > 0 ? self.contentOffset.y :0.0f), sender.frame.size.width, sender.frame.size.height)
                 menuItems:menuItems];
}

@end
