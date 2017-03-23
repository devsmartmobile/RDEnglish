//
//  EdictViewController.m
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//

#import "EdictViewController.h"
#import "NSString+FDEdict.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "UPStackMenu.h"
#import "KxMenu.h"

@import GoogleMobileAds;

#define debug 1

@interface EdictViewController ()<UIPrintInteractionControllerDelegate,UITextFieldDelegate,UPStackMenuDelegate,UIScrollViewDelegate,AVSpeechSynthesizerDelegate,UIDocumentInteractionControllerDelegate>
{
    BOOL isShowPhonetic;
    BOOL isLoadPhonetic;
    BOOL isPlayAudio;
    AVSpeechUtterance *utterance;
    AVSpeechSynthesizer *synthesizer;
    UIView *contentView;
    UPStackMenu *stack;
    UPStackMenuItem *settingItem;
    UPStackMenuItem *speaker_on;
    UPStackMenuItem *speaker_off;
    UPStackMenuItem *print;
    UPStackMenuItem *save;
    UPStackMenuItem *exportFile;

    CGRect keyboardFrameBeginRect;

}
@property (weak, nonatomic) IBOutlet UIButton *buttonPhonetic;
@property (copy , nonatomic)NSString *textBuffer;
@property (assign , nonatomic)NSUInteger fontSizeBuffer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintButtonSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintTextViewInput;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintScrollText;
@property (weak, nonatomic) IBOutlet GADBannerView *banerView;
@property (assign, nonatomic) BOOL isClearText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintTextInput;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceSearchText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintSearchEnglish;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
- (IBAction)didPressOnPrint:(id)sender;
- (IBAction)didPressOnReading:(id)sender;
- (IBAction)didPressOnPhonetic:(id)sender;
- (IBAction)didPressOnSearch:(id)sender;
- (IBAction)didPressOnSetting:(id)sender;
- (IBAction)openCamera:(id)sender;
- (IBAction)recognizeSampleImage:(id)sender;
@property (nonatomic, strong)UIDocumentInteractionController *documentController;
@property (weak, nonatomic) IBOutlet UIButton *btPhoneticWord;
@property (weak, nonatomic) IBOutlet EdictTextView *scrollText;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EdictViewController


#pragma mark - handle keyboard event of viewcontroller

- (void)keyboardDidShow: (NSNotification *) notif{
    [stack closeStack];
    [KxMenu dismissMenu];
    // Do something here
    NSDictionary* keyboardInfo = [notif userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [UIView animateWithDuration:0.1 animations:^{
        if (self.bottomSpaceSearchText.constant == 61) {
            self.bottomSpaceSearchText.constant = keyboardFrameBeginRect.size.height +self.bottomSpaceSearchText.constant ;
        }
        if (self.bottomConstraintTextInput.constant == 61) {
            self.bottomConstraintTextInput.constant = self.bottomConstraintTextInput.constant + keyboardFrameBeginRect.size.height;
        }
        if (self.bottomConstraintSearchEnglish.constant == 0) {
            self.bottomConstraintSearchEnglish.constant = self.bottomConstraintSearchEnglish.constant + keyboardFrameBeginRect.size.height;
        }
        if (stack.center.y == self.view.frame.size.height - 50) {
            [stack setCenter:CGPointMake(stack.center.x, stack.center.y - keyboardFrameBeginRect.size.height)];
        }
        self.topConstraintScrollText.constant = 0.f;
        self.topConstraintTextViewInput.constant = 0.f;
        self.banerView.hidden = YES;
        self.topConstraintButtonSwitch.constant = - (self.banerView.frame.size.height - 9);

    }];
}
-(void)hiddenKeyBoard:(UISwipeGestureRecognizer*)sender
{
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [stack closeStack];
    [KxMenu dismissMenu];
    
}
- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    NSDictionary* keyboardInfo = [notif userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

    [UIView animateWithDuration:0.1 animations:^{
        self.bottomSpaceSearchText.constant = self.bottomSpaceSearchText.constant - keyboardFrameBeginRect.size.height;
        self.bottomConstraintTextInput.constant = self.bottomConstraintTextInput.constant -keyboardFrameBeginRect.size.height;
        self.bottomConstraintSearchEnglish.constant = 0.0f;
        [stack setCenter:CGPointMake(stack.center.x, stack.center.y+keyboardFrameBeginRect.size.height)];
        self.topConstraintScrollText.constant = self.banerView.frame.size.height;
        self.topConstraintTextViewInput.constant = self.banerView.frame.size.height;
        self.banerView.hidden = NO;
        self.topConstraintButtonSwitch.constant = 9.0f;
    }];
    
    
}

#pragma mark - handle view of viewcontroller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.fontSizeBuffer = [RDConstant sharedRDConstant].fontSizeView;
    self.textViewInput.text = @"Input text to search phonetic";
    self.textViewInput.textColor = [UIColor lightGrayColor]; //optional
    //setup swip left and right
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showWordView:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPhoenticView:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.textViewInput addGestureRecognizer:swipLeft];
    [self.scrollText addGestureRecognizer:swipRight];

    UISwipeGestureRecognizer *swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
    swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipDown];
    self.view.userInteractionEnabled = YES;
    //setup gogle Admod
    // Replace this ad unit ID with your own ad unit ID.
    self.banerView.adUnitID = @"ca-app-pub-6290218846561932/6053256005";
    self.banerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    request.testDevices = @[
                            @"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
                            ];
    [self.banerView loadRequest:request];

    // Do any additional setup after loading the view.
    self.textViewInput.font = [UIFont fontWithName:[UtilsXML utilXMLInstance].fontNames[0] size:[RDConstant sharedRDConstant].fontSizeView];
    self.textViewInput.delegate = self;
    self.textViewInput.userInteractionEnabled = YES;
    self.scrollText.hidden= YES;
    isShowPhonetic = NO;
    isLoadPhonetic = NO;
    self.searchText.delegate = self;
    //rgb(189, 195, 199)
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLaunchAppWithUserInfor:)
                                                 name:@"UIApplicationLaunchOptionsURL"
                                               object:nil];

    //setting content stack
