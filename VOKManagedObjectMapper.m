//
//  VOKManagedObjectMap.m
//  CoreData
//

#import "VOKManagedObjectMapper.h"
#import "VOKCoreDataManager.h"

@interface VOKManagedObjectDefaultMapper : VOKManagedObjectMapper
@end

@interface VOKManagedObjectMapper()
@property (nonatomic) NSArray *mapsArray;
- (void)updateForeignComparisonKey;
- (id)checkNull:(id)inputObject;
- (id)checkDate:(id)inputObject withDateFormatter:(NSDateFormatter *)dateFormatter;
- (id)checkString:(id)outputObject withDateFormatter:(NSDateFormatter *)dateFormatter;
- (id)checkClass:(id)inputObject managedObject:(NSManagedObject *)object key:(NSString *)key;
- (Class)expectedClassForObject:(NSManagedObject *)object andKey:(id)key;
@end

@implementation VOKManagedObjectMapper

+ (instancetype)mapperWithUniqueKey:(NSString *)comparisonKey andMaps:(NSArray *)mapsArray;
{
    VOKManagedObjectMapper *mapper = [[self alloc] init];
    [mapper setMapsArray:mapsArray];
    [mapper setUniqueComparisonKey:comparisonKey];
    return mapper;
}

+ (instancetype)defaultMapper
{
    return [[VOKManagedObjectDefaultMapper alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        _overwriteObjectsWithServerChanges = YES;
    }
    return self;
}

- (void)setUniqueComparisonKey:(NSString *)uniqueComparisonKey
{
    _uniqueComparisonKey = uniqueComparisonKey;
    _foreignUniqueComparisonKey = nil;
    if (uniqueComparisonKey) {
        [self updateForeignComparisonKey];
    }
}

- (void)setMapsArray:(NSArray *)mapsArray
{
    _mapsArray = mapsArray;
    _foreignUniqueComparisonKey = nil;
    if (mapsArray) {
        [self updateForeignComparisonKey];
    }
}

- (void)updateForeignComparisonKey
{
    [self.mapsArray enumerateObjectsUsingBlock:^(VOKManagedObjectMap *aMap, NSUInteger idx, BOOL *stop) {
        if ([aMap.coreDataKey isEqualToString:self.uniqueComparisonKey]) {
            _foreignUniqueComparisonKey = aMap.inputKeyPath;
        }
    }];
}

#pragma mark - Description
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>\nMaps:%@\nUniqueKey:%@",
            NSStringFromClass([self class]),
            self,
            self.mapsArray,
            self.uniqueComparisonKey];
}

#pragma mark - Import Safety Checks

- (id)checkNull:(id)inputObject
{
    if ([[NSNull null] isEqual:inputObject]) {
        return nil;
    }
    return inputObject;
}

- (id)checkNumber:(id)inputObject withNumberFormatter:(NSNumberFormatter *)numberFormatter
{
    if (![inputObject isKindOfClass:[NSString class]]) {
        return inputObject;
    }

    //Bug: using DEFAULT mapper, if the input string COULD be made a number it WILL be made a number.
    //Be wary of the default mapper
    id number = [numberFormatter numberFromString:inputObject];
    return number ? number : inputObject;
}

- (id)checkDate:(id)inputObject withDateFormatter:(NSDateFormatter *)dateFormatter
{
    if (![inputObject isKindOfClass:[NSString class]]) {
        return inputObject;
    }
    id date = [dateFormatter dateFromString:inputObject];
    return date ? date : inputObject;
}

- (id)checkString:(id)outputObject withNumberFormatter:(NSNumberFormatter *)numberFormatter
{
    if (![outputObject isKindOfClass:[NSNumber class]]) {
        return outputObject;
    }
    id numberString = [numberFormatter stringFromNumber:outputObject];
    return numberString ? numberString : outputObject;
}

- (id)checkString:(id)outputObject withDateFormatter:(NSDateFormatter *)dateFormatter
{
    if (![outputObject isKindOfClass:[NSDate class]]) {
        return outputObject;
    }
    id dateString = [dateFormatter stringFromDate:outputObject];
    return dateString ? dateString : outputObject;
}

- (id)checkClass:(id)inputObject managedObject:(NSManagedObject *)object key:(NSString *)key
{
    Class expectedClass = [self expectedClassForObject:object andKey:key];
    if (![inputObject isKindOfClass:expectedClass]) {
        CDLog(@"Wrong kind of class for %@\nProperty: %@ \nExpected: %@\nReceived: %@",
              object,
              key,
              NSStringFromClass(expectedClass),
              NSStringFromClass([inputObject class]));
        return nil;
    }
    return inputObject;
}

