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
#import "EDictLabel.h"
#import "PhoneticLabel.h"
@import GoogleMobileAds;
static NSString * BCP47LanguageCodeFromISO681LanguageCode(NSString *ISO681LanguageCode) {
    if ([ISO681LanguageCode isEqualToString:@"ar"]) {
        return @"ar-SA";
    } else if ([ISO681LanguageCode hasPrefix:@"cs"]) {
        return @"cs-CZ";
    } else if ([ISO681LanguageCode hasPrefix:@"da"]) {
        return @"da-DK";
    } else if ([ISO681LanguageCode hasPrefix:@"de"]) {
        return @"de-DE";
    } else if ([ISO681LanguageCode hasPrefix:@"el"]) {
        return @"el-GR";
    } else if ([ISO681LanguageCode hasPrefix:@"en"]) {
        return @"en-US"; // en-AU, en-GB, en-IE, en-ZA
    } else if ([ISO681LanguageCode hasPrefix:@"es"]) {
        return @"es-ES"; // es-MX
    } else if ([ISO681LanguageCode hasPrefix:@"fi"]) {
        return @"fi-FI";
    } else if ([ISO681LanguageCode hasPrefix:@"fr"]) {
        return @"fr-FR"; // fr-CA
    } else if ([ISO681LanguageCode hasPrefix:@"hi"]) {
        return @"hi-IN";
    } else if ([ISO681LanguageCode hasPrefix:@"hu"]) {
        return @"hu-HU";
    } else if ([ISO681LanguageCode hasPrefix:@"id"]) {
        return @"id-ID";
    } else if ([ISO681LanguageCode hasPrefix:@"it"]) {
        return @"it-IT";
    } else if ([ISO681LanguageCode hasPrefix:@"ja"]) {
        return @"ja-JP";
    } else if ([ISO681LanguageCode hasPrefix:@"ko"]) {
        return @"ko-KR";
    } else if ([ISO681LanguageCode hasPrefix:@"nl"]) {
        return @"nl-NL"; // nl-BE
    } else if ([ISO681LanguageCode hasPrefix:@"no"]) {
        return @"no-NO";
    } else if ([ISO681LanguageCode hasPrefix:@"pl"]) {
        return @"pl-PL";
    } else if ([ISO681LanguageCode hasPrefix:@"pt"]) {
        return @"pt-BR"; // pt-PT
    } else if ([ISO681LanguageCode hasPrefix:@"ro"]) {
        return @"ro-RO";
    } else if ([ISO681LanguageCode hasPrefix:@"ru"]) {
        return @"ru-RU";
    } else if ([ISO681LanguageCode hasPrefix:@"sk"]) {
        return @"sk-SK";
    } else if ([ISO681LanguageCode hasPrefix:@"sv"]) {
        return @"sv-SE";
    } else if ([ISO681LanguageCode hasPrefix:@"th"]) {
        return @"th-TH";
    } else if ([ISO681LanguageCode hasPrefix:@"tr"]) {
        return @"tr-TR";
    } else if ([ISO681LanguageCode hasPrefix:@"zh"]) {
        return @"zh-CN"; // zh-HK, zh-TW
    } else {
        return nil;
    }
}
static NSString * BCP47LanguageCodeForString(NSString *string) {
    NSString *ISO681LanguageCode = (__bridge NSString *)CFStringTokenizerCopyBestStringLanguage((__bridge CFStringRef)string, CFRangeMake(0, [string length]));
    return BCP47LanguageCodeFromISO681LanguageCode(ISO681LanguageCode);
}

#define debug 1