//    rgb(127, 140, 141)
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle-add"]];
//    [contentView setBackgroundColor:[UIColor colorWithRed:127/255. green:140/255. blue:141/255. alpha:1.]];
    [contentView setBackgroundColor:[UIColor clearColor]];

    [contentView.layer setCornerRadius:30];
    [icon setContentMode:UIViewContentModeScaleToFill];
    [icon setFrame:CGRectInset(contentView.frame, 0, 0)];
    [contentView addSubview:icon];
    [self setupStackMenu:0];
    
//    [[UITextView appearance] setTintColor:[UIColor blackColor]];
//    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    self.banerView.hidden = YES;
    self.topConstraintButtonSwitch.constant = - (self.banerView.frame.size.height -9);
    //
    // Create a queue to perform recognition operations
    self.operationQueue = [[NSOperationQueue alloc] init];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
//    rgb(236, 240, 241)
//    rgb(44, 62, 80)
    [self.view setBackgroundColor:[UIColor colorWithRed:236 green:240 blue:241 alpha:0.1]];
//    self.textViewInput.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    self.searchText.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handle event of viewcontroller
- (IBAction)didPressOnPrint:(id)sender {
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    if (self.scrollText.isHidden) {
        if (![self.textViewInput.text isEqualToString:@""]) {
            
            [self didPressOnPhonetic:nil];
        }
        return ;
    }
    [self showMenuForSettingPrinter];
}
- (IBAction)didPressOnReading:(id)sender {
    [stack closeStack];
    [KxMenu dismissMenu];

    if (isPlayAudio) {
        [self didPressOffReading:sender];
        return;
    }
    isPlayAudio = YES;
    [speaker_on changeImageItem:[UIImage imageNamed:@"audio_on_off"]];
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    
    synthesizer = [[AVSpeechSynthesizer alloc]init];
    utterance = [AVSpeechUtterance speechUtteranceWithString:self.textViewInput.text];
    synthesizer.delegate = self;
//    aus
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[UtilsXML utilXMLInstance].langCodes[[RDConstant sharedRDConstant].langCode]];
    [utterance setRate:0.4f];
    [synthesizer speakUtterance:utterance];
    
}
- (IBAction)didPressOffReading:(id)sender {
    [stack closeStack];
    [KxMenu dismissMenu];

    [speaker_on changeImageItem:[UIImage imageNamed:@"audio_play"]];
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    isPlayAudio = NO;
}

