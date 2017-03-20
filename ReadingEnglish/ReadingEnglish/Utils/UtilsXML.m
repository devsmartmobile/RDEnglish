//
//  UtilsXML.m
//  EdictFRD
//
//  Created by Han Tran on 3/15/17.
//
//

#import "UtilsXML.h"

@implementation UtilsXML
static UtilsXML *FDConstantsSharedSingleton = nil;

+ (UtilsXML*)utilXMLInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FDConstantsSharedSingleton = [[UtilsXML alloc] init];
    });
    return FDConstantsSharedSingleton;
}

-(NSString*)getPhoneticFromHTML:(NSString*)html
{
    NSString* phonetic;
    HTMLParser *parser = [[HTMLParser alloc] initWithString: html];
    
    HTMLElement *tableContext = [[HTMLElement alloc] initWithTagName:@"C"];
    NSArray *nodes = [parser parseFragmentWithContextElement:tableContext];
    
    for (HTMLNode *node in nodes) {
        NSString *str = node.arrTextContent[0];
        NSArray* arrayOfStrings = [str componentsSeparatedByString:@"/"];
        NSArray* arrayOfStrings2 = [arrayOfStrings.count > 1 ?  arrayOfStrings[1] :  arrayOfStrings[0]componentsSeparatedByString:@","];
        phonetic = arrayOfStrings2.count > 1 ? arrayOfStrings2[1] : arrayOfStrings2[0];
    }

    return [phonetic copy];
}
- (NSArray *)fontNames {
    if (_fontNames == nil) {
        // Get system font name
        UIFont *defaultFont = [UIFont systemFontOfSize:12];
        NSString *defaultFontSystemNames = defaultFont.fontName;
        _fontNames = @[
                       defaultFontSystemNames,
                       @"CRCandGRyuurei-M04",
                       //      @"Arphic-Marker-Tai4-Extra-JIS",
                       @"Arphic-Kaisho4-Medium-JIS",
                       @"Arphic-Marker-Tai4-Extra-JIS"
                       ];
    }
    return _fontNames;
}

@end
