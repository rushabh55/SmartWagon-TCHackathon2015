//
//  VNLDeviceObserving.h
//  Vinli
//
//  Created by Phillip Bowden on 7/8/15.
//  Copyright © 2015 Vinli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VNLDeviceManager.h"

@class VNLPID;

/**
 `VNLDeviceObserving` is a protocol that provides callbacks to communicate with a VNLDeviceManager,
 including CBCentralManager lifecycle and VNLDevice lifecycle events.
 
 All protocol methods are optional
 */

@class VNLDeviceManager;


@protocol VNLDeviceObserving <NSObject>
@optional

///----------------------------------------
/// @name DeviceManager Bluetooth Lifecycle
///----------------------------------------

/**
 Notifys observer when the DeviceManager's CBCentralManager has entered PoweredOn state.
 Typical use case is to call VNLDeviceManager's scanForDevices method in this callback to begin
 connecting to nearby devices.
 
 @param deviceManager The VNLDeviceManager.
 */
- (void)deviceManagerDidInitialize:(VNLDeviceManager *)deviceManager;

/**
 Notifys observer when the DeviceManager has reset due to the CBCentralManager entering any state but PoweredOn.
 
 @param deviceManager The VNLDeviceManager.
 */
- (void)deviceManagerDidReset:(VNLDeviceManager *)deviceManager;

/**
 Notified observer when the DeviceManager begins scanning for nearby Vinli devices.
 
 @param deviceManager The VNLDeviceManager;
 */
- (void)deviceManagerDidStartScanningForDevices:(VNLDeviceManager *)deviceManager;

/**
 Notified observer when the DeviceManager begins scanning for nearby Vinli devices.
 
 @param deviceManager The VNLDeviceManager;
 */
- (void)deviceManagerDidStopScanningForDevices:(VNLDeviceManager *)deviceManager;


//// Might not need
- (void)deviceManager:(VNLDeviceManager *)deviceManager didDiscoverDevice:(VNLDevice *)device;
- (void)deviceManager:(VNLDeviceManager *)deviceManager didIdentifyDevice:(VNLDevice *)device;
////


///---------------------------
/// @name Device Lifecycle
///---------------------------


/**
 Implement this method to override auto connection to nearby Vinli devices. If this is not implemented the DeviceManager will
 connect to the closest valid Vinli device.
 
 @param deviceManager The VNLDeviceManager.
 @param device The device which will be connected.
 */
- (BOOL)deviceManager:(VNLDeviceManager *)deviceManager shouldConnectDevice:(VNLDevice *)device;

/**
 Notifies the observer that the DeviceManager has successfully made a connection to a Vinli device.
 The observer will now be updated about any updates to subscribed properties
 
 @param deviceManager The VNLDeviceManager.
 @param device The connected Vinli Device.
 */
- (void)deviceManager:(VNLDeviceManager *)deviceManager didConnectDevice:(VNLDevice *)device;

/**
 Notify the observer that the DeviceManager has successfully made a connection to a Vinli device.
 The observer will now be updated about any updates to subscribed properties
 
 @param deviceManager The VNLDeviceManager
 @param device The bluetooth device that failed to connect.
 @param error A failure error object
 */
- (void)deviceManager:(VNLDeviceManager *)deviceManager failedToConnectDevice:(VNLDevice *)device withError:(NSError *)error;


/**
 Notifies the observer that the DeviceManager has disconnected from a Vinli device.
 The observer will no longer be updated about any updates to subscribed properties
 
 @param deviceManager The VNLDeviceManager.
 @param device The disconnected Vinli Device.
 */
- (void)deviceManager:(VNLDeviceManager *)deviceManager didDisconnectDevice:(VNLDevice *)device;



///------------------------------------
/// @name Device Property Subscriptions
///------------------------------------

/**
 Notifies the observer that a Vinli device had been initialized. 
 VIN and ChipId characterisits can be read from the device.
 
 @param device The Vinli device.
 */
- (void)deviceDidInitialize:(VNLDevice *)device;

/**
 Notifies the observer that a subscribed property has been updated.
 
 @param device The Vinli device.
 @param updatedValue The value of the updated property
 @param property The VNLProperty that has been subscribed to.
 */
- (void)device:(VNLDevice *)device updatedValue:(id)value forProperty:(NSString *)property;

// PUMPKIN
- (void)device:(VNLDevice *)device updatedPid:(VNLPID *)pid forProperty:(NSString *)property;


/**
 Notifies the observer that a subscribed property has been updated.
 
 @param device The Vinli device.
 @param accelerometerInfo A struct containing the x, y, and z values returned from the Vinli device accelerometer.
 */
- (void)device:(VNLDevice *)device didUpdateAccelerometerState:(VNLAcceleration)accelerometerInfo;

/**
 Notifies the observer that a collison has been detected.
 
 @param device The device reporting the collision.
 */
- (void)deviceDidDetectCollision:(VNLDevice *)device;

/**
 Notifies the observer of the current trouble codes reported by the device.
 
 @param device The Vinli device.
 @param updatedValue The value of the updated property
 @param property The VNLProperty that has been subscribed to.
 */
- (void)device:(VNLDevice *)device didUpdateTroubleCodes:(NSArray *)codes;

/**
 Notifies the observer that a vehicle has powered on or off.
 
 @param device The Vinli device.
 @param vehicleOn BOOL representing the vehicle's power status
 */
- (void)device:(VNLDevice *)device didUpdateVehiclePowerStatus:(BOOL)vehicleOn;

/**
 Notifies the observer of the Vinli device's battery voltage.
 
 @param device The Vinli device.
 @param voltage Integer value of battery voltage.
 */
- (void)device:(VNLDevice *)device didUpdateBatterVoltage:(NSInteger)voltage;


/**
 TODO
 */
- (void)deviceDidUpdateSupportedPids:(VNLDevice *)device;

/**
 Subscribes to log messages from the Device Manager
 
 @param log a message
 */
- (void)deviceManager:(VNLDeviceManager *)deviceManager log:(NSString *)log;




///---------------
/// @name iBeacon
///---------------

- (void)didEnterRegion;
- (void)didExitRegion;



@end
