//
//  FailedBankDatabase.h
//  Edict Free reading
//
//  Created by Ray Wenderlich on 4/5/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@class FailedBankDetails;

@interface EdictDatabase : NSObject {
    sqlite3 *_database;
}
@property (strong,nonatomic) NSMutableArray *strDetail;
+ (EdictDatabase*)database;
- (NSArray *)getEdictInfosWithArrWord:(NSArray*)arrWord;
- (NSString *)getEdictInfosWithWord:(NSString*)arrWord;

@end
