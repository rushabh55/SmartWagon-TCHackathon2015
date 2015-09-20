//
//  VNLPid.m
//  Vinli
//
//  Created by Andrew Wells on 8/8/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import "VNLPID.h"

static NSMutableDictionary* PIDObjectMap;
static NSDictionary* PIDInfo;

@interface VNLPID ()
@end


@implementation VNLPID

+ (void)initialize
{
    PIDObjectMap = [NSMutableDictionary new];
}
+ (void)setPIDInfo:(NSDictionary *)pidInfo
{
    PIDInfo = pidInfo;
}

- (instancetype)initWithMetadata:(NSDictionary *)metadata andValue:(id)value
{
    if (self = [super init])
    {
        _rawValue = value;
        _metadata = metadata;
        
    }
    return self;
}

- (NSString *)getPIDTypeString
{
   return [NSString stringWithFormat:@"%02lX", (long)self.type];
}

- (NSString *)name
{
    return self.metadata[@"name"] ?: @"";
}

- (NSString *)units
{
    return  self.metadata[@"units"] ?: @"";
}

- (BOOL)isDecimal
{
    NSString* datatype = self.metadata[@"dataType"];
    return [datatype isEqualToString:@"decimal"];
}

#pragma mark - PID Decoding

+ (VNLPID *)getPIDObjectForType:(VNLPIDType)type
{
    NSString *pidKey = [NSString stringWithFormat:@"%02lX", (long)type];
    VNLPID* retVal = [PIDObjectMap objectForKey:pidKey];
    if (!retVal)
    {
        @synchronized(PIDObjectMap)
        {
            NSDictionary* metadata = [VNLPID metadataForPIDType:type];
            retVal = [[VNLPID alloc] initWithMetadata:metadata andValue:nil];
            [PIDObjectMap setObject:retVal forKey:pidKey];
        }
    }
    
    return retVal;
}

+ (NSDictionary *)valuesForPIDData:(NSData *)data
{
    VNLPIDValues pidValues = [data VNL_PIDValues];
    if (pidValues.type == VNLPIDTypeUnknown) {
        return nil;
    }
    
    NSMutableDictionary *returnValues = [[NSMutableDictionary alloc] init];
    
    @synchronized(PIDInfo) {
        id pidMetadata = [self metadataForPIDType:pidValues.type];
        if (!pidMetadata) {
            return nil;
        }
        
        NSArray *pidMetadataList = nil;
        
        if ([pidMetadata isKindOfClass:[NSArray class]]) {
            pidMetadataList = pidMetadata;
        } else if ([pidMetadata isKindOfClass:[NSDictionary class]]) {
            pidMetadataList = @[pidMetadata];
        }
        
        if (!pidMetadataList) {
            return nil;
        }
        
        [pidMetadataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *currentPIDMetadata = (NSDictionary *)obj;
            
            id value = [self valueForPIDValues:pidValues metadata:currentPIDMetadata];
            VNLPID* pid = [VNLPID getPIDObjectForType:pidValues.type];
            pid.metadata = currentPIDMetadata;
            pid.rawValue = value;
            pid.type = pidValues.type;
            
            if (!value || !pid) {
                return;
            }
            
            NSString *key = [currentPIDMetadata objectForKey:@"key"];
            if (!key) {
                return;
            }
            
            [returnValues setObject:pid forKey:key];
        }];
    }
    
    return returnValues;
}

