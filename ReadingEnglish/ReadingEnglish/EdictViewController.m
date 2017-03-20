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

@interface EdictViewController ()<UIPrintInteractionControllerDelegate,UITextFieldDelegate,UPStackMenuDelegate>
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

}
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
@property (weak, nonatomic) IBOutlet UIButton *btPhoneticWord;
@property (weak, nonatomic) IBOutlet EdictTextView *scrollText;

@end

@implementation EdictViewController


#pragma mark - handle keyboard event of viewcontroller

- (void)keyboardDidShow: (NSNotification *) notif{
    [stack closeStack];
    [KxMenu dismissMenu];
    // Do something here
    NSDictionary* keyboardInfo = [notif userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
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
        self.topConstraintButtonSwitch.constant = - self.banerView.frame.size.height;

    }];
}
- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    NSDictionary* keyboardInfo = [notif userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

    [UIView animateWithDuration:0.1 animations:^{
        self.bottomSpaceSearchText.constant = self.bottomSpaceSearchText.constant - keyboardFrameBeginRect.size.height;
        self.bottomConstraintTextInput.constant = self.bottomConstraintTextInput.constant -keyboardFrameBeginRect.size.height;
        self.bottomConstraintSearchEnglish.constant = 0.0f;
        [stack setCenter:CGPointMake(stack.center.x, stack.center.y+keyboardFrameBeginRect.size.height)];
        self.topConstraintScrollText.constant = self.banerView.frame.size.height;
        self.topConstraintTextViewInput.constant = self.banerView.frame.size.height;
        self.banerView.hidden = NO;
        self.topConstraintButtonSwitch.constant = 0.0;
    }];
    
    
}

#pragma mark - handle view of viewcontroller
- (void)viewDidLoad {
    [super viewDidLoad];
    //setup swip left and right
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showWordView:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPhoenticView:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.textViewInput addGestureRecognizer:swipLeft];
    [self.scrollText addGestureRecognizer:swipRight];

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
    self.textViewInput.font = [UIFont fontWithName:[UtilsXML utilXMLInstance].fontNames[0] size:18];
    self.textViewInput.delegate = self;
    self.textViewInput.userInteractionEnabled = YES;
    self.textViewInput.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Add_icon"]];
    [contentView setBackgroundColor:[UIColor colorWithRed:127/255. green:140/255. blue:141/255. alpha:1.]];
    [contentView.layer setCornerRadius:30];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    [icon setFrame:CGRectInset(contentView.frame, 10, 10)];
    [contentView addSubview:icon];
    [self setupStackMenu:0];
    
//    [[UITextView appearance] setTintColor:[UIColor blackColor]];
//    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    self.banerView.hidden = YES;
    self.topConstraintButtonSwitch.constant = - self.banerView.frame.size.height;
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
    self.textViewInput.textColor = [UIColor colorWithRed:44/255. green:62/255. blue:80/255. alpha:1.];
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
    
    if ([UIPrintInteractionController isPrintingAvailable])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            // Available
            [self.scrollText imageWithView:self.scrollText withCompleteBlock:^(NSArray *arrPaper) {
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

- (IBAction)didPressOnReading:(id)sender {
    if (isPlayAudio) {
        [self didPressOffReading:sender];
        return;
    }
    isPlayAudio = YES;
    [speaker_on changeImageItem:[UIImage imageNamed:@"speaker_on"]];
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    
    synthesizer = [[AVSpeechSynthesizer alloc]init];
    utterance = [AVSpeechUtterance speechUtteranceWithString:self.textViewInput.text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
    [utterance setRate:0.4f];
    [synthesizer speakUtterance:utterance];
    
}
- (IBAction)didPressOffReading:(id)sender {
    [speaker_on changeImageItem:[UIImage imageNamed:@"speaker_off"]];
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    isPlayAudio = NO;
}

- (IBAction)didPressOnPhonetic:(id)sender {
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    if ([self.textViewInput.text isEqualToString:@""]) {
        return;
    }
    if (isShowPhonetic) {
        self.textViewInput.hidden = NO;
        self.scrollText.hidden = YES;
        isShowPhonetic = NO;
    }else
    {
        [self setupPhoneticWordForText];
        
    }
    [self.view bringSubviewToFront:self.btPhoneticWord];
    
}

- (IBAction)didPressOnSearch:(id)sender {
}
- (IBAction)didPressOnSetting:(id)sender
{
    [self.textViewInput resignFirstResponder];
    [self.searchText resignFirstResponder];
    [self showMenu:nil];
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
    speaker_on = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"speaker_off"] highlightedImage:nil title:@""];
    print = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"printer_icon"] highlightedImage:nil title:@""];
    settingItem = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"Gear_icon"] highlightedImage:nil title:@""];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:speaker_on, print,settingItem, nil];
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

- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
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
    if ([self.textViewInput.text isEqualToString:@""]) {
        return;
    }
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

        default:
            break;
    }
}


#pragma mark - handle Text View of viewcontroller
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
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;    [KxMenu sharedMenu].htmlString = htmlString;
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

#pragma mark - handle Func Common of viewcontroller
-(void)setupPhoneticWordForText
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        NSMutableArray *arrWord  = [NSMutableArray array];
        NSArray *arrBreakLine = [self.textViewInput.text componentsSeparatedByString:@"\n"];
        for (NSString *str in arrBreakLine) {
            NSString *strRemove = [str removeSpecifiCharacter];
            [arrWord addObjectsFromArray:[strRemove componentsSeparatedByString:@" "]];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.textViewInput.hidden = YES;
            self.scrollText.hidden = NO;
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
        self.textViewInput.text = nil;
        self.textViewInput.text = str;
        [self setupPhoneticWordForText];
        self.banerView.hidden = YES;
        self.topConstraintButtonSwitch.constant = self.banerView.frame.size.height;

    }

}
- (void)dealloc {
}

@end
