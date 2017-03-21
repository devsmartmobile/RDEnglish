//
//  RDConstant.m
//  ReadingEnglish
//
//  Created by Tran Han on 3/21/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import "RDConstant.h"
NSString *const RDConstantFontSizeViewKey = @"RDConstantFontSizeViewKey";
static RDConstant *RDConstantSharedSingletonDatabase = nil;
@interface RDConstant ()
{
    NSUserDefaults *defaut;
}
@end
@implementation RDConstant
+ (RDConstant*)sharedRDConstant {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RDConstantSharedSingletonDatabase = [[RDConstant alloc] init];
    });
    return RDConstantSharedSingletonDatabase;
}
-(void)setFontSizeView:(NSInteger)fontSizeView
{
     defaut= [NSUserDefaults standardUserDefaults];
    [defaut setObject:[NSNumber numberWithInteger:fontSizeView] forKey:RDConstantFontSizeViewKey];
    [defaut synchronize];
}
-(NSInteger)fontSizeView
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:RDConstantFontSizeViewKey] integerValue];
}
@end
