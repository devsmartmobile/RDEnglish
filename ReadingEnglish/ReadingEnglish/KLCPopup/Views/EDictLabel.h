//
//  EDictLabel.h
//  EdictFRD
//
//  Created by Tran Han on 3/15/17.
//
//

#import <UIKit/UIKit.h>
#import "EdictInfo.h"
#import "PhoneticLabel.h"
@protocol EDictLabelDelegate <NSObject>
@required
-(void)showDetailVocabolaryWithTag:(NSInteger)tag;

@end

@interface EDictLabel : UILabel
@property (strong,nonatomic) EdictInfo *infor;
@property (assign,nonatomic) NSInteger indexLabel;
@property (strong,nonatomic) PhoneticLabel *phoneticLabel;

@property (strong, nonatomic) id <EDictLabelDelegate> delegate;
-(void)initLabel:(PhoneticLabel*)phonetic;
-(void)hightLightTextlabel;
-(void)unhightLightTextlabel;

@end
