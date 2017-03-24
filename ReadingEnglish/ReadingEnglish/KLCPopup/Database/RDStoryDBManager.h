//
//  RDStoryDBManager.h
//  ReadingEnglish
//
//  Created by Tran Han on 3/24/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface RDStoryDBManager : NSObject
+ (RDStoryDBManager*)databaseStory;
-(void)insertGroupStory:(NSString*)group;
-(void)insertStoryWithGroup:(NSString*)group withDetailStory:(NSString*)story;
-(NSArray*)loadAllGroups;
-(NSArray*)loadAllStoryWithGroup:(NSString*)group;
-(NSDictionary*)loadAllStory;
@end
