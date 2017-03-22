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

@end
