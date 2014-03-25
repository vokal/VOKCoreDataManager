//
//  VOKManagedObject.h
//  VOKCoreData
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (VOKManagedObjectAdditions)

/**
 Checks for NSNull before seting a value.
 @param value
 The input object.
 @param key
 The key to set.
 */
- (void)safeSetValue:(id)value forKey:(NSString *)key;

/**
 Creates a dictionary based on the set mapping. This should round-trip data from dictionaries to core data and back.
 This method does not respect keyPaths. The dictionary is flat.
 @return
 An NSDictioary matching the original input dictionary.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 Creates a dictionary based on the set mapping. This should round-trip data from dictionaries to core data and back.
 This method respects keyPaths.
 @return
 An NSDictioary matching the original input dictionary.
 */
- (NSDictionary *)dictionaryRepresentationRespectingKeyPaths;

/**
 A convenience methods to create a new instance of a VOKManagedObject subclass.
 @return
 A new managed object subclass in the main context.
 */
+ (instancetype)newInstance;

/**
 A convenience methods to create a new instance of a VOKManagedObject subclass.
 @param contextOrNil
 The managed object context to insert the new object.  If nil, the main context will be used.
 @return
 A new managed object subclass in the main context.
 */
+ (instancetype)newInstanceWithContext:(NSManagedObjectContext *)contextOrNil;

/*
 Create or update many NSManagedObjects, respecting overwriteObjectsWithServerChanges.
 This should only be used to set all properties of an entity, any mapped attributes not included in the input dictionaries will be set to nil.
 This will overwrite ALL of an NSManagedObject's properties.
 @param inputArray
 An array of dictionaries with foreign data to inport.
 @param contextOfNil
 The managed object context to update and/or insert the objects. If nil, the main context will be used.
 @return 
 An array of this subclass of NSManagedObject.
 **/
+ (NSArray *)addWithArray:(NSArray *)inputArray forManagedObjectContext:(NSManagedObjectContext*)contextOrNil;

/*
 Create or update a single NSManagedObject, respecting overwriteObjectsWithServerChanges.
 This should only be used to set all properties of an entity, any mapped attributes not included in the input dictionaries will be set to nil.
 This will overwrite ALL of an NSManagedObject's properties.
 @param inputDict
 A dictionary with foreign data to inport.
 @param contextOfNil
 The managed object context to update and/or insert the object. If nil, the main context will be used.
 @return
 An instance of this subclass of NSManagedObject.
 **/
+ (instancetype)addWithDictionary:(NSDictionary *)inputDict forManagedObjectContext:(NSManagedObjectContext*)contextOrNil;

/*
 Convenience method to create a fetch request.
 @return
 A fetch request of the current class.
 */
+ (NSFetchRequest *)fetchRequest;

/*
 Convenience method to create a fetch request with a predicate.
 @param predicate
 Predicate to construct the fetch request.
 @return
 A fetch request on the given class.
 */
+ (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate;

/*
 Checks the count to determine if entities exist matching the predicate.
 @param predicate
 Predicate to use to fetch.
 @param contextOrNil
 The managed object context to fetch in.  If nil, the main context will be used.
 @return
 YES the object exists or NO it does not.
 */
+ (BOOL)existsForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;

/*
 Returns all entites matching the predicate.
 @param predicate
 Predicate to use to fetch.
 @param contextOrNil
 The managed object context to fetch in.  If nil, the main context will be used.
 @return
 NSArray full of the instances of the current class.
 */
+ (NSArray *)fetchAllForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;

/*
 Returns one entite matching the predicate. Asserts the count is exactly 1. If more objects are returned this method will let you know.
 @param predicate
 Predicate to use to fetch.
 @param contextOrNil
 The managed object context to fetch in.  If nil, the main context will be used.
 @return
 An instance of the current class.
 */
+ (instancetype)fetchForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;

@end