//
//  FailedBankInfo.m
//  Edict Free reading
//
//  Created by Ray Wenderlich on 4/5/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "EdictInfo.h"

@implementation EdictInfo

@synthesize uniqueId = _uniqueId;
@synthesize word = _word;
@synthesize detail = _detail;
@synthesize state = _state;

- (id)initWithUniqueId:(int)uniqueId name:(NSString *)word city:(NSString *)detail state:(NSString *)state {
    if ((self = [super init])) {
        self.uniqueId = uniqueId;
        self.word = word;
        self.detail = detail;
        self.state = state;
    }
    return self;
}

- (void) dealloc {
    self.word = nil;
    self.detail = nil;
    self.state = nil;    
}

@end
