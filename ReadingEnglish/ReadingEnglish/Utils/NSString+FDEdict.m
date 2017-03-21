//
//  NSMutableString+FDEdict.m
//  EdictFRD
//
//  Created by Tran Han on 3/15/17.
//
//

#import "NSString+FDEdict.h"

@implementation NSString (FDEdict)
-(NSString*)removeSpecifiCharacter
{
    NSString *strRemoveUnUsed1 = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *strRemoveUnUsed2 = [strRemoveUnUsed1 stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *strRemoveUnUsed3 = [strRemoveUnUsed2 stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *strRemoveUnUsed4 = [strRemoveUnUsed3 stringByReplacingOccurrencesOfString:@"(" withString:@""];
    NSString *strRemoveUnUsed5 = [strRemoveUnUsed4 stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSString *strRemoveUnUsed6 = [strRemoveUnUsed5 stringByReplacingOccurrencesOfString:@"&" withString:@""];
    NSString *strRemoveUnUsed7 = [strRemoveUnUsed6 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *strRemoveUnUsed8 = [strRemoveUnUsed7 stringByReplacingOccurrencesOfString:@"?" withString:@""];
    NSString *strRemoveUnUsed9 = [strRemoveUnUsed8 stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSString *strRemoveUnUsed10 = [strRemoveUnUsed9 stringByReplacingOccurrencesOfString:@"!" withString:@""];
    NSString *strRemoveUnUsed11 = [strRemoveUnUsed10 stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *strRemoveUnUsed12 = [strRemoveUnUsed11 stringByReplacingOccurrencesOfString:@"%" withString:@""];
    NSString *strRemoveUnUsed13 = [strRemoveUnUsed12 stringByReplacingOccurrencesOfString:@"^" withString:@""];
    NSString *strRemoveUnUsed14 = [strRemoveUnUsed13 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *strRemoveUnUsed15 = [strRemoveUnUsed14 stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSString *strRemoveUnUsed16 = [strRemoveUnUsed15 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    NSString *strRemoveUnUsed17 = [strRemoveUnUsed16 stringByReplacingOccurrencesOfString:@"`" withString:@""];
    NSString *strRemoveUnUsed18 = [strRemoveUnUsed17 stringByReplacingOccurrencesOfString:@"~" withString:@""];
    NSString *str = [strRemoveUnUsed18 stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    return str;
}

@end
