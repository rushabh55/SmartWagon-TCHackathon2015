//
//  VNLDevice.m
//  Vinli
//
//  Created by Laurence Andersen on 7/1/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import "VNLDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface VNLDevice ()

@property (strong, nonatomic) CBPeripheral *peripheral;

@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSString *vehicleIdentificationNumber;

@property (strong, nonatomic) NSString *chipID;

@property (nonatomic) BOOL collisionDetected;
@property (nonatomic) VNLAcceleration accelerometerInfo;

@property (strong, nonatomic) NSArray *diagnosticTroubleCodes;

@property (strong, nonatomic) NSMutableDictionary *deviceValues;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)updateValue:(id)value forProperty:(NSString *)propertyName;

- (void)updateDiagnosticTroubleCodesWithData:(NSData *)data;
- (void)addDiagnosticTroubleCode:(NSString *)troubleCode;

- (void)updateAccelerometerInfoWithData:(NSData *)data;

@property (strong, nonatomic) NSDictionary* supportedPidsMapCache;

@end


@implementation VNLDevice


#pragma mark - Initialization

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _peripheral = peripheral;
    
    _deviceValues = [[NSMutableDictionary alloc] init];
    
    _diagnosticTroubleCodePollingInterval = 60.0;
    
    _vehicleIdentificationNumber = nil;
    _chipID = nil;
    
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p (identifier: %@) (chipid: %@)>", NSStringFromClass([self class]), self, self.identifier, self.chipID];
}

#pragma mark - Accessors

- (BOOL)connected
{
    return (self.peripheral.state == CBPeripheralStateConnected);
}

- (NSString *)identifier
{
    if (!_peripheral) {
        return nil;
    }
    
    return [_peripheral.identifier UUIDString];
}

- (id)valueForProperty:(NSString *)propertyName
{
    if (!propertyName) {
        return nil;
    }
    
    @synchronized(_deviceValues) {
        return [_deviceValues objectForKey:propertyName];
    }
}

- (void)updateValue:(id)value forProperty:(NSString *)propertyName
{
    if (!value || !propertyName) {
        return;
    }
    
    @synchronized(_deviceValues) {
        [_deviceValues setObject:value forKeyedSubscript:propertyName];
    }
}

- (void)updateDiagnosticTroubleCodesWithData:(NSData *)data
{
    if (!data) {
        _diagnosticTroubleCodes = nil;
        return;
    }
    
    NSString *troubleCodesString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if (troubleCodesString.length == 0) {
        _diagnosticTroubleCodes = nil;
        return;
    }
    
    NSArray *rawDTCList = [troubleCodesString componentsSeparatedByString:@","];
    
    NSMutableArray *sanitizedDTCList = [[NSMutableArray alloc] init];
    
    [rawDTCList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *currentCode = (NSString *)obj;
        if (currentCode.length < 5) {
            return;
        }
        
        NSRange newLineRange = [currentCode rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0];
        NSString *sanitizedCode = currentCode;
        if (newLineRange.location != NSNotFound) {
            sanitizedCode = [currentCode substringToIndex:newLineRange.location];
        }
        
        char firstChar = [currentCode characterAtIndex:0];
        if (firstChar != 'P' && firstChar != 'B' && firstChar != 'C' && firstChar != 'U') {
            return;
        }
        
        
        [sanitizedDTCList addObject:sanitizedCode];
    }];
    
    _diagnosticTroubleCodes = sanitizedDTCList;
}

- (void)addDiagnosticTroubleCode:(NSString *)troubleCode
{
    if (!troubleCode) {
        return;
    }
    
    NSMutableArray *mutableDTCList = [_diagnosticTroubleCodes mutableCopy];
    if (!mutableDTCList) {
        mutableDTCList = [[NSMutableArray alloc] init];
    }
    
    [mutableDTCList addObject:troubleCode];
    
    _diagnosticTroubleCodes = mutableDTCList;
}

- (void)updateAccelerometerInfoWithData:(NSData *)data
{
    if (data.length == 14) {
    
        //NSLog(@"Accel data = %@", data);
        
        VNLAcceleration acceleration;
        double multiplier = (9.807f / 16384.0f);
        
        char* buffer = malloc(4);
        [data getBytes:buffer range:NSMakeRange(0, 4)];
        short x = (NSInteger)strtol(buffer, NULL, 16);
        
        acceleration.x = x * multiplier;
        
        [data getBytes:buffer range:NSMakeRange(4, 4)];
        short y = (NSInteger)strtol(buffer, NULL, 16);
        
        acceleration.y = y * multiplier;
        
        [data getBytes:buffer range:NSMakeRange(8, 4)];
        short z = strtol(buffer, NULL, 16);
        
        acceleration.z = z * multiplier;
        
        char* collisionBuffer = malloc(2);
        [data getBytes:collisionBuffer range:NSMakeRange(12, 2)];
        short collisionVal = strtol(collisionBuffer, NULL, 16);
        self.collisionDetected = collisionVal == 1;
        
        
        self.accelerometerInfo = acceleration;
        //self.collisionDetected = (BOOL)collision;

        
        free(buffer);
        free(collisionBuffer);
    }
    else
    if (data.length == 4) // This is deprecated but leaving in case we test older devices
    {
        VNLAcceleration acceleration;
        char* accelBytes = malloc(4);
        [data getBytes:accelBytes length:4];
        acceleration.x = accelBytes[0];
        acceleration.y = accelBytes[1];
        acceleration.z = accelBytes[2];
        
        BOOL collision = accelBytes[3] == 1;
        
        self.collisionDetected = (BOOL)collision;
        
        free(accelBytes);
    }
}