@interface EdictViewController ()<UIPrintInteractionControllerDelegate,UITextFieldDelegate,UPStackMenuDelegate,UIScrollViewDelegate,AVSpeechSynthesizerDelegate,UIDocumentInteractionControllerDelegate,UIAlertViewDelegate>
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
    NSTimer *timer;
    NSInteger tagPre ;
    NSInteger tagCurrent;
    __weak IBOutlet NSLayoutConstraint *constantHeightBanerView;
    __weak IBOutlet NSLayoutConstraint *constantHeightEnglishDictionary;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantHeigtButtonPhonetic;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantWidthButtonPhonetic;
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
        if (self.bottomSpaceSearchText.constant == roundf(61 * (self.view.frame.size.height/736))) {
            self.bottomSpaceSearchText.constant = keyboardFrameBeginRect.size.height +self.bottomSpaceSearchText.constant ;
        }
        if (self.bottomConstraintTextInput.constant == roundf(61 * (self.view.frame.size.height/736))) {
            self.bottomConstraintTextInput.constant = self.bottomConstraintTextInput.constant + keyboardFrameBeginRect.size.height;
        }
        if (self.bottomConstraintSearchEnglish.constant == 0) {
            self.bottomConstraintSearchEnglish.constant = self.bottomConstraintSearchEnglish.constant + keyboardFrameBeginRect.size.height;
        }
        if (stack.center.y == self.view.frame.size.height - roundf(50 * (self.view.frame.size.height/736))) {
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
    [stack closeStack];
    [KxMenu dismissMenu];
    // Do something here
    NSDictionary* keyboardInfo = [notif userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.searchText.text = @"";
    [UIView animateWithDuration:0.1 animations:^{
        self.bottomSpaceSearchText.constant = self.bottomSpaceSearchText.constant - keyboardFrameBeginRect.size.height;
        self.bottomConstraintTextInput.constant = self.bottomConstraintTextInput.constant -keyboardFrameBeginRect.size.height;
        self.bottomConstraintSearchEnglish.constant = 0.0f;
        if (stack.center.y+keyboardFrameBeginRect.size.height <= self.view.frame.size.height - roundf(50 * (self.view.frame.size.height/736))) {
            [stack setCenter:CGPointMake(stack.center.x, stack.center.y+keyboardFrameBeginRect.size.height)];
        }
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
    self.textViewInput.text = @"Input English To Show Phonetic";
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
    self.scrollText.delegate = self;
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
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, roundf(64 * (self.view.frame.size.height/736)), roundf(64 * (self.view.frame.size.height/736)))];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle-add"]];
//    [contentView setBackgroundColor:[UIColor colorWithRed:127/255. green:140/255. blue:141/255. alpha:1.]];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView.layer setCornerRadius:roundf(30 * (self.view.frame.size.height/736))];
    [icon setContentMode:UIViewContentModeScaleToFill];
    [icon setFrame:CGRectInset(contentView.frame, 0, 0)];
    [contentView addSubview:icon];
    [self setupStackMenu:0];
    
//    [[UITextView appearance] setTintColor:[UIColor blackColor]];
//    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    self.banerView.hidden = YES;
    //
    // Create a queue to perform recognition operations
    self.operationQueue = [[NSOperationQueue alloc] init];
    constantHeightEnglishDictionary.constant = roundf(62 * (self.view.frame.size.height/736));
    
    self.constantHeigtButtonPhonetic.constant = roundf(self.constantHeigtButtonPhonetic.constant * (self.view.frame.size.height/736));
    self.constantWidthButtonPhonetic.constant = roundf(self.constantWidthButtonPhonetic.constant * (self.view.frame.size.height/736));
    
    self.bottomSpaceSearchText.constant = roundf(self.bottomSpaceSearchText.constant * (self.view.frame.size.height/736));
    self.bottomConstraintTextInput.constant = roundf(self.bottomConstraintTextInput.constant * (self.view.frame.size.height/736));

    self.searchText.font =[UIFont systemFontOfSize:roundf(18 * (([UIScreen screens][0].bounds.size.height)/736))] ;
    constantHeightBanerView.constant = roundf(constantHeightBanerView.constant * (self.view.frame.size.height/736));
    self.topConstraintButtonSwitch.constant = - (constantHeightBanerView.constant -9);
//    [self addStoryView];
    
    tagPre = -1;
    tagCurrent = -1;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.textViewInput.backgroundColor = [UIColor whiteColor];
    self.scrollText.backgroundColor = [UIColor whiteColor];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    rgb(236, 240, 241)
//    rgb(44, 62, 80)
//    [self.view setBackgroundColor:[UIColor colorWithRed:236 green:240 blue:241 alpha:0.1]];
//    self.textViewInput.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    self.searchText.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    [self.buttonPhonetic updateConstraints];
    [self.view updateConstraints];
//    [self showMenuListAllStory];
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

    utterance = [AVSpeechUtterance speechUtteranceWithString:self.textReading];
    synthesizer.delegate = self;
//    aus
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        // code here
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:BCP47LanguageCodeForString(utterance.speechString)];

    }else
    {
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[UtilsXML utilXMLInstance].langCodes[[RDConstant sharedRDConstant].langCode]];
    }

    [utterance setRate:0.3f];
    utterance.preUtteranceDelay = 0.2f;
    utterance.postUtteranceDelay = 0.2f;

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
    if ([self.textViewInput.text isEqualToString:@"Input English To Show Phonetic"]) {
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
    [self showMenuForSettingStory];
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
    [stack setCenter:CGPointMake(self.view.frame.size.width - roundf(50 * (self.view.frame.size.height/736)), self.view.frame.size.height - roundf(50 * (self.view.frame.size.height/736)))];
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
- (void)pushMenuItemGroupSelect:(id)sender{
    KxMenuItem *menu= (KxMenuItem*)sender;
    switch (menu.typeStory) {
        case STORY_TYPE_CREATE_NEW:
            [self createNewStory];
            break;
        case STORY_TYPE_LIST_ALL_STORY:
            [self showMenuListAllStory];
            break;
        case STORY_TYPE_SAVE_ALL_STORY:
            [self showMenuListAllGroup];
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
            [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
            isPlayAudio = NO;

            break;
        case 2:
            [self didPressOnSetting:nil];
            [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
            isPlayAudio = NO;

            break;
        case 3:
            [self didPressOnSave:nil];
            [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
            isPlayAudio = NO;

            break;
        case 4:
           [self didPressOnExportFile:nil];
            [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
            isPlayAudio = NO;
            break;

        default:
            break;
    }
}


#pragma mark - handle Text View of viewcontroller
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Input English To Show Phonetic"]) {
        textView.text = @"";
        self.textViewInput.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{

    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Input English To Show Phonetic";
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
    NSArray *menuItems = [[UtilsXML utilXMLInstance] getArrayMenuItemForScreenSearchText:(NSInteger)self.view.frame.size.height];
    KxMenuItem *first0 = menuItems[0];
    first0.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first0.alignment = NSTextAlignmentCenter;
    first0.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    [KxMenu sharedMenu].htmlString = htmlString;
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_DETAIL_DICTIONARY;
    [KxMenu sharedMenu].textAudio = audioText;
    [KxMenu sharedMenu].audiolangCode = [UtilsXML utilXMLInstance].langCodes[[RDConstant sharedRDConstant].langCode];

    if (self.textViewInput.hidden) {
        [KxMenu showMenuInView:self.scrollText
                      fromRect:CGRectMake(self.searchText.frame.origin.x, self.searchText.frame.origin.y - 20, 62, 62)
                     menuItems:menuItems];

    }else
    [KxMenu showMenuInView:self.textViewInput
                  fromRect:CGRectMake(self.searchText.frame.origin.x, self.searchText.frame.origin.y - 20, 62, 62)
                 menuItems:menuItems];
}
- (void)showMenuListAllStory;
{
    NSArray *menuItems = [[UtilsXML utilXMLInstance] getArrayMenuItemForScreenSearchText:(NSInteger)self.view.frame.size.height];
    KxMenuItem *first0 = menuItems[0];
    first0.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first0.alignment = NSTextAlignmentCenter;
    first0.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    [KxMenu sharedMenu].arrGroups = [[RDStoryDBManager databaseStory] loadAllGroups];
    [KxMenu sharedMenu].arrStories = [[RDStoryDBManager databaseStory] loadAllStory];
    [KxMenu sharedMenu].targetStory = self;
    [KxMenu sharedMenu].selectorStory = @selector(didChooseStory:);
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_LIST_ALL_STORY;
    [KxMenu sharedMenu].edictViewControll = self;
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(stack.center.x, self.searchText.frame.origin.y, stack.frame.size.width, stack.frame.size.height)
                 menuItems:menuItems];
}
-(void)showMenuListAllGroup
{
    NSArray *menuItems = [[UtilsXML utilXMLInstance] getArrayMenuItemForScreenSearchText:(NSInteger)self.view.frame.size.height];
    KxMenuItem *first0 = menuItems[0];
    first0.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first0.alignment = NSTextAlignmentCenter;
    first0.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    [KxMenu sharedMenu].arrGroups = [[RDStoryDBManager databaseStory] loadAllGroups];
    [KxMenu sharedMenu].arrStories = nil;
    [KxMenu sharedMenu].targetStory = self;
    [KxMenu sharedMenu].selectorStory = @selector(didChooseGroup:);

    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_LIST_ALL_STORY;
    [KxMenu sharedMenu].edictViewControll = self;
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(stack.center.x, self.searchText.frame.origin.y, stack.frame.size.width, stack.frame.size.height)
                 menuItems:menuItems];

}
-(void)didChooseStory:(id)sender
{
    self.textViewInput.text = (NSString*)sender;
}
-(void)didChooseGroup:(id)sender
{
    [[RDStoryDBManager databaseStory] insertStoryWithGroup:(NSString*)sender withDetailStory:self.textViewInput.text];
}
-(void)saveStoryToGorup:(NSString*)group
{
    
}
-(void)createNewStory
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create New Story"
                                                    message:@"Input Name Group Of Story"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
        return;
    }
    [[RDStoryDBManager databaseStory] insertGroupStory:[alertView textFieldAtIndex:0].text];
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
    first.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
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
    seven.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    KxMenuItem *eight = menuItems[7];
    eight.languagecode = 0;
    eight.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    KxMenuItem *neight = menuItems[8];
    neight.languagecode = 1;
    neight.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    KxMenuItem *ten = menuItems[9];
    ten.languagecode = 2;
    ten.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];;
    KxMenuItem *menu1 = menuItems[10];
    menu1.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    menu1.languagecode = 3;
    KxMenuItem *menu2 = menuItems[11];
    menu2.languagecode = 4;
    menu2.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];

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
    first.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];;
    KxMenuItem *two = menuItems[1];
    two.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];;
    two.typePrint = MENU_TYPE_AIRPRINT;
    KxMenuItem *three = menuItems[2];
    three.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    three.typePrint = MENU_TYPE_CANONPRINT;
    first.alignment = NSTextAlignmentLeft;
    
        [KxMenu sharedMenu].htmlString = nil;
    [KxMenu sharedMenu].typeSHow = MENU_TYPE_SHOWING_MENU;
    [KxMenu sharedMenu].textAudio = nil;
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(stack.center.x, self.searchText.frame.origin.y, stack.frame.size.width, stack.frame.size.height)
                 menuItems:menuItems];
}
- (void)showMenuForSettingStory
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Save Story To Group"
                     image:nil
                    target:self
                    action:@selector(pushMenuItemGroupSelect:)],
      
      [KxMenuItem menuItem:@"Create New Group"
                     image:nil
                    target:self
                    action:@selector(pushMenuItemGroupSelect:)],
      
      [KxMenuItem menuItem:@"List All Story"
                     image:nil
                    target:self
                    action:@selector(pushMenuItemGroupSelect:)],
      
      
      ];
    
    KxMenuItem *first = menuItems[0];
    first.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    first.typeStory = STORY_TYPE_SAVE_ALL_STORY;
    KxMenuItem *two = menuItems[1];
    two.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];;
    two.typeStory = STORY_TYPE_CREATE_NEW;
    KxMenuItem *three = menuItems[2];
    three.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)self.view.frame.size.height];
    three.typeStory = STORY_TYPE_LIST_ALL_STORY;
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
            if ([str isEqualToString:@""]) {
                [arrWord addObject:@"\n"];
                continue;
            }
            [arrWord addObjectsFromArray:[str componentsSeparatedByString:@" "]];
            [arrWord addObject:@"\n"];
        }
        isLoadPhonetic = YES;
        self.scrollText.fontName = [[UtilsXML alloc] init].fontNames[0];
        self.scrollText.fontSize = 18;
        [self.scrollText initEdictTextView];
        self.scrollText.arrWord = arrWord;