- (IBAction)didPressOnPhonetic:(id)sender {
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [stack closeStack];
    [KxMenu dismissMenu];
    if ([self.textViewInput.text isEqualToString:@""]) {
        [self.textViewInput becomeFirstResponder];
        return;
    }
    if (isShowPhonetic) {
        self.textViewInput.hidden = NO;
        self.scrollText.hidden = YES;
        isShowPhonetic = NO;
        [self.buttonPhonetic setBackgroundImage:[UIImage imageNamed:@"Phonetic"] forState:UIControlStateNormal];
    }else
    {
        if (![self.textViewInput.text isEqualToString:self.textBuffer] || [RDConstant sharedRDConstant].fontSizeView !=self.fontSizeBuffer) {
            [self setupPhoneticWordForText:self.textViewInput.text];
        }else
        {
            self.textViewInput.hidden = YES;
            self.scrollText.hidden = NO;
            isShowPhonetic = YES;
            [self.buttonPhonetic setBackgroundImage:[UIImage imageNamed:@"EditText"] forState:UIControlStateNormal];

        }
        
    }
    [self.view bringSubviewToFront:self.btPhoneticWord];
    
}
 - (IBAction)didPressOnExportFile:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        // Available
        [self.scrollText imageWithView:self.scrollText withFrame:CGRectMake(0, 0, 1101, 1654) withCompleteBlock:^(NSArray *arrPaper) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.documentController =
                [UIDocumentInteractionController
                 interactionControllerWithURL:[NSURL fileURLWithPath:[[UtilsXML utilXMLInstance] drawImagesToPdf:arrPaper]]];
                self.documentController.delegate = self;
                self.documentController.UTI = @"com.adobe.pdf";
                [self.documentController presentOpenInMenuFromRect:CGRectZero
                                                       inView:self.view
                                                     animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
        }];
    });

}

- (IBAction)didPressOnSave:(id)sender
{
    [stack closeStack];
    [KxMenu dismissMenu];
    [self openCamera:nil];

}
- (IBAction)didPressOnSearch:(id)sender {
    [stack closeStack];
    [KxMenu dismissMenu];

}
- (IBAction)didPressOnSetting:(id)sender
{
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [self showMenuForSetting];
}

#pragma mark - handle stactk menu of viewcontroller
- (void)setupStackMenu:(NSInteger)index
{
    if(stack)
        [stack removeFromSuperview];
    
    stack = [[UPStackMenu alloc] initWithContentView:contentView];
    [stack setCenter:CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50)];
    [stack setDelegate:self];
    
//    UPStackMenuItem *getPhonetic = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"Switch"] highlightedImage:nil title:@""];
    speaker_on = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"audio_play"] highlightedImage:nil title:@""];
    print = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"paper_printer"] highlightedImage:nil title:@""];
    settingItem = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"settings"] highlightedImage:nil title:@""];
    save = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"take-picture"] highlightedImage:nil title:@""];
    exportFile = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"Export_File"] highlightedImage:nil title:@""];

    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:speaker_on, print,settingItem,save,exportFile, nil];
    [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitleColor:[UIColor blackColor]];
    }];
    
    switch (index) {
        case 0:
            [stack setAnimationType:UPStackMenuAnimationType_progressive];
            [stack setStackPosition:UPStackMenuStackPosition_up];
            [stack setOpenAnimationDuration:.4];
            [stack setCloseAnimationDuration:.4];
            [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                [item setLabelPosition:UPStackMenuItemLabelPosition_right];
                [item setLabelPosition:UPStackMenuItemLabelPosition_left];
            }];
            break;
            
        case 1:
            [stack setAnimationType:UPStackMenuAnimationType_linear];
            [stack setStackPosition:UPStackMenuStackPosition_down];
            [stack setOpenAnimationDuration:.3];
            [stack setCloseAnimationDuration:.3];
            [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                [item setLabelPosition:UPStackMenuItemLabelPosition_right];
            }];
            break;
            
        case 2:
            [stack setAnimationType:UPStackMenuAnimationType_progressiveInverse];
            [stack setStackPosition:UPStackMenuStackPosition_up];
            [stack setOpenAnimationDuration:.4];
            [stack setCloseAnimationDuration:.4];
            [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                if(idx%2 == 0)
                    [item setLabelPosition:UPStackMenuItemLabelPosition_left];
                else
                    [item setLabelPosition:UPStackMenuItemLabelPosition_right];
            }];
            break;
            
        default:
            break;
    }
    
    [stack addItems:items];
    [self.view addSubview:stack];
    
    [self setStackIconClosed:YES];
}
- (void)showMenu:(UIButton *)sender
{
}