- (void)setRSSI:(NSNumber *)RSSI
{
    _RSSI = RSSI;
}

#pragma mark - Supported Pids

-(NSString*)hexToBinary:(NSString*)hexString {
    NSMutableString *retnString = [NSMutableString string];
    for(int i = 0; i < [hexString length]; i++) {
        char c = [[hexString lowercaseString] characterAtIndex:i];
        
        switch(c) {
            case '0': [retnString appendString:@"0000"]; break;
            case '1': [retnString appendString:@"0001"]; break;
            case '2': [retnString appendString:@"0010"]; break;
            case '3': [retnString appendString:@"0011"]; break;
            case '4': [retnString appendString:@"0100"]; break;
            case '5': [retnString appendString:@"0101"]; break;
            case '6': [retnString appendString:@"0110"]; break;
            case '7': [retnString appendString:@"0111"]; break;
            case '8': [retnString appendString:@"1000"]; break;
            case '9': [retnString appendString:@"1001"]; break;
            case 'a': [retnString appendString:@"1010"]; break;
            case 'b': [retnString appendString:@"1011"]; break;
            case 'c': [retnString appendString:@"1100"]; break;
            case 'd': [retnString appendString:@"1101"]; break;
            case 'e': [retnString appendString:@"1110"]; break;
            case 'f': [retnString appendString:@"1111"]; break;
            default : break;
        }
    }
    
    return retnString;
}
NSData *CreateDataWithHexString(NSString *inputString)
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
    
    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
    
    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }
            
        } else {
            if (o != 0) break;
        }
    }
    
    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}

- (BOOL)pidSupported:(NSString *)pid
{
    [self buildSupportedPidCache];
    return _supportedPidsMapCache[pid] ? [_supportedPidsMapCache[pid] boolValue] : NO;
}

- (BOOL)pidTypeSupported:(NSInteger)pidType
{
    NSString* pidKey = [NSString stringWithFormat:@"%02lx", (long)pidType];
    return [self pidSupported:pidKey];
}


//B3824000 is passed back by device simulator
- (void)buildSupportedPidCache
{
    if (_supportedPidsMapCache || !_supportedPidsHexString)
    {
        return;
    }
    
    //clean the string before converting to data -- device returns \n\r
    NSString* cleanStr;
    cleanStr = [_supportedPidsHexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cleanStr = [cleanStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    cleanStr = [cleanStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSData* data = CreateDataWithHexString(cleanStr);
    
    //bytes
    const char *byte = [data bytes];
    
    //bits
    NSMutableDictionary* pidCache = [NSMutableDictionary new];
    NSUInteger length = [data length];
    for (int i=0; i<length; i++) {
        char n = byte[i];
        char buffer[9];
        buffer[8] = 0; //for null
        int j = 8;
        
        while(j > 0)
        {
            int val = (i * 8) + j;
            if (val == 1|| val == 32 || val == 64 || val == 96 ||  val == 128) {
                // These represent a marker for a group of supported pids in the data.
                // They will never have a value so I am just removing them.
                // This is awful, but I couldn't think of a better way to do it. I'm bad at math. (Pumpkin)
            }
            else
            {
                NSString* pidKey = [NSString stringWithFormat:@"%02x", (i * 8) + j];
                [pidCache setObject:[NSNumber numberWithInt:(n & 0x01)] forKey:pidKey];
            }
            
            --j;
            n >>= 1;
        }
    }
    _supportedPidsMapCache = [pidCache copy];
    
}

- (NSArray *)getSupportedPIDs;
{
    [self buildSupportedPidCache];
    
    NSMutableArray* currentlySupportedPids = [NSMutableArray new];
    for (int i = 0; i < _supportedPidsMapCache.allKeys.count; i++)
    {
        NSString* str = [NSString stringWithFormat:@"%02x", i];
        BOOL supported = [self pidSupported:str];
        
        if (supported)
        {
            [currentlySupportedPids addObject:str];
        }
        
        // NSLog(@"Pid %@ supported = %@", str, supported ? @"YES" : @"NO");
    }
    
    return [currentlySupportedPids copy];
}

- (void)clearCollision
{
    self.collisionDetected = NO;
}

@end


@implementation VNLDeviceMetaData

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _name = dictionary[@"name"] ? dictionary[@"name"] : nil;
        _deviceId = dictionary[@"deviceId"] ? dictionary[@"deviceId"] : nil;
        _iconURL = dictionary[@"iconURL"] ? dictionary[@"iconURL"] : nil;
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{@"name": _name ? _name : @"", @"deviceId" :_deviceId ? _deviceId : @"", @"iconURL" : _iconURL ? _iconURL : @"" };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self toDictionary]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_deviceId forKey:@"deviceId"];
    [encoder encodeObject:_iconURL forKey:@"iconURL"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    
    if((self = [super init])) {
        _name = [decoder decodeObjectForKey:@"name"];
        _deviceId = [decoder decodeObjectForKey:@"deviceId"];
        _iconURL= [decoder decodeObjectForKey:@"iconURL"];
    }
    return self;
}

@end

