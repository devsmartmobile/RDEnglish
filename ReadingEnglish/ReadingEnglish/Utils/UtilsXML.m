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
- (NSArray *)langCodes {
    if (_langCodes == nil) {
        // Get system font name
        _langCodes = @[
                       @"en-AU",
                       @"en-IE",
                       @"en-ZA",
                       @"en-GB",
                       @"en-US"
                       ];
    }
    return _langCodes;
}
- (NSString *)drawImagesToPdf:(NSArray*)images {
    //[Spec]: create pdf size 1101x1654
    CGFloat pageWidth = 1101;
    CGFloat pageHeight = 1654;
    CGSize pageSize = CGSizeMake(pageWidth, pageHeight);
    NSInteger numberAddressSide = [images count];
    NSString *fileName = @"ReadingEnglishByPhoneticHightlight.pdf";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName =
    [documentsDirectory stringByAppendingPathComponent:fileName];
    UIGraphicsBeginPDFContextToFile(
                                    pdfFileName, CGRectMake(0, 0, pageWidth, pageHeight * numberAddressSide),
                                    nil);
    UIImage *image;
    for (int i = 0; i < numberAddressSide; i++) {
        UIImage *img = images[i] ;
        //    [imagePreview removeSubviewImageView];
        //    imagePreview = nil;
        // Do not need to resize
        //      img = [img imageWithSize:CGSizeMake(1181, 1748)];
        
        // [Spec]crop image left: 40, top 35, width 1101, height 1654
        CGRect cropRect = CGRectMake(0, 0, 1101, 1654);
        CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
        img = nil;
        image = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        UIGraphicsBeginPDFPageWithInfo(
                                       CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        [image drawInRect:CGRectMake(0, 0, pageWidth, pageHeight)];
        
        image = nil;
    }
    UIGraphicsEndPDFContext();
    return pdfFileName;
}
-(NSInteger)getFontForScreen:(NSInteger)height
{
    NSInteger fontSize = 15;
    switch (height) {
        case 480:
            fontSize = 10;
            break;
        case 568:
            fontSize = 12;
            break;
        case 667:
            fontSize = 14;
            break;
        case 736:
            fontSize = 16;
            break;
        case 1024:
            fontSize = 18;
            break;
        case 1366:
            fontSize = 21;
            break;
        default:
            break;
    }
    return fontSize;
}
-(NSArray *)getArrayMenuItemForScreenSearchText:(NSInteger)height
{
    NSArray *arrMenuItem ;
    switch (height) {
        case 480:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              ];
            KxMenuItem *first1 = arrMenuItem[0];
            first1.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first2 = arrMenuItem[1];
            first2.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
        }
            break;
        case 568:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              ];
            KxMenuItem *first3 = arrMenuItem[0];
            first3.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first4 = arrMenuItem[1];
            first4.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first5 = arrMenuItem[2];
            first5.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
        }
            break;
        case 667:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              ];
            KxMenuItem *first6 = arrMenuItem[0];
            first6.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first7 = arrMenuItem[1];
            first7.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first8 = arrMenuItem[2];
            first8.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first9 = arrMenuItem[3];
            first9.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first10 = arrMenuItem[4];
            first10.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first11 = arrMenuItem[5];
            first11.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
        }
            break;
        case 736:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 12344561234456"
                             image:nil
                            target:nil
                            action:NULL],

              ];
            KxMenuItem *first12 = arrMenuItem[0];
            first12.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first13 = arrMenuItem[1];
            first13.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first14 = arrMenuItem[2];
            first14.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first15 = arrMenuItem[3];
            first15.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first16 = arrMenuItem[4];
            first16.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first17 = arrMenuItem[5];
            first17.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first18 = arrMenuItem[6];
            first18.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first19 = arrMenuItem[7];
            first19.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
        }
            break;
        case 1024:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],

              ];
            KxMenuItem *first20 = arrMenuItem[0];
            first20.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first21 = arrMenuItem[1];
            first21.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first22 = arrMenuItem[2];
            first22.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first23 = arrMenuItem[3];
            first23.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first24 = arrMenuItem[4];
            first24.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first25 = arrMenuItem[5];
            first25.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first26 = arrMenuItem[6];
            first26.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first27 = arrMenuItem[7];
            first27.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first28 = arrMenuItem[8];
            first28.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first29 = arrMenuItem[9];
            first29.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
        }
            break;
        case 1366:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 123445612344561234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              ];
            KxMenuItem *first30 = arrMenuItem[0];
            first30.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first31 = arrMenuItem[1];
            first31.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first32 = arrMenuItem[2];
            first32.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first33 = arrMenuItem[3];
            first33.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first34 = arrMenuItem[4];
            first34.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first35 = arrMenuItem[5];
            first35.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first36 = arrMenuItem[6];
            first36.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first37 = arrMenuItem[7];
            first37.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first38 = arrMenuItem[8];
            first38.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first39 = arrMenuItem[9];
            first39.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
        }
            break;
            
        default:
        {
            arrMenuItem =
            @[
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              [KxMenuItem menuItem:@"ACTION MENU 1234456"
                             image:nil
                            target:nil
                            action:NULL],
              
              ];
            KxMenuItem *first3 = arrMenuItem[0];
            first3.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first4 = arrMenuItem[1];
            first4.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];
            KxMenuItem *first5 = arrMenuItem[2];
            first5.fontSize = [[UtilsXML utilXMLInstance] getFontForScreen:(NSInteger)[UIScreen screens][0].bounds.size.height];

        }
            break;
    }
    
    return arrMenuItem;

}
-(CGFloat)getHeightEnglishVietnameseDictionaryForScreen:(NSInteger)height
{
    CGFloat SizeEnglishDictionary = 62;
//    switch (height) {
//        case 480:
//            SizeEnglishDictionary = 62 * (height/736);
//            break;
//        case 568:
//            SizeEnglishDictionary = 62 * (height/736);
//            break;
//        case 667:
//            SizeEnglishDictionary = 62 * (height/736);
//            break;
//        case 736:
//            SizeEnglishDictionary = 62 * (height/736);
//            break;
//        case 1024:
//            SizeEnglishDictionary = 62 * (height/736);
//            break;
//        case 1366:
//            SizeEnglishDictionary = 62 * (height/736);
//            break;
//        default:
//            break;
//    }
    return SizeEnglishDictionary = 62 * (height/736);
;

}
@end