//        self.scrollText.arrPhonetic = arrPhonetic;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scrollText.hidden = NO;
            self.textViewInput.hidden = YES;
        });
        [[EdictDatabase database] getEdictInfosWithArrWord:arrWord withCreateViewBlock:^(NSInteger index, NSString *word, NSString *phonetic,NSInteger location) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.scrollText setupEdictTextViewWithFrame:self.scrollText.frame forIndex:index withWord:word withPhonetic:phonetic withLocation:location];
            });

        } withCompleteBlock:^(BOOL isComplete,NSArray*phonetic,NSString *textInputString) {
            if (isComplete) {
                self.scrollText.arrPhonetic = phonetic;
                dispatch_async(dispatch_get_main_queue(), ^{
                    isShowPhonetic = YES;
                    self.banerView.hidden = NO;
                    self.topConstraintButtonSwitch.constant = 9.0f;
                    self.topConstraintScrollText.constant = self.banerView.frame.size.height;
                    self.topConstraintTextViewInput.constant = self.banerView.frame.size.height;
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    self.textViewInput.hidden = YES;
                    self.scrollText.hidden = NO;
                    self.textBuffer = text;
                    self.fontSizeBuffer = [RDConstant sharedRDConstant].fontSizeView;
                    [self.buttonPhonetic setBackgroundImage:[UIImage imageNamed:@"EditText"] forState:UIControlStateNormal];
                    [self.scrollText setContentOffset:CGPointZero animated:YES];
                    self.textReading = textInputString;
                });
            }

        }];
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
    EDictLabel *labelPre = [self.scrollText viewWithTag:tagPre];