- (void)pushMenuItemSetting:(id)sender
{
    KxMenuItem *menu= (KxMenuItem*)sender;
    [RDConstant sharedRDConstant].fontSizeView = menu.fontSize;
    self.textViewInput.font = [UIFont systemFontOfSize:menu.fontSize];
    self.textViewInput.hidden = NO;
    if (!self.scrollText.isHidden) {
        [self setupPhoneticWordForText:self.textViewInput.text];
    }

}
- (void)pushMenuItemSettingLanguageCodes:(id)sender
{
    KxMenuItem *menu= (KxMenuItem*)sender;
    [RDConstant sharedRDConstant].langCode = menu.languagecode;
}

- (void)pushMenuItemPrinterSelect:(id)sender
{
    KxMenuItem *menu= (KxMenuItem*)sender;
    switch (menu.typePrint) {
        case MENU_TYPE_AIRPRINT:
            [self openAirtPrint];
            break;
        case MENU_TYPE_CANONPRINT:
            [self openCannonPrintScreen];

            break;

        default:
            break;
    }
}

- (void)setStackIconClosed:(BOOL)closed
{
    UIImageView *icon = [[contentView subviews] objectAtIndex:0];
    float angle = closed ? 0 : (M_PI * (135) / 180.0);
    [UIView animateWithDuration:0.3 animations:^{
        [icon.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
    }];
}

#pragma mark - UPStackMenuDelegate

- (void)stackMenuWillOpen:(UPStackMenu *)menu
{
    [KxMenu dismissMenu];
    if([[contentView subviews] count] == 0)
        return;
    
    [self setStackIconClosed:NO];
}
- (void)stackMenuDidOpen:(UPStackMenu*)menu
{
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];

}
- (void)stackMenuWillClose:(UPStackMenu *)menu
{
    if([[contentView subviews] count] == 0)
        return;
    
    [self setStackIconClosed:YES];
}
- (void)stackMenu:(UPStackMenu *)menu didTouchItem:(UPStackMenuItem *)item atIndex:(NSUInteger)index
{
    [stack closeStack];
    switch (index) {
//        case 0:
//            [self didPressOnPhonetic:nil];
//            break;
//        case 0:
//            [self didPressOnReading:nil];
//            break;
        case 0:
            [self didPressOnReading:nil];
            break;
        case 1:
            [self didPressOnPrint:nil];;
            break;
        case 2:
            [self didPressOnSetting:nil];;
            break;
        case 3:
            [self didPressOnSave:nil];;
            break;
        case 4:
           [self didPressOnExportFile:nil];;
            break;

        default:
            break;
    }
}


#pragma mark - handle Text View of viewcontroller
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Input text to search phonetic"]) {
        textView.text = @"";
        self.textViewInput.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Input text to search phonetic";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.searchText resignFirstResponder];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL isEnableEditing = YES;
    if (stack.isOpen) {
        isEnableEditing = NO;
    }
    return isEnableEditing;

}


