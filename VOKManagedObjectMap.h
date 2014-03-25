//
//  VOKManagedObjectMap.h
//  CoreData
//

#import <Foundation/Foundation.h>

@interface VOKManagedObjectMap : NSObject

@property NSString *inputKeyPath;
@property NSString *coreDataKey;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSNumberFormatter *numberFormatter;

/**
 Provides easy access to rfc3339 date formatter, like "1985-04-12T23:20:50.52Z"
 @return
 A static instance of NSDateFormatter.
 */
+ (NSDateFormatter *)defaultDateFormatter;

/**
 Provides easy access to NSNumberFormatterDecimalStyle.
 @return
 A static instance of NSNumberFormatterDecimalStyle
 */
+ (NSNumberFormatter *)defaultNumberFormatter;

/**
 Creates a map.
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