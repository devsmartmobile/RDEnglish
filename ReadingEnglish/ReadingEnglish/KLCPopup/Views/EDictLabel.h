//
//  EDictLabel.h
//  EdictFRD
//
//  Created by Tran Han on 3/15/17.
//
//

#import <UIKit/UIKit.h>
#import "EdictInfo.h"

@protocol EDictLabelDelegate <NSObject>
@required
-(void)showDetailVocabolaryWithTag:(NSInteger)tag;

@end

@interface EDictLabel : UILabel
@property (strong,nonatomic) EdictInfo *infor;
@property (strong, nonatomic) id <EDictLabelDelegate> delegate;
-(void)initLabel;
-(void)hightLightTextlabel;
-(void)unhightLightTextlabel;

@end
