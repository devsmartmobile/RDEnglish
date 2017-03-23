//
//  FailedBankInfo.h
//  Edict Free reading
//
//  Created by Ray Wenderlich on 4/5/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdictInfo : NSObject {
    int _uniqueId;
    NSString *_word;
    NSString *_detail;
    NSString *_state;
}

@property (nonatomic, assign) int uniqueId;
@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *state;

- (id)initWithUniqueId:(int)uniqueId name:(NSString *)word city:(NSString *)detail state:(NSString *)state;

@end