#pragma mark - handle Text Seacrch of viewcontroller
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL isEnableEditing = YES;
    if (stack.isOpen) {
        isEnableEditing = NO;
    }
    return isEnableEditing;
}
// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [stack closeStack];
    [KxMenu dismissMenu];
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [stack closeStack];
    NSString *stringWord = nil;
    if (self.isClearText) {
        stringWord =[[textField.text stringByReplacingOccurrencesOfString:textField.text withString:string] stringByReplacingOccurrencesOfString:@" " withString:@""];

    }else
    {
        stringWord =[[NSString stringWithFormat:@"%@%@",textField.text,string] stringByReplacingOccurrencesOfString:@" " withString:@""];

    }
    NSString *detailShow = [[EdictDatabase database] getEdictInfosWithWord:stringWord];
    [self showMenuSearchText:detailShow withAudioText:stringWord];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.isClearText = YES;
    return YES;

}
- (void)showMenuSearchText:(NSString *)htmlString withAudioText:(NSString*)audioText;
{
    NSArray *menuItems =
    @[
      
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
    if (self.view.frame.size.height > 736) {
        menuItems =
        @[
          
          [KxMenuItem menuItem:@"ACTION MENU 1234456 1234456 1234456"
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
          [KxMenuItem menuItem:@"ACTION MENU 1234456"
                         image:nil
                        target:nil
                        action:NULL]
          
          ];
        
    }
    if (self.view.frame.size.height <586) {
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
    [KxMenu sharedMenu].htmlString = htmlString;
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_DETAIL_DICTIONARY;
    [KxMenu sharedMenu].textAudio = audioText;
    if (self.textViewInput.hidden) {
        [KxMenu showMenuInView:self.scrollText
                      fromRect:CGRectMake(self.searchText.frame.origin.x, self.searchText.frame.origin.y - 20, 62, 62)
                     menuItems:menuItems];

    }else
    [KxMenu showMenuInView:self.textViewInput
                  fromRect:CGRectMake(self.searchText.frame.origin.x, self.searchText.frame.origin.y - 20, 62, 62)
                 menuItems:menuItems];
}
- (void)showMenuForSetting
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Choose font size for view"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"font size 14"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItemSetting:)],
      
      [KxMenuItem menuItem:@"font size 15"
                     image:nil
                    target:self
                    action:@selector(pushMenuItemSetting:)],
      
      [KxMenuItem menuItem:@"font size 16"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItemSetting:)],
      
      [KxMenuItem menuItem:@"font size 17"
                     image:[UIImage imageNamed:@"search_icon"]
                    target:self
                    action:@selector(pushMenuItemSetting:)],
      
      [KxMenuItem menuItem:@"font size 18"
                     image:[UIImage imageNamed:@"home_icon"]
                    target:self
                    action:@selector(pushMenuItemSetting:)],
      [KxMenuItem menuItem:@"Choose Language type specker"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"English (Australia)"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItemSettingLanguageCodes:)],
      
      [KxMenuItem menuItem:@"English (Ireland)"
                     image:nil
                    target:self
                    action:@selector(pushMenuItemSettingLanguageCodes:)],
      
      [KxMenuItem menuItem:@"English (South Africa)"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItemSettingLanguageCodes:)],
      
      [KxMenuItem menuItem:@"English (United Kingdom)"
                     image:[UIImage imageNamed:@"search_icon"]
                    target:self
                    action:@selector(pushMenuItemSettingLanguageCodes:)],
      
      [KxMenuItem menuItem:@"English (United States)"
                     image:[UIImage imageNamed:@"home_icon"]
                    target:self
                    action:@selector(pushMenuItemSettingLanguageCodes:)]

      ];
    
    KxMenuItem *first = menuItems[0];
    first.fontSize = 15;
    KxMenuItem *two = menuItems[1];
    two.fontSize = 14;
    KxMenuItem *three = menuItems[2];
    three.fontSize = 15;
    KxMenuItem *four = menuItems[3];
    four.fontSize = 16;
    KxMenuItem *five = menuItems[4];
    five.fontSize = 17;
    KxMenuItem *six = menuItems[5];
    six.fontSize = 18;
    KxMenuItem *seven = menuItems[6];
    seven.fontSize = 15;
    KxMenuItem *eight = menuItems[7];
    eight.languagecode = 0;
    eight.fontSize = 15;
    KxMenuItem *neight = menuItems[8];
    neight.languagecode = 1;
    neight.fontSize = 15;
    KxMenuItem *ten = menuItems[9];
    ten.languagecode = 2;
    ten.fontSize = 15;
    KxMenuItem *menu1 = menuItems[10];
    menu1.fontSize = 15;
    menu1.languagecode = 3;
    KxMenuItem *menu2 = menuItems[11];
    menu2.languagecode = 4;
    menu2.fontSize = 15;

    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentLeft;
    seven.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    seven.alignment = NSTextAlignmentLeft;

    [KxMenu sharedMenu].htmlString = nil;
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_MENU;
    [KxMenu sharedMenu].textAudio = nil;
    [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake(stack.center.x, self.searchText.frame.origin.y, stack.frame.size.width, stack.frame.size.height)
                     menuItems:menuItems];
}
- (void)showMenuForSettingPrinter
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Choose Printer"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"Print with AirPrint"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItemPrinterSelect:)],
      
      [KxMenuItem menuItem:@"Print with Canon"
                     image:nil
                    target:self
                    action:@selector(pushMenuItemPrinterSelect:)],
      
      
      ];
    
    KxMenuItem *first = menuItems[0];
    first.fontSize = 15;
    KxMenuItem *two = menuItems[1];
    two.fontSize = 14;
    two.typePrint = MENU_TYPE_AIRPRINT;
    KxMenuItem *three = menuItems[2];
    three.fontSize = 15;
    three.typePrint = MENU_TYPE_CANONPRINT;

    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentLeft;
    
        [KxMenu sharedMenu].htmlString = nil;
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_MENU;
    [KxMenu sharedMenu].textAudio = nil;
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(stack.center.x, self.searchText.frame.origin.y, stack.frame.size.width, stack.frame.size.height)
                 menuItems:menuItems];
}