+ (id)valueForPIDValues:(VNLPIDValues)pidValues metadata:(NSDictionary *)pidMetadata
{
    if (pidValues.type == VNLPIDTypeUnknown || !pidMetadata) {
        return nil;
    }
    
    NSString* dataType = nil;
    NSNumber *numberOfBytes = nil;
    NSString *conversionFormula = nil;
    
    if (![pidMetadata isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    
    numberOfBytes = [pidMetadata objectForKey:@"numBytes"];
    if (!numberOfBytes) {
        return nil;
    }
    
    dataType = [pidMetadata objectForKey:@"dataType"];
    if (!dataType) {
        return nil;
    }
    else if ([dataType isEqualToString:@"string"])
    {
        NSString* hexStr = [NSString stringWithUTF8String:pidValues.hexValue];
        free(pidValues.hexValue);
        return hexStr;
    }
    
    conversionFormula = [pidMetadata objectForKey:@"convert"];
    if (!conversionFormula) {
        return nil;
    }

    
    if ([dataType isEqualToString:@"decimal"])
    {
    }
    
    NSExpression *expression = [NSExpression expressionWithFormat:conversionFormula];
    NSMutableDictionary *expressionValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(pidValues.a), @"A", @(pidValues.b), @"B", @(pidValues.c), @"C", @(pidValues.d), @"D", nil];
    
    id returnValue = [expression expressionValueWithObject:expressionValues context:nil];
    return returnValue;
}

+ (id)metadataForPIDType:(VNLPIDType)pidType
{
    if (pidType == VNLPIDTypeUnknown || !PIDInfo) {
        return nil;
    }
    
    NSString *pidKey = [NSString stringWithFormat:@"01-%02lX", (long)pidType];
    NSDictionary *info = [PIDInfo objectForKey:pidKey];
    return info;
}

+ (NSString *)pidForProperty:(NSString *)property
{
    __block NSString* retVal;
    [PIDInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* pidDic = obj;
            if (pidDic[@"key"])
            {
                if ([pidDic[@"key"] isEqualToString:property])
                {
                    retVal = key;
                    *stop = YES;
                }
            }
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            NSArray* pidArray = obj;
            for (NSDictionary* pidDic in pidArray)
            {
                if ([pidDic[@"key"] isEqualToString:property])
                {
                    retVal = key;
                    *stop = YES;
                    break;
                }
            }
        }
    }];
    
    //NSRange range = [retVal rangeOfString:@"-"];
    retVal = [retVal substringWithRange:NSMakeRange(retVal.length - 2, 2)];
    return retVal.lowercaseString;
}




@end

@implementation NSData (VNLConveniences)

- (NSInteger)VNL_startingIndexOfPIDType
{
    NSInteger pidTypeStart = NSNotFound;
    
    // Look for the beginning of the PID,
    // skipping over extraneous characters
    // (such as extra line breaks)
    for (NSInteger currentByteIndex = 0; currentByteIndex < 2; currentByteIndex++) {
        char *modeString = malloc(2);
        [self getBytes:modeString range:NSMakeRange(currentByteIndex, 2)];
        
        if (!strncmp(modeString, "41", 2)) {
            pidTypeStart = currentByteIndex + 2;
        }
        
        free(modeString);
        
        if (pidTypeStart != NSNotFound) {
            break;
        }
    }
    
    return pidTypeStart;
}

- (VNLPIDValues)VNL_PIDValues
{
    VNLPIDValues pidValues;
    pidValues.type = VNLPIDTypeUnknown;
    pidValues.a = 0;
    pidValues.b = 0;
    pidValues.c = 0;
    pidValues.d = 0;
    pidValues.hexValue = 0;
    
    NSInteger pidTypeStart = [self VNL_startingIndexOfPIDType];
    
    if (pidTypeStart == NSNotFound || (self.length < 6)) {
        return pidValues;
    }
    
    char *buffer = malloc(2);
    
    // Determine the PID type
    [self getBytes:buffer range:NSMakeRange(pidTypeStart, 2)];
    unsigned long pidType = strtoul(buffer, NULL, 16);
    pidValues.type = pidType;
    
    
    // Data portion starts after mode
    // and PID
    NSInteger dataStart = pidTypeStart + 2;
    
    char *fullBuffer = malloc(self.length - dataStart);
    [self getBytes:fullBuffer range:NSMakeRange(dataStart, self.length - dataStart)];
    pidValues.hexValue = fullBuffer;
    
    if (pidValues.type == VNLPIDTypeShortTermFuelTrimBank1) {
       NSLog( @"" );
    }
    
    // Determine the A value
    [self getBytes:buffer range:NSMakeRange(dataStart, 2)];
    short aValue = (NSInteger)strtol(buffer, NULL, 16);
    pidValues.a = aValue;
    
    // Determine the B value
    if (dataStart + 2 + 2 > self.length) {
        goto cleanup;
    }
    [self getBytes:buffer range:NSMakeRange(dataStart + 2, 2)];
    NSInteger bValue = (NSInteger)strtol(buffer, NULL, 16);
    pidValues.b = bValue;
    
    // Bail if data isn't long
    // enough for B & C values
    if (self.length < pidTypeStart + 12) {
        goto cleanup;
    }
    
    // Determine the C value
    [self getBytes:buffer range:NSMakeRange(dataStart + 4, 2)];
    NSInteger cValue = (NSInteger)strtol(buffer, NULL, 16);
    pidValues.c = cValue;
    
    // Determine the D value
    [self getBytes:buffer range:NSMakeRange(dataStart + 6, 2)];
    NSInteger dValue = (NSInteger)strtol(buffer, NULL, 16);
    pidValues.d = dValue;
    
cleanup:
    free(buffer);
    return pidValues;
}

@end
