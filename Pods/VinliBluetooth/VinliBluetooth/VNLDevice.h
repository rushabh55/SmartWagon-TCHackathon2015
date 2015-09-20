//
//  VNLDevice.h
//  Vinli
//
//  Created by Laurence Andersen on 7/1/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    double x;
    double y;
    double z;
} VNLAcceleration;

@interface VNLDeviceMetaData : NSObject
@property (readonly) NSString* name;
@property (readonly) NSString* deviceId;
@property (readonly) NSURL* iconURL;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;
@end


@interface VNLDevice : NSObject

@property (nonatomic, readonly) BOOL connected;

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, readonly) NSString *vehicleIdentificationNumber;

@property (nonatomic, readonly) NSString *chipID;

@property (nonatomic, readonly) BOOL collisionDetected;
@property (nonatomic, readonly) VNLAcceleration accelerometerInfo;

@property (nonatomic, readonly) NSArray *diagnosticTroubleCodes;
@property (nonatomic) NSTimeInterval diagnosticTroubleCodePollingInterval;

@property (copy, nonatomic) NSString* supportedPidsHexString;

@property (strong, nonatomic) VNLDeviceMetaData* deviceMetaData;

@property (readonly, nonatomic) NSNumber* RSSI;

- (id)valueForProperty:(NSString *)propertyName;

- (BOOL)pidSupported:(NSString *)pid;
- (BOOL)pidTypeSupported:(NSInteger)pidType;
- (NSArray *)getSupportedPIDs;

- (void)clearCollision;

@end
