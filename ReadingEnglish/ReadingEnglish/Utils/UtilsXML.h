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

+ (UtilsXML*)utilXMLInstance ;

-(NSString*)getPhoneticFromHTML:(NSString*)html;
@end
