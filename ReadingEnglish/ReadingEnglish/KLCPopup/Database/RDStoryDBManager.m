//
//  RDStoryDBManager.m
//  ReadingEnglish
//
//  Created by Tran Han on 3/24/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#import "RDStoryDBManager.h"

@implementation RDStoryDBManager
static RDStoryDBManager *FDConstantsSharedSingletonDatabaseStory = nil;

+ (RDStoryDBManager*)databaseStory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FDConstantsSharedSingletonDatabaseStory = [[RDStoryDBManager alloc] init];
    });
    return FDConstantsSharedSingletonDatabaseStory;
}
-(void)insertGroupStory:(NSString*)group
{
    AppDelegate *delegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
        NSManagedObject *groupObject = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
        [groupObject setValue:group forKey:@"group_name"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            
        }

}
-(void)insertStoryWithGroup:(NSString*)group withDetailStory:(NSString*)story
{
    AppDelegate *delegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSManagedObject *StoryObject = [NSEntityDescription insertNewObjectForEntityForName:@"DetailStory" inManagedObjectContext:context];
    [StoryObject setValue:group forKey:@"group_name"];
    [StoryObject setValue:story forKey:@"detail_story"];
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
    }

}
-(NSArray*)loadAllGroups
{
    NSMutableArray *arrStory = [NSMutableArray array];
    AppDelegate *delegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
    arrStory = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject *obj in arrStory) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        for (NSString *group in dictionary) {
            [arrStory addObject:group];
        }
        
    }
    return arrStory;

}
-(NSArray*)loadAllStoryWithGroup:(NSString*)group
{
    NSMutableArray *arrStory = [NSMutableArray array];
    AppDelegate *delegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DetailStory"];
    NSPredicate *predicateGroup = [NSPredicate predicateWithFormat:@"(group_name >= %@)", group];
    fetchRequest.predicate = predicateGroup;
    arrStory = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    return arrStory;
}
-(NSDictionary*)loadAllStory
{
    NSArray *arrGroup = [[RDStoryDBManager databaseStory] loadAllGroups];
    NSMutableDictionary *dictStory = [NSMutableDictionary dictionary];
    for (NSString *group in arrGroup) {
        AppDelegate *delegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DetailStory"];
        NSPredicate *predicateGroup = [NSPredicate predicateWithFormat:@"(group_name = %@)", group];
        fetchRequest.predicate = predicateGroup;
        NSArray *arr =  [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
//        [dictStory setObject:arr forKey:group];
        for (NSManagedObject *obj in arr) {
            NSArray *keys = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
            dictStory = dictionary;
        }

    }
    return dictStory;
}
@end