#pragma mark - handle Func Common of viewcontroller
-(void)setupPhoneticWordForText:(NSString*)text
{
    for (UILabel *lable in self.scrollText.subviews) {
        [lable removeFromSuperview];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        NSMutableArray *arrWord  = [NSMutableArray array];
        NSArray *arrBreakLine = [text componentsSeparatedByString:@"\n"];
        for (NSString *str in arrBreakLine) {
//            NSString *strRemove = [str removeSpecifiCharacter];
            [arrWord addObjectsFromArray:[str componentsSeparatedByString:@" "]];
            [arrWord addObject:@"\n"];
        }
        NSArray *arrPhonetic = [[EdictDatabase database] getEdictInfosWithArrWord:arrWord];
        isLoadPhonetic = YES;
        self.scrollText.fontName = [[UtilsXML alloc] init].fontNames[0];
        self.scrollText.fontSize = 18;
        self.scrollText.arrWord = arrWord;
        self.scrollText.arrPhonetic = arrPhonetic;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollText setupEdictTextViewWithFrame:self.scrollText.frame];
        });
        isShowPhonetic = YES;
        self.banerView.hidden = NO;
        self.topConstraintButtonSwitch.constant = 9.0f;
        self.topConstraintScrollText.constant = self.banerView.frame.size.height;
        self.topConstraintTextViewInput.constant = self.banerView.frame.size.height;

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.textViewInput.hidden = YES;
            self.scrollText.hidden = NO;
            self.textBuffer = text;
            self.fontSizeBuffer = [RDConstant sharedRDConstant].fontSizeView;
            [self.buttonPhonetic setBackgroundImage:[UIImage imageNamed:@"EditText"] forState:UIControlStateNormal];

        });
    });
    
    
}
-(void)showWordView:(UIGestureRecognizer*)ges
{
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [self didPressOnPhonetic:nil];
}
-(void)showPhoenticView:(UIGestureRecognizer*)ges
{
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [self didPressOnPhonetic:nil];

}
-(void)didLaunchAppWithUserInfor:(NSNotification*)userInfor
{
    NSString *str = [NSString stringWithContentsOfURL:(NSURL*)userInfor.object encoding:NSUTF8StringEncoding error:nil];
    //this is not the way to display this on the screen
    if (str) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textViewInput.text = nil;
            self.textViewInput.text = str;
            self.textViewInput.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
            if (isShowPhonetic) {
                self.textViewInput.hidden = NO;
                self.scrollText.hidden = YES;
                [self.buttonPhonetic setBackgroundImage:[UIImage imageNamed:@"Phonetic"] forState:UIControlStateNormal];
                isShowPhonetic = NO;
            }
        });

    }else
    {
        UIImage *img =[UIImage imageWithContentsOfFile:[(NSURL*)userInfor.object absoluteString]];
        
        if (!img) {
            NSData *dataimg2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:[(NSURL*)userInfor.object absoluteString]]];
            img = [UIImage imageWithData:dataimg2];
        }

        if (img) {
            [self recognizeImageWithTesseract:img WithData:nil];

        }
