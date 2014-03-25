//
//  VOKManagedObjectMap.h
//  VOKCoreData
//

#import <Foundation/Foundation.h>

@interface VOKManagedObjectMap : NSObject

/// Remote key for input/output
@property NSString *inputKeyPath;

/// Local key for input/output
@property NSString *coreDataKey;

/// Date formatter for input/output
@property (nonatomic) NSDateFormatter *dateFormatter;

/// Number formatter for input/output
@property (nonatomic) NSNumberFormatter *numberFormatter;

/**
 Creates a map with the default date mapper.
 @param inputKeyPath
 The foreign key to match with the local key.
 @param coreDataKey
 The local key.
 @return
 A VOKManagedObjectMap
 */
+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey;
/**
 Creates a map with a date formatter. If the input object is an NSString the date formatter will be appied.
 @param inputKeyPath
 The foreign key to match with the local key.
 @param coreDataKey
 The local key.
 @param dateFormatter
 A date formatter to parse in and out of core data.
 @return
 A VOKManagedObjectMap
 */
+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey
                        dateFormatter:(NSDateFormatter *)dateFormatter;
/**
 Creates a map with a number formatter. If the input object is an NSNumber the number formatter will be appied.
 @param inputKeyPath
 The foreign key to match with the local key.
 @param coreDataKey
 The local key.
 @param numberFormatter
 A number formatter to parse in and out of core data.
 @return
 A VOKManagedObjectMap
 */
+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey
                      numberFormatter:(NSNumberFormatter *)numberFormatter;

/**
 Make a dictionary of keys and values and get an array of maps in return.
 @param mapDict
 Each key is the expected input keyPath and each value is core data key.
 @return
 An array of VOKManagedObjectMaps.
 */
+ (NSArray *)mapsFromDictionary:(NSDictionary *)mapDict;

@end