//
//  VNLDeviceManager.h
//  Vinli
//
//  Created by Laurence Andersen on 6/24/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "VNLDevice.h"
#import "VNLDeviceObserving.h"
#import "VNLProperties.h"
#import "VNLPID.h"

#define weakify(var) __weak typeof(var) VNLWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = VNLWeak_##var; \
_Pragma("clang diagnostic pop")


/**
 `VNLDeviceManager` provides methods to communicate with Vinli devices over Bluetooth Low Engergy (BLE).
 */

@interface VNLDeviceManager : NSObject

@property (nonatomic, readonly) NSDictionary *vinliDevices;

@property (weak, nonatomic) id <VNLDeviceObserving> deviceObserver;

@property (strong, nonatomic) NSString* accessToken;


///-----------------------------
/// @name Initialization
///-----------------------------

- (instancetype)initWithPIDInfo:(NSDictionary *)PIDInfo accessToken:(NSString *)token;
- (instancetype)initWithAccessToken:(NSString *)token;


///-----------------------------
/// @name Device Lifecycle
///-----------------------------

/**
 DeviceManager's CBCentralManager will begin scanning for nearby Vinli devices and identify the device by its ChipId.

 */
- (void)scanForDevices;

/**
 DeviceManager's CBCentralManager will stop scanning for nearby Vinli devices.
 
 */
- (void)stopScanningForDevices;
//- (void)connectDevice:(VNLDevice *)device;


/**
 Clears the Device Trouble Codes (DTCs) of the connected Vinli Device.
 
 */
- (void)clearDeviceTroubleCodes;

/**
 Clears the crash status of the connected Vinli Device.
 
 */
- (void)clearDeviceCrash;


/**
 The DeviceManager automatically valid Vinli devices that is successfully connects to and will automatically reconnect when those devices are detected.
 
 This will clear the device managers cache associted with the current user.
 
 */
- (void)clearDeviceCache;


///-----------------------------
/// @name Subscribing to Updates
///-----------------------------

// Device Observation

// Device Manager will send updates for all properties, unless there is
// a nonzero amount of properties subscribed to

/**
 Adds property to the subscriptions list
 Device Manager will send updates for all properties, unless there is a nonzero amount of properties subscribed to.
 Check VNLProperty for list of convenience property keys
 
 @param propertyName The name of the property to be updated
 */
- (void)subscribeToUpdatesForProperty:(NSString *)propertyName;

/**
 Removes property from the subscriptions list
 Device Manager will send updates for all properties, unless there is a nonzero amount of properties subscribed to.
 
 @param propertyName The name of the property to be removed
 */
- (void)unsubscribeFromUpdatesForProperty:(NSString *)propertyName;

/**
 Adds multiple properties to the subscriptions list
 Device Manager will send updates for all properties, unless there is a nonzero amount of properties subscribed to.
 
 @param properties An array of the property names to be added
 */
- (void)subscribeToUpdatesForProperties:(NSArray *)properties;

/**
 Removes all properties from the subscriptons list and adds VNLPropertyNone to subscription list to stop all updates
 Device Manager will send updates for all properties, unless there is a nonzero amount of properties subscribed to.
 */
- (void)unsubscribeFromAllProperites;


- (void)subscribeSelector:(SEL)selector forProperty:(NSString *)property;

//- (NSString *)pidForProperty:(NSString *)property;

@end