//        else
//        {
////            NSString *PDFPath = [[NSBundle mainBundle] pathForResource:[(NSURL*)userInfor.object absoluteString] ofType:@"pdf"];
////            NSData *dataimg2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:[(NSURL*)userInfor.object absoluteString]]];
//
//        }

    }

}
#pragma mark - handle Func OCR of viewcontroller

-(void)recognizeImageWithTesseract:(UIImage *)image WithData:(NSData*)pdfData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    // Use the original Tesseract engine mode in performing the recognition
    // (see G8Constants.h) for other engine mode options
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    // Let Tesseract automatically segment the page into blocks of text
    // based on its analysis (see G8Constants.h) for other page segmentation
    // mode options
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    // Optionally limit the time Tesseract should spend performing the
    // recognition
    //operation.tesseract.maximumRecognitionTime = 1.0;
    
    // Set the delegate for the recognition to be this class
    // (see `progressImageRecognitionForTesseract` and
    // `shouldCancelImageRecognitionForTesseract` methods below)
    operation.delegate = self;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    operation.tesseract.image = image;
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *recognizedText = tesseract.recognizedText;
        if (recognizedText) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textViewInput.text = nil;
                self.textViewInput.text = recognizedText;
                if (isShowPhonetic) {
                    self.textViewInput.hidden = NO;
                    self.scrollText.hidden = YES;
                    [self.buttonPhonetic setBackgroundImage:[UIImage imageNamed:@"Phonetic"] forState:UIControlStateNormal];
                    isShowPhonetic = NO;
                }
            });
        }
        
    };
    
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];

}
/**
 *  This function is part of Tesseract's delegate. It will be called
 *  periodically as the recognition happens so you can observe the progress.
 *
 *  @param tesseract The `G8Tesseract` object performing the recognition.
 */
- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

/**
 *  This function is part of Tesseract's delegate. It will be called
 *  periodically as the recognition happens so you can cancel the recogntion
 *  prematurely if necessary.
 *
 *  @param tesseract The `G8Tesseract` object performing the recognition.
 *
 *  @return Whether or not to cancel the recognition.
 */
- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to cancel recognition prematurely
}

- (IBAction)openCamera:(id)sender
{
    UIImagePickerController *imgPicker = [UIImagePickerController new];
    imgPicker.delegate = self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
}

- (IBAction)recognizeSampleImage:(id)sender {
}

- (IBAction)clearCache:(id)sender
{
    [G8Tesseract clearCache];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self recognizeImageWithTesseract:image WithData:nil];
}
#pragma mark - handle audio speak text

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [speaker_on changeImageItem:[UIImage imageNamed:@"audio_play"]];
    isPlayAudio = NO;

}
#pragma mark - handle canon print app

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)createCanonDataAndOpenApp
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        // Available
        [self.scrollText imageWithView:self.scrollText withFrame:CGRectMake(0, 0, 1101, 1654) withCompleteBlock:^(NSArray *arrPaper) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *pdfURL = [NSURL URLWithString:@"canonij1pdf://"];
                NSString *pt = @"pdfToCPIS";
                /*Creating a Data Object*/
                
                NSData *data = [NSData dataWithContentsOfFile:[[UtilsXML utilXMLInstance] drawImagesToPdf:arrPaper]];
                
                /* Getting the generalPasteboard */
                UIPasteboard *pb = [UIPasteboard generalPasteboard];
                /* Setting NSData Object of PDF */
                [pb setData:data forPasteboardType:pt];
                
                [[UIApplication sharedApplication] openURL:pdfURL];
                //    [self closeHudInView:self.view];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            });
            
        }];
    });

}

- (void)openCannonApp {
//    [self openLoadingHudInView:self.view text:TEXT_PROCESSING];
    [self performSelector:@selector(createCanonDataAndOpenApp) withObject:nil afterDelay:1.0f];
}

