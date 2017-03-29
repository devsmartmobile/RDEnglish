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
#import "NSString+FDEdict.h"

@implementation EdictDatabase
@synthesize bufferWord = _bufferWord;
@synthesize bufferDetail = _bufferDetail;
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
        _bufferWord= [NSMutableDictionary dictionary];
        _bufferDetail= [NSMutableDictionary dictionary];
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
        NSString *phoneticStr = [_bufferWord objectForKey:str];
        if (phoneticStr) {
            [arrPhonetic addObject:phoneticStr];
            [_strDetail addObject:[_bufferDetail objectForKey:str]];
            continue;
        }
        NSString *strRemove = [str removeSpecifiCharacter];
        NSString *query = [NSString stringWithFormat:@"%@%@%@",@"SELECT idx,word, detail FROM tbl_edict WHERE word = '",[strRemove lowercaseString],@"'LIMIT 1"] ;
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
                NSString *phonetic =[[UtilsXML utilXMLInstance] getPhoneticFromHTML:detail];
                [arrPhonetic addObject:phonetic];
                [_strDetail addObject:detail];
                if (![_bufferWord objectForKey:str]) {
                    [_bufferWord setObject:phonetic forKey:str];
                    [_bufferDetail setObject:detail forKey:str];
                }
                i++;
            }
            if (i<=0) {
                [arrPhonetic addObject:str];
                [_strDetail addObject:str];
                if (![_bufferWord objectForKey:str]) {
                    [_bufferWord setObject:str forKey:str];
                    [_bufferDetail setObject:str forKey:str];

                }

            }

            sqlite3_finalize(statement);
        }else{
            [arrPhonetic addObject:str];
            [_strDetail addObject:str];
            if (![_bufferWord objectForKey:str]) {
            [_bufferWord setObject:str forKey:str];
            [_bufferDetail setObject:str forKey:str];
            }
        }


    }
    
    return arrPhonetic;
    
}
- (void)getEdictInfosWithArrWord:(NSArray*)arrWord withCreateViewBlock:(void (^)(NSInteger index,NSString* word,NSString * phonetic,NSInteger location))createView  withCompleteBlock:(void (^)(BOOL isComplete , NSArray*phonetic,NSString *textInputString))completion
{
    NSMutableString *strInputString = [NSMutableString string];
    NSMutableArray *arrPhonetic = [NSMutableArray array];
    [self.strDetail removeAllObjects];
    self.strDetail = nil;
    self.strDetail = [NSMutableArray array];
    NSInteger locationAtIndex = 0;
    for (int index = 0; index < arrWord.count; index ++) {
        NSString *str = arrWord [index];
        if ([str isEqualToString:@""] || [str isEqualToString:@"\n"]) {
            [strInputString appendString:@" "];
        }else
        {
            [strInputString appendString:str];
            [strInputString appendString:@" "];

        }
        
        locationAtIndex =  strInputString.length - str.length - 1;

        NSString *phoneticStr = [_bufferWord objectForKey:str];
        if (phoneticStr) {
            [arrPhonetic addObject:phoneticStr];
            [_strDetail addObject:[_bufferDetail objectForKey:str]];
            createView (index,str,phoneticStr,locationAtIndex);
            continue;
        }
        NSString *strRemove = [str removeSpecifiCharacter];
        NSString *query = [NSString stringWithFormat:@"%@%@%@",@"SELECT idx,word, detail FROM tbl_edict WHERE word = '",[strRemove lowercaseString],@"'LIMIT 1"] ;
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
                NSString *phonetic =[[UtilsXML utilXMLInstance] getPhoneticFromHTML:detail];
                [arrPhonetic addObject:phonetic];
                createView (index,str,phonetic,locationAtIndex);
                [_strDetail addObject:detail];
                if (![_bufferWord objectForKey:str]) {
                    [_bufferWord setObject:phonetic forKey:str];
                    [_bufferDetail setObject:detail forKey:str];
                }
                i++;
            }
            if (i<=0) {
                [arrPhonetic addObject:str];
                createView (index,str,str,locationAtIndex);
                [_strDetail addObject:str];
                if (![_bufferWord objectForKey:str]) {
                    [_bufferWord setObject:str forKey:str];
                    [_bufferDetail setObject:str forKey:str];
                    
                }
                i++;
            }
            
            sqlite3_finalize(statement);
        }else{
            [arrPhonetic addObject:str];
            createView (index,str,str,locationAtIndex);
            [_strDetail addObject:str];
            if (![_bufferWord objectForKey:str]) {
                [_bufferWord setObject:str forKey:str];
                [_bufferDetail setObject:str forKey:str];
            }
        }
    }
    completion(YES,arrPhonetic,strInputString);
}
- (NSString *)getEdictInfosWithWord:(NSString*)arrWord
{
    NSString *strPhonetic = [NSString string];
    NSString *strRemove = [arrWord removeSpecifiCharacter];

        NSString *query = [NSString stringWithFormat:@"%@%@%@",@"SELECT idx,word, detail FROM tbl_edict WHERE word = '",[strRemove lowercaseString],@"'LIMIT 1"] ;
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
- (BOOL)createTableGroupStory
{
    NSString *query=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT PRIMARY KEY,'%@' TEXT);",@"GroupStory",@"IDG",@"NameG"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_close(_database);
        return  TRUE;
    }else
    {
        NSAssert(0, @"Table failed to create");
        return  FALSE;

    }

}
- (BOOL)createTableDetailStory
{
    NSString *query=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT PRIMARY KEY,'%@' TEXT);",@"DetailStory",@"IDG",@"Detail"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_close(_database);
        return  TRUE;
    }else
    {
        NSAssert(0, @"Table failed to create");
        return  FALSE;
    }

}
-(void)insertrecordIntoTable:(NSString*) tableName withField1:(NSString*) field1 field1Value:(NSString*)field1Vaue andField2:(NSString*)field2 field2Value:(NSString*)field2Value
{
    
    NSString *sqlStr=[NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@')VALUES(?,?)",tableName,field1,field2];
    const char *sql=[sqlStr UTF8String];
    
    sqlite3_stmt *statement1;
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement1, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement1, 1, [field1Vaue UTF8String], -1, nil);
        sqlite3_bind_text(statement1, 2, [field2Value UTF8String], -1, nil);
    }
    if(sqlite3_step(statement1) !=SQLITE_DONE)
        NSAssert(0, @"Error upadating table");
    sqlite3_finalize(statement1);
}
-(void)getAllRowsFromTableNamed:(NSString *)tableName
{
    NSString *field1Str,*field2Str;
    
    NSString *qsql=[NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(_database, [qsql UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        while(sqlite3_step(statement) ==SQLITE_ROW)
        {
            char *field1=(char *) sqlite3_column_text(statement, 0);
            char *field2=(char *) sqlite3_column_text(statement, 1);
            
            field1Str=[[NSString alloc]initWithUTF8String:field1];
            field2Str=[[NSString alloc] initWithUTF8String:field2];
            
            NSString *str=[NSString stringWithFormat:@"%@ - %@",field1Str,field2Str];
        }
    }
}
-(void)getAllRowsFromTableNamed:(NSString *)tableName  withFieldSearch:(NSString*)feildSearch withKeySearch:(NSString*)keySearch
{
    NSString *field1Str,*field2Str;
    
    NSString *qsql=[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,feildSearch,keySearch];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(_database, [qsql UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        while(sqlite3_step(statement) ==SQLITE_ROW)
        {
            char *field1=(char *) sqlite3_column_text(statement, 0);
            char *field2=(char *) sqlite3_column_text(statement, 1);
            
            field1Str=[[NSString alloc]initWithUTF8String:field1];
            field2Str=[[NSString alloc] initWithUTF8String:field2];
            
            NSString *str=[NSString stringWithFormat:@"%@ - %@",field1Str,field2Str];
        }
    }
}

@end
