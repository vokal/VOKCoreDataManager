//
//  VOKManagedObject.h
//  CoreData
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

//These will adhere to the NSManagedObjectContext of the managedObject.
+ (BOOL)existsForPredicate:(NSPredicate *)predicate forManagedObject:(NSManagedObject *)object;
+ (NSArray *)fetchAllForPredicate:(NSPredicate *)predicate forManagedObject:(NSManagedObject *)object;
+ (id)fetchForPredicate:(NSPredicate *)predicate forManagedObject:(NSManagedObject *)object;

//These allow for more flexibility.
+ (BOOL)existsForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;
+ (NSArray *)fetchAllForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;
+ (id)fetchForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;

@end