- (void)openCannonPrintScreen {
    NSURL *photoURL = [NSURL URLWithString:@"canonij1pdf://"];
    if ([[UIApplication sharedApplication] canOpenURL:photoURL] == YES) {
        /* Launch CPIS by Using URL Scheme if the Latest Version of
         CPIS is Installed. */
        if (U_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@""
                                        message:@"TEXT_PRINT_OPEN_CANON_APP_ADDRESS"
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"TEXT_BUTTON_CANCEL"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [alert
             addAction:[UIAlertAction
                        actionWithTitle:@"TEXT_PRINT_OPEN_CANON_APP_CONFIRMATION"
                        style:UIAlertActionStyleDestructive
                        handler:^(UIAlertAction *_Nonnull action) {
                            [self openCannonApp];
                        }]];
            [self presentViewController:alert animated:NO completion:nil];
        } else {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
            [[[UIAlertView alloc]
              initWithTitle:@""
              message:@"TEXT_PRINT_OPEN_CANON_APP_ADDRESS"
              delegate:(id<UIAlertViewDelegate>)self
              cancelButtonTitle:@"TEXT_BUTTON_CANCEL"
              otherButtonTitles:@"TEXT_PRINT_OPEN_CANON_APP_CONFIRMATION", nil] show];
#pragma clang diagnostic pop
        }
    } else {
        /* Encourage Users to Install CPIS if CPIS is not Installed.
         */
        NSString *message = @"TEXT_PRINT_CANNON_APP_APPSTORE_INSTALL_HELP";
        NSString *titleAlert = @"TEXT_PRINT_CANNON_APP_NOT_INSTALLED";
        NSString *cancelButtonAlert = @"TEXT_BUTTON_CANCEL";
        NSString *acceptButtonAlert = @"TEXT_BUTTON_OK";
        
        if (U_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:titleAlert
                                        message:message
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:cancelButtonAlert
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [alert addAction:[UIAlertAction
                              actionWithTitle:acceptButtonAlert
                              style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *_Nonnull action) {
                                  [self openAppstoreForCannon];
                              }]];
            [self presentViewController:alert animated:NO completion:nil];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
            [[[UIAlertView alloc] initWithTitle:titleAlert
                                        message:message
                                       delegate:(id<UIAlertViewDelegate>)self
                              cancelButtonTitle:cancelButtonAlert
                              otherButtonTitles:acceptButtonAlert, nil] show];
#pragma clang diagnostic pop
        }
    }
}

- (void)alertView:(UIAlertView *)alertView
willDismissWithButtonIndex:(NSInteger)buttonIndex
NS_DEPRECATED_IOS(2_0, 9_0) {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([alertView.title isEqualToString:@"TEXT_PRINT_CANNON_APP_NOT_INSTALLED"]) {
            [self openAppstoreForCannon];
        } else if ([alertView.message
                    isEqualToString:@"TEXT_PRINT_OPEN_CANON_APP_ADDRESS"]) {
            [self openCannonApp];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
}

- (void)openAppstoreForCannon {
    NSString *iTunesLink = TEXT_APPSTORE_CANNON_APP_LINK;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}
-(void)openAirtPrint
{
    if ([UIPrintInteractionController isPrintingAvailable])
    {
        
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        // Available
        [self.scrollText imageWithView:self.scrollText withFrame:CGRectMake(0, 0, 598, 842) withCompleteBlock:^(NSArray *arrPaper) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
                pic.delegate = self;
                UIPrintInfo *printInfo = [UIPrintInfo printInfo];
                printInfo.outputType = UIPrintInfoOutputGeneral;
                printInfo.jobName = @"Print";
                printInfo.duplex = UIPrintInfoDuplexLongEdge;
                pic.printInfo = printInfo;
                pic.printingItems = arrPaper;
                if ([FDDeviceHardware deviceFamily]==UIDeviceFamilyiPhone) {
                    [pic presentAnimated:YES completionHandler:^(UIPrintInteractionController * _Nonnull printInteractionController, BOOL completed, NSError * _Nullable error) {
                        if (completed) {
                        }
                    }];
                    
                }else
                {
                    [pic presentFromRect:CGRectMake(stack.center.x , stack.center.y, 64, 64) inView:self.view animated:YES completionHandler:^(UIPrintInteractionController * _Nonnull printInteractionController, BOOL completed, NSError * _Nullable error) {
                        if (completed) {
                        }
                    }];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            });
            
        }];
    });
    } else {
        // Not Available
    }
    
}
@end