//    if ([labelPre respondsToSelector:@selector(unhightLightTextlabel)]) {
//        [labelPre unhightLightTextlabel];
//    }
    EDictLabel *labelCurrent = [self.scrollText viewWithTag:tagCurrent];
//    if ([labelCurrent respondsToSelector:@selector(unhightLightTextlabel)]) {
//        [labelCurrent unhightLightTextlabel];
//    }
    PhoneticLabel *labelPhoPre =labelPre.phoneticLabel;
    if ([labelPhoPre respondsToSelector:@selector(unhightLightTextlabel)]) {
        [labelPhoPre unhightLightTextlabel];
    }
    PhoneticLabel *labelPhoCurrent = labelCurrent.phoneticLabel;
    if ([labelPhoCurrent respondsToSelector:@selector(unhightLightTextlabel)]) {
        [labelPhoCurrent unhightLightTextlabel];
    }
    [self.scrollText setContentOffset:CGPointZero animated:YES];
    self.buttonPhonetic.hidden = NO;


}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                               target:self
                                             selector:@selector(siwtchViewText:)
                                             userInfo:nil
                                              repeats:NO];
        

}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [speaker_on changeImageItem:[UIImage imageNamed:@"audio_play"]];
    isPlayAudio = NO;
    EDictLabel *labelPre = [self.scrollText viewWithTag:tagPre];
    //    if ([labelPre respondsToSelector:@selector(unhightLightTextlabel)]) {
    //        [labelPre unhightLightTextlabel];
    //    }
    EDictLabel *labelCurrent = [self.scrollText viewWithTag:tagCurrent];
    //    if ([labelCurrent respondsToSelector:@selector(unhightLightTextlabel)]) {
    //        [labelCurrent unhightLightTextlabel];
    //    }
    PhoneticLabel *labelPhoPre =labelPre.phoneticLabel;
    if ([labelPhoPre respondsToSelector:@selector(unhightLightTextlabel)]) {
        [labelPhoPre unhightLightTextlabel];
    }
    PhoneticLabel *labelPhoCurrent = labelCurrent.phoneticLabel;
    if ([labelPhoCurrent respondsToSelector:@selector(unhightLightTextlabel)]) {
        [labelPhoCurrent unhightLightTextlabel];
    }

}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance
{
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [speaker_on changeImageItem:[UIImage imageNamed:@"audio_play"]];
    isPlayAudio = NO;
    EDictLabel *labelPre = [self.scrollText viewWithTag:tagPre];
    //    if ([labelPre respondsToSelector:@selector(unhightLightTextlabel)]) {
    //        [labelPre unhightLightTextlabel];
    //    }
    EDictLabel *labelCurrent = [self.scrollText viewWithTag:tagCurrent];
    //    if ([labelCurrent respondsToSelector:@selector(unhightLightTextlabel)]) {
    //        [labelCurrent unhightLightTextlabel];
    //    }
    PhoneticLabel *labelPhoPre =labelPre.phoneticLabel;
    if ([labelPhoPre respondsToSelector:@selector(unhightLightTextlabel)]) {
        [labelPhoPre unhightLightTextlabel];
    }
    PhoneticLabel *labelPhoCurrent = labelCurrent.phoneticLabel;
    if ([labelPhoCurrent respondsToSelector:@selector(unhightLightTextlabel)]) {
        [labelPhoCurrent unhightLightTextlabel];
    }
    tagPre = -1;
    tagCurrent = -1;
    self.buttonPhonetic.hidden = NO;


}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
        EDictLabel *labelPre = [self.scrollText viewWithTag:tagPre];
