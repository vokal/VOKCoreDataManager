//
//  VOKManagedObject.m
//  VOKCoreData
//

#import "NSManagedObject+VOKManagedObjectAdditions.h"

#import "VOKCoreDataManager.h"

@implementation NSManagedObject (VOKManagedObjectAdditions)

- (void)vok_safeSetValue:(id)value forKey:(NSString *)key
{
    if (value && ![[NSNull null] isEqual:value]) {
        [self setValue:value forKey:key];
    } else {
        [self setNilValueForKey:key];
    }
}

- (NSDictionary *)vok_dictionaryRepresentation
{
    return [[VOKCoreDataManager sharedInstance] dictionaryRepresentationOfManagedObject:self respectKeyPaths:NO];
}

- (NSDictionary *)vok_dictionaryRepresentationRespectingKeyPaths
{
    return [[VOKCoreDataManager sharedInstance] dictionaryRepresentationOfManagedObject:self respectKeyPaths:YES];
}

#pragma mark - Create Objects

+ (instancetype)vok_newInstance
{
    return [self vok_newInstanceWithContext:nil];
}

+ (instancetype)vok_newInstanceWithContext:(NSManagedObjectContext *)context
{
    return [[VOKCoreDataManager sharedInstance] managedObjectOfClass:self inContext:context];
}

#pragma mark - Add Objects

+ (NSArray *)vok_addWithArray:(NSArray *)inputArray forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] importArray:inputArray forClass:[self class] withContext:contextOrNil];
}

+ (instancetype)vok_addWithDictionary:(NSDictionary *)inputDict forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    if (!inputDict || [[NSNull null] isEqual:inputDict]) {
        return nil;
    }

    NSArray *array = [[VOKCoreDataManager sharedInstance] importArray:@[inputDict] forClass:[self class] withContext:contextOrNil];
    
    if ([array count]) {
        return [array firstObject];
    } else {
        return nil;
    }
}

#pragma mark - Fetching

+ (NSFetchRequest *)vok_fetchRequest
{
    return [self vok_fetchRequestWithPredicate:nil];
}

+ (NSFetchRequest *)vok_fetchRequestWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
}

+ (BOOL)vok_existsForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] countForClass:[self class]
                                                withPredicate:predicate
                                                   forContext:contextOrNil];
}

+ (NSArray *)vok_fetchAllForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] arrayForClass:[self class]
                                                withPredicate:predicate
                                                   forContext:contextOrNil];
}

+ (instancetype)vok_fetchForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    NSArray *results = [self vok_fetchAllForPredicate:predicate forManagedObjectContext:contextOrNil];

    NSUInteger count = [results count];
    if (count) {
        NSAssert(count == 1, @"Your predicate is returning more than 1 object, but the coredatamanger returns only one.");
        return [results lastObject];
    }

    return nil;
}

@end
