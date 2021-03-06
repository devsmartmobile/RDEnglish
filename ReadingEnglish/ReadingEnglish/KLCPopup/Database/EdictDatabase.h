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
@property (strong,nonatomic)NSMutableDictionary *bufferWord;
@property (strong,nonatomic)NSMutableDictionary *bufferDetail;
@property (strong,nonatomic) NSMutableArray *strDetail;
+ (EdictDatabase*)database;
- (NSArray *)getEdictInfosWithArrWord:(NSArray*)arrWord ;
- (void)getEdictInfosWithArrWord:(NSArray*)arrWord withCreateViewBlock:(void (^)(NSInteger index,NSString* word,NSString * phonetic,NSInteger location))createView  withCompleteBlock:(void (^)(BOOL isComplete , NSArray*phonetic,NSString *textInputString))completion;
- (NSString *)getEdictInfosWithWord:(NSString*)arrWord;
- (BOOL)createTableGroupStory;
- (BOOL)createTableDetailStory;
-(void)insertrecordIntoTable:(NSString*) tableName withField1:(NSString*) field1 field1Value:(NSString*)field1Vaue andField2:(NSString*)field2 field2Value:(NSString*)field2Value;
-(void)getAllRowsFromTableNamed:(NSString *)tableName;
-(void)getAllRowsFromTableNamed:(NSString *)tableName  withFieldSearch:(NSString*)feildSearch withKeySearch:(NSString*)keySearch;
@end
