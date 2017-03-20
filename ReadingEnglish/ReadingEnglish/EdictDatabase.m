//
//  FailedBankDatabase.m
//  Edict Free reading
//
//  Created by Ray Wenderlich on 4/5/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "EdictDatabase.h"
#import "EdictInfo.h"
#import "UtilsXML.h"
#import "HTMLParser.h"

@implementation EdictDatabase

static EdictDatabase *FDConstantsSharedSingletonDatabase = nil;

+ (EdictDatabase*)database {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FDConstantsSharedSingletonDatabase = [[EdictDatabase alloc] init];
    });
    return FDConstantsSharedSingletonDatabase;
}


- (id)init {
    if ((self = [super init])) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"tbl_edict" ofType:@"sqlite"];

        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (NSArray *)getEdictInfosWithArrWord:(NSArray*)arrWord {
    NSMutableArray *arrPhonetic = [NSMutableArray array];
    [self.strDetail removeAllObjects];
    self.strDetail = nil;
    self.strDetail = [NSMutableArray array];
    for (NSString* str in arrWord) {
        NSString *query = [NSString stringWithFormat:@"%@%@%@",@"SELECT idx,word, detail FROM tbl_edict WHERE word = '",[str lowercaseString],@"'"] ;
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            NSInteger i = 0;
            while (sqlite3_step(statement) == SQLITE_ROW) {
//                char *wordChars = (char *) sqlite3_column_text(statement, 1);
                char *detailChars = (char *) sqlite3_column_text(statement, 2);
                //            char *stateChars = (char *) sqlite3_column_text(statement, 3);
//                NSString *word = [[NSString alloc] initWithUTF8String:wordChars];
                NSString *detail = [[NSString alloc] initWithUTF8String:detailChars];
                
//                [Dict setObject:[[UtilsXML utilXMLInstance] getPhoneticFromHTML:detail] forKey:[word copy]];
                [arrPhonetic addObject:[[UtilsXML utilXMLInstance] getPhoneticFromHTML:detail]];
                [_strDetail addObject:detail];
                i++;
            }
            if (i<=0) {
                [arrPhonetic addObject:str];
                [_strDetail addObject:str];
            }

            sqlite3_finalize(statement);
        }else{
            [arrPhonetic addObject:str];
            [_strDetail addObject:str];
        }


    }
    return arrPhonetic;
    
}
- (NSString *)getEdictInfosWithWord:(NSString*)arrWord
{
    NSString *strPhonetic = [NSString string];
        NSString *query = [NSString stringWithFormat:@"%@%@%@",@"SELECT idx,word, detail FROM tbl_edict WHERE word = '",[arrWord lowercaseString],@"'"] ;
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            NSInteger i = 0;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //                char *wordChars = (char *) sqlite3_column_text(statement, 1);
                char *detailChars = (char *) sqlite3_column_text(statement, 2);
                //            char *stateChars = (char *) sqlite3_column_text(statement, 3);
                //                NSString *word = [[NSString alloc] initWithUTF8String:wordChars];
                NSString *detail = [[NSString alloc] initWithUTF8String:detailChars];
                
                //                [Dict setObject:[[UtilsXML utilXMLInstance] getPhoneticFromHTML:detail] forKey:[word copy]];
                strPhonetic = detail;
                i++;
            }
            if (i==0) {
                strPhonetic = arrWord;
            }
            sqlite3_finalize(statement);
        }else
        {
            strPhonetic = arrWord;

        }
    
    return strPhonetic;

}
@end
