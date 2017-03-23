//
//  EdictTextView.h
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EdictTextView : UIScrollView
@property (nonatomic,strong) NSString *fontName;
@property (nonatomic,assign) NSInteger fontSize;
@property (nonatomic,strong) NSArray *arrPhonetic;
@property (nonatomic,strong) NSArray *arrWord;
@property (nonatomic,assign) CGFloat totalHeight;
@property (nonatomic,assign) NSInteger totalLine;

-(void)setupEdictTextViewWithFrame:(CGRect)framePaper;
-(void)setupEdictTextViewWithFrameForPrint:(CGRect)framePaper withCompleteBlock:(void (^)(NSArray *arrPaper))completion;
- (void) imageWithView:(UIView *)view withFrame:(CGRect)frame withCompleteBlock:(void (^)(NSArray *arrPaper))completion;
-(UIImage*)crop:(CGRect)frame withImage:(UIImage*)image;
-(void)addSubviewWithKey :(NSString*)key withPhonetic:(NSString*)phonetic withSizeKey:(CGSize)sizeKey withSizePhonetic:(CGSize)sizePhonetic  withTag:(NSInteger)tag;
-(void)addSubviewWithKey :(NSString*)key withPhonetic:(NSString*)phonetic withTextView:(EdictTextView*)textview withSizeKey:(CGSize)sizeKey withSizePhonetic:(CGSize)sizePhonetic withTag:(NSInteger)tag;

@end