//        if ([labelPre respondsToSelector:@selector(unhightLightTextlabel)]) {
//            [labelPre unhightLightTextlabel];
//        }
        PhoneticLabel *labelPhoPre = labelPre.phoneticLabel;
        if ([labelPhoPre respondsToSelector:@selector(unhightLightTextlabel)]) {
            [labelPhoPre unhightLightTextlabel];
        }
     EDictLabel *labelCurrent = [self.scrollText viewWithTag:characterRange.location];

      if (tagCurrent == -1 && self.scrollText.contentOffset.y > labelCurrent.frame.origin.y) {
        [self.scrollText setContentOffset:CGPointMake(0, labelCurrent.frame.origin.y -labelCurrent.frame.size.height) animated:YES];
        }
        if (labelCurrent.frame.origin.y > self.scrollText.contentOffset.y + self.scrollText.frame.size.height- labelCurrent.frame.size.height) {
        [self.scrollText setContentOffset:CGPointMake(0, labelCurrent.frame.origin.y -labelCurrent.frame.size.height) animated:YES];
        }

       tagCurrent = characterRange.location;
       NSLog(@"location in view %ld",(long)characterRange.location);

//    for (UILabel *label in self.scrollText.subviews) {
//        NSLog(@"location in view %ld",(long)label.tag);
//        NSLog(@"tag is %ld",-(label.tag + ((label.tag == 0) ? 1: 0)));
//
//    }
//    NSLog(@"location in view %ld",(long)tagCurrent);
//    NSLog(@"tag is %ld",-(tagCurrent + ((tagCurrent == 0) ? 1: 0)));

