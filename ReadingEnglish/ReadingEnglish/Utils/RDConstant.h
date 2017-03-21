//
//  RDConstant.h
//  ReadingEnglish
//
//  Created by Tran Han on 3/21/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDConstant : NSObject
@property (assign,nonatomic) NSInteger fontSizeView;
+(instancetype)sharedRDConstant;
@end