- (Class)expectedClassForObject:(NSManagedObject *)object andKey:(id)key
{
    NSDictionary *attributes = [[object entity] attributesByName];
    NSAttributeDescription *attributeDescription = [attributes valueForKey:key];
    return NSClassFromString([attributeDescription attributeValueClassName]);
}

@end

#pragma mark - Dictionary Input and Output
@implementation VOKManagedObjectMapper (dictionaryInputOutput)
- (void)setInformationFromDictionary:(NSDictionary *)inputDict forManagedObject:(NSManagedObject *)object
{
    [self.mapsArray enumerateObjectsUsingBlock:^(VOKManagedObjectMap *aMap, NSUInteger idx, BOOL *stop) {
        id inputObject = [inputDict valueForKeyPath:aMap.inputKeyPath];
        inputObject = [self checkDate:inputObject withDateFormatter:aMap.dateFormatter];
        inputObject = [self checkNumber:inputObject withNumberFormatter:aMap.numberFormatter];
        inputObject = [self checkClass:inputObject managedObject:object key:aMap.coreDataKey];        
        inputObject = [self checkNull:inputObject];
        [object safeSetValue:inputObject forKey:aMap.coreDataKey];
    }];
}

- (NSDictionary *)dictionaryRepresentationOfManagedObject:(NSManagedObject *)object
{
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    [self.mapsArray enumerateObjectsUsingBlock:^(VOKManagedObjectMap *aMap, NSUInteger idx, BOOL *stop) {
        id outputObject = [object valueForKey:aMap.coreDataKey];
        outputObject = [self checkString:outputObject withDateFormatter:aMap.dateFormatter];
        outputObject = [self checkString:outputObject withNumberFormatter:aMap.numberFormatter];
        if (outputObject) {
            outputDict[aMap.inputKeyPath] = outputObject;
        }
    }];
    
    return [outputDict copy];
}

NSString *const period = @".";
- (NSDictionary *)hierarchicalDictionaryRepresentationOfManagedObject:(NSManagedObject *)object
{
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    [self.mapsArray enumerateObjectsUsingBlock:^(VOKManagedObjectMap *aMap, NSUInteger idx, BOOL *stop) {
        id outputObject = [object valueForKey:aMap.coreDataKey];
        outputObject = [self checkString:outputObject withDateFormatter:aMap.dateFormatter];
        outputObject = [self checkString:outputObject withNumberFormatter:aMap.numberFormatter];

        NSArray *components = [aMap.inputKeyPath componentsSeparatedByString:period];
        [self createNestedDictionary:outputDict fromKeyPathComponents:components];
        if (outputObject) {
            [outputDict setValue:outputObject forKeyPath:aMap.inputKeyPath];
        }
    }];

    return [outputDict copy];
}

- (void)createNestedDictionary:(NSMutableDictionary *)outputDict fromKeyPathComponents:(NSArray *)components
{
    __block NSMutableDictionary *nestedDict = outputDict;
    NSUInteger lastObjectIndex = [components count] - 1;
    [components enumerateObjectsUsingBlock:^(NSString *keyPathComponent, NSUInteger idx, BOOL *stop) {
        if(![nestedDict valueForKey:keyPathComponent] && idx < lastObjectIndex) {
            nestedDict[keyPathComponent] = [NSMutableDictionary dictionary];
        }
        nestedDict = [nestedDict valueForKey:keyPathComponent];
    }];
}

@end

#pragma mark - Dictionary Input and Output with the Default Mapper
@implementation VOKManagedObjectDefaultMapper
- (void)setInformationFromDictionary:(NSDictionary *)inputDict forManagedObject:(NSManagedObject *)object
{
    //this default mapper assumes that local keys and entities match foreign keys and entities
    [inputDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id inputObject = obj;
        inputObject = [self checkDate:inputObject withDateFormatter:[VOKManagedObjectMap defaultDateFormatter]];
        inputObject = [self checkNumber:inputObject withNumberFormatter:[VOKManagedObjectMap defaultNumberFormatter]];
        inputObject = [self checkClass:inputObject managedObject:object key:key];
        inputObject = [self checkNull:inputObject];
        [object safeSetValue:inputObject forKey:key];
    }];
}

- (NSDictionary *)dictionaryRepresentationOfManagedObject:(NSManagedObject *)object
{
    NSDictionary *attributes = [[object entity] attributesByName];
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id outputObject = [object valueForKey:key];
        outputObject = [self checkString:outputObject withDateFormatter:[VOKManagedObjectMap defaultDateFormatter]];
        if (outputObject) {
            outputDict[key] = outputObject;
        }
    }];
    
    return [outputDict copy];
}

- (NSDictionary *)hierarchicalDictionaryRepresentationOfManagedObject:(NSManagedObject *)object
{
    //the default mapper does not have key paths
    return [self dictionaryRepresentationOfManagedObject:object];
}

@end
