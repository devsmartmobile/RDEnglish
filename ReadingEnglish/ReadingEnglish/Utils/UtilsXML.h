//
//  UtilsXML.h
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//

#import <Foundation/Foundation.h>
#import "HTMLParser.h"

@interface UtilsXML : NSObject
@property(strong, nonatomic) NSArray *fontNames;
@property(strong, nonatomic) NSArray *langCodes;

+ (UtilsXML*)utilXMLInstance ;
- (NSString *)drawImagesToPdf:(NSArray*)images;
-(NSString*)getPhoneticFromHTML:(NSString*)html;
@end