//    if ([labelCurrent respondsToSelector:@selector(hightLightTextlabel)]) {
//        [labelCurrent hightLightTextlabel];
//    }
    PhoneticLabel *labelPhoCurrent = labelCurrent.phoneticLabel;
    if ([labelPhoCurrent respondsToSelector:@selector(hightLightTextlabel)]) {
        [labelPhoCurrent hightLightTextlabel];
    }
    tagPre = tagCurrent;
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
                                        message:@"PRINT WITH CANON APP"
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [alert
             addAction:[UIAlertAction
                        actionWithTitle:@"PRINT WITH CANON APP"
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
              message:@"READING ENGLISH PRINT WITH CANON"
              delegate:(id<UIAlertViewDelegate>)self
              cancelButtonTitle:@"CANCEL"
              otherButtonTitles:@"PRINT WITH CANON APP", nil] show];
#pragma clang diagnostic pop
        }
    } else {
        /* Encourage Users to Install CPIS if CPIS is not Installed.
         */
        NSString *message = @"PRINT CANNON APP APPSTORE INSTALL";
        NSString *titleAlert = @"CANON APP IS INSTALLED";
        NSString *cancelButtonAlert = @"CANCEL";
        NSString *acceptButtonAlert = @"OK";
        
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
        if ([alertView.title isEqualToString:@"CANON APP NOT INSTALL"]) {
            [self openAppstoreForCannon];
        } else if ([alertView.message
                    isEqualToString:@"PRINT WITH CANON APP"]) {
            [self openCannonApp];
        }
    }
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
                pic.delegate = self;
                if ([FDDeviceHardware deviceFamily]==UIDeviceFamilyiPhone) {
                    [pic presentAnimated:YES completionHandler:^(UIPrintInteractionController * _Nonnull printInteractionController, BOOL completed, NSError * _Nullable error) {
                        if (completed) {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    }];
                    
                }else
                {
                    [pic presentFromRect:CGRectMake(stack.center.x , stack.center.y, 64, 64) inView:self.view animated:YES completionHandler:^(UIPrintInteractionController * _Nonnull printInteractionController, BOOL completed, NSError * _Nullable error) {
                        if (completed) {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];

                        }
                    }];
                }
                
            });
            
        }];
    });
    } else {
        // Not Available
    }
    
}
- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}
#pragma mark - handle delegate scrooll view app
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [KxMenu dismissMenu];
    [stack closeStack];
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];

}
#pragma mark - handle timer view app
-(void)siwtchViewText:(id)sender
{
    self.buttonPhonetic.hidden = YES;
}
@end
