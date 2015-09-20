//
//  VNLDeviceManager.m
//  Vinli
//
//  Created by Laurence Andersen on 6/24/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import "VNLDeviceManager.h"
#import "VNLDevice.h"
#import "VNLDevicePickerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <VinliNet/VinliSDK.h>

#define ENABLE_DEBUG

#ifdef ENABLE_DEBUG
#define DebugLog(format, args...) \
NSLog(@"%s, line %d: " format "\n", \
__func__, __LINE__, ## args);
#else
#define DebugLog(format, args...) do {} while(0)
#endif


#if DEBUG
#define VNLDEVICEMANAGER_DEBUG_ALLDEVICESVALID             1
#define VNLDEVICEMANAGER_DEBUG_NOCACHE                     0
#define VNLDEVICEMANAGER_DEBUG_NOMEMCACHE                  1
#define VNLDEVICEMANAGER_DEBUG_CLEAR_BEACON_REGIONS        0
#define VNLDEVICEMANAGER_DEBUG_NOWIFI                      0
#define VNLDEVICEMANAGER_DEBUG_USEDEV_HOST                 0
#endif

static CBUUID *VNLServiceUUIDMainStream;

static CBUUID *VNLCharacteristicUUIDMainStream;
static CBUUID *VNLCharacteristicUUIDChipID;
static CBUUID *VNLCharacteristicUUIDVIN;
static CBUUID *VNLCharacteristicUUIDRPM;
static CBUUID *VNLCharacteristicUUIDTroubleCodes;
static CBUUID *VNLCharacteristicUUIDClearTroubleCodes;
static CBUUID *VNLCharacteristicUUIDAccelerometer;
static CBUUID *VNLCharacteristicUUIDCrash;
static CBUUID *VNLCharacteristicUUIDClearCrash;
static CBUUID *VNLCharacteristicUUIDSupportedPIDs;
static CBUUID *VNLCharacteristicUUIDVehiclePowerStatus;

static NSArray *VNLCharacteristicsPaired;

static NSString * const VNLDeviceManagerCachedDevicesKey = @"VNLDeviceManagerCachedDevicesKey";

@interface VNLDeviceManager () <CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate, VNLDevicePickerViewControllerDelegate>

@property CBCentralManager *bluetoothCentralManager;
@property CLLocationManager *locationManager;

@property (strong, nonatomic) dispatch_queue_t workerQueue;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;


@property (strong, nonatomic) NSMutableSet *subscribedProperties;
@property (strong, nonatomic) NSDictionary *vinliDevices;

@property (strong, nonatomic) VNLDevice* pairedDevice;
@property (strong, nonatomic) NSMutableArray* deviceMemCache;
@property (strong, nonatomic) VLService* service;
@property (assign, nonatomic) BOOL bluetoothManagerHasInitalized;
@property (assign, nonatomic) NSInteger scanCount;

@property (strong, nonatomic) NSMutableDictionary* unknownDevices;
@property (strong, nonatomic) NSMutableDictionary* propertySelectors;
@property (strong, nonatomic) NSMutableDictionary* PIDObjectMap;

//- (NSDictionary *)valuesForPIDData:(NSData *)data;
//- (id)valueForPIDValues:(VNLPIDValues)pidValues metadata:(NSDictionary *)pidMetadata;
//- (id)metadataForPIDType:(VNLPIDType)pidType;

- (void)reset;
- (void)findConnectedDevices;
- (void)scanForDevices;
- (void)addDeviceForBluetoothPeripheral:(CBPeripheral *)peripheral;
- (VNLDevice *)deviceForIdentifier:(NSString *)identifier;
- (VNLDevice *)deviceForBluetoothPeripheral:(CBPeripheral *)peripheral;

- (void)readTroubleCodesCharacteristicForDeviceWithIdentifier:(NSString *)identifier;

- (void)performBlockOnDelegateQueue:(void (^)())block;

@end

@interface VNLDevice (Protected)

@property (strong, nonatomic) CBPeripheral *peripheral;

@property (nonatomic, readonly) CBService *mainService;

@property (nonatomic, readonly) CBCharacteristic *streamCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *chipIDCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *troubleCodesCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *VINCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *RPMCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *accelerometerCharacteristic;

@property (strong, nonatomic) NSString *chipID;
@property (strong, nonatomic) NSString *vehicleIdentificationNumber;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)updateValue:(id)value forProperty:(NSString *)propertyName;

- (void)updateDiagnosticTroubleCodesWithData:(NSData *)data;
- (void)addDiagnosticTroubleCode:(NSString *)troubleCode;

- (void)updateAccelerometerInfoWithData:(NSData *)data;

- (void)setRSSI:(NSNumber *)RSSI;

@end


@interface VNLDevice (Bluetooth)

@property (nonatomic, readonly) CBService *mainService;

@property (nonatomic, readonly) CBCharacteristic *streamCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *chipIDCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *troubleCodesCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *clearTroubleCodesCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *VINCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *RPMCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *accelerometerCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *clearCrashCharacteristic;

@end


@interface NSArray (VNLConveniences)

- (CBAttribute *)VNL_objectMatchingCBUUID:(CBUUID *)UUID;

@end


@interface CBPeripheral (VNLConveniences)

- (CBService *)VNL_serviceWithUUID:(CBUUID *)UUID;

@end


@interface CBService (VNLConveniences)

- (CBCharacteristic *)VNL_characteristicWithUUID:(CBUUID *)UUID;

@end

@implementation VNLDeviceManager

#pragma mark - Accessors and Mutators

- (void)setDeviceObserver:(id<VNLDeviceObserving>)deviceObserver
{
    _deviceObserver = deviceObserver;
    if (_bluetoothManagerHasInitalized && [deviceObserver respondsToSelector:@selector(deviceManagerDidInitialize:)])
    {
        [self performBlockOnDelegateQueue:^{
            [_deviceObserver deviceManagerDidInitialize:self];
        }];
    }
}

- (VLService *)service
{
    if (!_service)
    {
        _service = [[VLService alloc] initWithSession:[[VLSession alloc] initWithAccessToken:self.accessToken]];
#if VNLDEVICEMANAGER_DEBUG_USEDEV_HOST
        _service.host = @"-dev.vin.li";
#endif
    }
    return _service;
}

#pragma mark - Initialization

+ (void)initialize
{
    VNLServiceUUIDMainStream = [CBUUID UUIDWithString:@"e4888211-50f0-412d-9c9a-75015eb36586"];
    
    VNLCharacteristicUUIDMainStream = [CBUUID UUIDWithString:@"180c5783-aa91-43c0-a8f3-d12a7668b339"];
    VNLCharacteristicUUIDChipID = [CBUUID UUIDWithString:@"a9b47333-f59f-4390-82a3-e5af6b8b75dc"];
    
    VNLCharacteristicUUIDVIN = [CBUUID UUIDWithString:@"707d0997-0880-4ab7-b900-c779bcb08a11"];
    VNLCharacteristicUUIDRPM = [CBUUID UUIDWithString:@"3197f839-9920-4fea-a3a6-f3d45c3eaa97"];
    VNLCharacteristicUUIDTroubleCodes = [CBUUID UUIDWithString:@"82e6de6b-b610-455e-bf53-0166f4d6e493"];
    VNLCharacteristicUUIDClearTroubleCodes = [CBUUID UUIDWithString:@"00f8e5ab-f0d3-42f7-bc42-de3696b0a522"];
    
    VNLCharacteristicUUIDAccelerometer = [CBUUID UUIDWithString:@"51c5848d-40ec-4d0c-918c-628db566432c"];
    VNLCharacteristicUUIDCrash = [CBUUID UUIDWithString:@"5d053d4d-0420-4e44-b386-c97d3cab5845"];
    VNLCharacteristicUUIDClearCrash = [CBUUID UUIDWithString:@"0d24c32c-46d8-4576-bb23-83f8d5504a73"];
    
    VNLCharacteristicUUIDSupportedPIDs = [CBUUID UUIDWithString:@"86754999-7269-4e55-b4e7-01c017a16f3a"];
    VNLCharacteristicUUIDVehiclePowerStatus = [CBUUID UUIDWithString:@"8b56f17c-43e6-47b8-8e0e-010c57bafc4a"];
    
     VNLCharacteristicsPaired = @[VNLCharacteristicUUIDMainStream, VNLCharacteristicUUIDRPM, VNLCharacteristicUUIDVIN, VNLCharacteristicUUIDTroubleCodes, VNLCharacteristicUUIDClearTroubleCodes, VNLCharacteristicUUIDAccelerometer, VNLCharacteristicUUIDCrash, VNLCharacteristicUUIDClearCrash, VNLCharacteristicUUIDSupportedPIDs, VNLCharacteristicUUIDVehiclePowerStatus];
}

- (instancetype)initWithPIDInfo:(NSDictionary *)PIDInfo accessToken:(nonnull NSString *)token
{
    if (!(self = [super init]) || token.length <= 0)
    {
        //return nil;
    }
    
    if (!PIDInfo)
    {
        NSString *pidInfoPath = [[NSBundle mainBundle] pathForResource:@"pids" ofType:@"json"];
        NSData *pidData = [NSData dataWithContentsOfFile:pidInfoPath];
        PIDInfo = [NSJSONSerialization JSONObjectWithData:pidData options:0 error:NULL];
    }
    
    [VNLPID setPIDInfo:PIDInfo];
    _accessToken = token;
    
    NSString *workerQueueName = @"VNLDeviceManager Worker Queue";
    _workerQueue = dispatch_queue_create([workerQueueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    
    NSString *delegateQueueName = @"VNLDeviceManager Delegate Queue";
    _delegateQueue = dispatch_queue_create([delegateQueueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_delegateQueue, dispatch_get_main_queue());
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager startUpdatingLocation];

    _locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    
    VLUserCache* userCache = [VLUserCache getUserWithAccessToken:_accessToken];
    if (!userCache)
    {
        weakify(self);
        [self.service getUserOnSuccess:^(VLUser *user, NSHTTPURLResponse *response) {
            strongify(self);
            
            VLUserCache* newUser = [[VLUserCache alloc] init];
            newUser.accessToken = _accessToken;
            newUser.userId = user.userId;
            [newUser save];
            
            [self performBlockOnInternalQueue:^{
                [self initalizeBluetoohManagerAndStartMonitoring];
            }];
            
        } onFailure:^(NSError *error, NSHTTPURLResponse *response, NSString *bodyString) {
            NSLog(@"Failure getting User");
        }];
    }
    else
    {
        [self initalizeBluetoohManagerAndStartMonitoring];
    }
    
    _unknownDevices = [NSMutableDictionary new];
    _propertySelectors = [NSMutableDictionary new];

    
    return self;
}

- (void)initalizeBluetoohManagerAndStartMonitoring
{
     _bluetoothCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_workerQueue];
    
    NSUUID* VinliUUID = [[NSUUID alloc] initWithUUIDString:@"e2c56db5-dffb-48d2-b060-d0f5a71096e0"];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:VinliUUID identifier:@"com.vinli.vinliregion"];
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    
    
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];

}

- (instancetype)initWithAccessToken:(nonnull NSString *)token
{
    return [self initWithPIDInfo:nil accessToken:token];
}


- (void)reset
{
    NSLog(@"DeviceManager reset");
    _scanCount = 0;
    
    @synchronized (_vinliDevices) {
        _vinliDevices = nil;
    }
    
    @synchronized (_subscribedProperties) {
        _subscribedProperties = nil;
    }
    
    @synchronized (_pairedDevice)
    {
        _pairedDevice = nil;
    }
    
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManagerDidReset:)]) {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManagerDidReset:self];
        }];
    }
}


#pragma mark - Subscription Management

- (void)subscribeToUpdatesForProperties:(NSArray *)properties
{
    @synchronized (_subscribedProperties)
    {
        if (!_subscribedProperties){
            _subscribedProperties = [[NSMutableSet alloc] init];
        }
        
        [_subscribedProperties addObjectsFromArray:properties];
    }
}

- (void)subscribeToUpdatesForProperty:(NSString *)propertyName
{
    @synchronized (_subscribedProperties) {
        if (!_subscribedProperties) {
            _subscribedProperties = [[NSMutableSet alloc] init];
        }
        
        [_subscribedProperties addObject:propertyName];
    }
}

- (void)unsubscribeFromUpdatesForProperty:(NSString *)propertyName
{
    @synchronized (_subscribedProperties) {
        [_subscribedProperties removeObject:propertyName];
    }
}

- (void)unsubscribeFromAllProperites
{
    @synchronized (_subscribedProperties)
    {
        [_subscribedProperties removeAllObjects];
    }
    [self subscribeToUpdatesForProperty:VNLPropertyNone];
}

- (BOOL)shouldSendUpdateToDeviceObserverForProperty:(NSString *)propertyName
{
    @synchronized (_subscribedProperties) {
        if (_subscribedProperties.count == 0) {
            return YES;
        }
        
        return [_subscribedProperties containsObject:propertyName];
    }
}

#pragma mark - Device Management

- (void)findConnectedDevices
{
    NSArray *peripherals = [_bluetoothCentralManager retrieveConnectedPeripheralsWithServices:@[VNLServiceUUIDMainStream]];
    
    [peripherals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBPeripheral *currentPeripheral = (CBPeripheral *)obj;
        [self addDeviceForBluetoothPeripheral:currentPeripheral];
    }];
}

- (void)scanForDevices
{
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManagerDidStartScanningForDevices:)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManagerDidStartScanningForDevices:self];
        }];
    }
    
    weakify(self);
    
    __block void (^timer)();
    timer = ^{
        
        strongify(self)
        [self.bluetoothCentralManager scanForPeripheralsWithServices:nil options:nil];//@[VNLServiceUUIDMainStream] options:nil];
        
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, _workerQueue, ^(void){
            
            if (!self) {
                timer = nil;
                return;
            }
            
            if ([self shouldFinishScanning])
            {
                timer = nil;
                if (![self.deviceObserver respondsToSelector:@selector(deviceManager:shouldConnectDevice:)]) {
                    [self pairWithAvailableDevices];
                }
            }
            else {
                // Schedule the timer again
                timer();
            }
        });
    };
    
    if (_pairedDevice) {
        return;
    }
    
    timer();
}

- (BOOL)shouldFinishScanning
{
    _scanCount++;
    NSLog(@"Scanning");
    if ([self.deviceObserver respondsToSelector:@selector(deviceManager:log:)])
    {
        [self performBlockOnDelegateQueue:^{
             [self.deviceObserver deviceManager:self log:[NSString stringWithFormat:@"Scanning...%li : devices = %li", (long)_scanCount, (unsigned long)_vinliDevices.allValues.count]];
        }];
    }
    
    BOOL allDevicesIdentified = YES;
    
    @synchronized (self.vinliDevices)
    {
        if (self.vinliDevices.allValues.count <= 0)
        {
            NSLog(@"No devices found during scan");
            if (_scanCount > 10)
            {
                //[self reset];
            }
            return NO;
        }

        for (VNLDevice* device in _vinliDevices.allValues)
        {
            if (device.chipID.length == 0)
            {
                allDevicesIdentified = NO;
                break;
            }
        }
    }
    
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManager:shouldConnectDevice:)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.vinliDevices.allValues enumerateObjectsUsingBlock:^(VNLDevice *device, NSUInteger idx, BOOL *stop) {
                if([self.deviceObserver deviceManager:self shouldConnectDevice:device])
                {
                    [self performBlockOnInternalQueue:^{
                        [self pairWithDevice:device];
                    }];
                }
            }];
        }];
    }
    
    
#if DEBUG
    NSLog(@"All devices %@", _vinliDevices);
    NSMutableArray* identifiedDevices = [NSMutableArray new];
    [self.vinliDevices.allValues enumerateObjectsUsingBlock:^(VNLDevice* device, NSUInteger idx, BOOL *stop) {
        if (device.chipID)
        {
            [identifiedDevices addObject:device.chipID];
        }
    }];
    NSLog(@"Initial scan Identified Devices = %@", identifiedDevices);
#endif
    
    NSLog(@"All devices identified = %@", allDevicesIdentified ? @"YES" : @"NO");
    return allDevicesIdentified;
    
}


- (void)pairWithAvailableDevices
{
    [self performBlockOnInternalQueue:^{
        [self _pairWithAvailableDevices];
    }];
}

- (void)_pairWithAvailableDevices
{
    if (_pairedDevice) {
        return;
    }

    
#if VNLDEVICEMANAGER_DEBUG_NOCACHE
#else
    // Check Cache
    VLUserCache* userCache = [VLUserCache getUserWithAccessToken:self.accessToken];
    
    //NSMutableArray* validCachedDevices = [NSMutableArray new];
    NSDictionary* cachedDevices = [[NSUserDefaults standardUserDefaults] objectForKey:VNLDeviceManagerCachedDevicesKey];
    NSDictionary* userDeviceCache = [cachedDevices objectForKey:userCache.userId];
    if (userDeviceCache.allValues > 0)
    {
        BOOL deviceFound = NO;
        for (VNLDevice* device in _vinliDevices.allValues)
        {
            if (userDeviceCache[device.chipID])
            {
                device.deviceMetaData = [[VNLDeviceMetaData alloc] initWithDictionary:userDeviceCache[device.chipID]];
                NSLog(@"Pairing with cached device - %@", device.chipID);
                [self pairWithDevice:device];
                deviceFound = YES;
            }
        }
        if (!deviceFound) {
            [self scanForDevices];
        }
        return;
    }
//    if (userDeviceCache)
//    {
//        for (VNLDevice* device in _vinliDevices.allValues)
//        {
//            if (userDeviceCache[device.chipID])
//            {
//                device.deviceMetaData = [[VNLDeviceMetaData alloc] initWithDictionary:userDeviceCache[device.chipID]];
//                [validCachedDevices addObject:device];
//            }
//        }
//    }
//    
//    if (validCachedDevices.count > 0)
//    {
//        NSLog(@"Pairing with cached device");
//        if (validCachedDevices.count == 1)
//        {
//            [self pairWithDevice:validCachedDevices[0]];
//        }
//        else
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                 [VNLDevicePickerViewController instantiateAndPresentDevicePickerWithTarget:[[UIApplication sharedApplication].windows[0] rootViewController] delegate:self devices:validCachedDevices completion:nil];
//            });
//        }
//        return;
//    }
#endif

   
    dispatch_async(dispatch_get_main_queue(), ^{
    
    weakify(self)
    [self.service getDevicesOnSuccess:^(VLDevicePager *devicePager, NSHTTPURLResponse *response) {
        
        strongify(self)
        [self performBlockOnInternalQueue:^{
            
        
        NSMutableArray* validDevices = [NSMutableArray new];
        for (VLDevice* userDevice in devicePager.devices)
        {
            for (VNLDevice* device in self.vinliDevices.allValues)
            {
                if ([userDevice.chipID isEqualToString:device.chipID])
                {
                    device.deviceMetaData = [[VNLDeviceMetaData alloc] initWithDictionary:  @{@"name" : userDevice.name && userDevice.name.length > 0 ? userDevice.name : @"Unknown Device", @"iconURL" : userDevice.iconURL ? userDevice.iconURL : @"", @"deviceId" : userDevice.deviceId}];
                    [validDevices addObject:device];
                }
            }
        }
        
#if VNLDEVICEMANAGER_DEBUG_ALLDEVICESVALID
        validDevices = [self.vinliDevices.allValues mutableCopy];
#endif
        
        NSLog(@"Devices ready to connect: %@", validDevices);
        
         // TODO notify delegate that we have identified devices
        
        if (validDevices.count == 1)
        {
            [self pairWithDevice:validDevices[0]];
        }
        else if (validDevices.count > 1)
        {
            // Launch picker
            dispatch_async(dispatch_get_main_queue(), ^{
                [VNLDevicePickerViewController instantiateAndPresentDevicePickerWithTarget:[[UIApplication sharedApplication].windows[0] rootViewController] delegate:self devices:validDevices completion:nil];
            });
        }
        else
        {
            if ([self.deviceObserver respondsToSelector:@selector(deviceManager:log:)])
            {
                [self.deviceObserver deviceManager:self log:@"No valid devices found"];
                [self scanForDevices];
            }
        }
    }];
        
    } onFailure:^(NSError *error, NSHTTPURLResponse *response, NSString *bodyString) {
        [self scanForDevices];
        DebugLog(@"Failed to retrieve device information: %@", error);
    }];
 });
    
}

- (void)clearDeviceCache
{
    VLUserCache* userCache = [VLUserCache getUserWithAccessToken:self.accessToken];
    if (!userCache || userCache.userId.length == 0) {
        return;
    }

    NSMutableDictionary* deviceCache = [[[NSUserDefaults standardUserDefaults] objectForKey:VNLDeviceManagerCachedDevicesKey] mutableCopy];
    [deviceCache removeObjectForKey:userCache.userId];
    [[NSUserDefaults standardUserDefaults] setObject:deviceCache forKey:VNLDeviceManagerCachedDevicesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cachePairedDevice
{
    @synchronized(_pairedDevice)
    {
        if (!_pairedDevice || _pairedDevice.chipID.length == 0) { return; }
        NSMutableDictionary* deviceCache = [[[NSUserDefaults standardUserDefaults] objectForKey:VNLDeviceManagerCachedDevicesKey] mutableCopy];
        if (!deviceCache)
        {
            deviceCache = [NSMutableDictionary new];
        }
        
        VLUserCache* userCache = [VLUserCache getUserWithAccessToken:self.accessToken];
        if (!userCache || userCache.userId.length == 0) {
            return;
        }
        
        NSString* userKey = userCache.userId;
        
        if (_pairedDevice.deviceMetaData)
        {
            NSDictionary* deviceDataDic = @{_pairedDevice.chipID : [_pairedDevice.deviceMetaData toDictionary]};
            [deviceCache setObject:deviceDataDic forKey:userKey];
        }
        
        /*
        NSMutableDictionary* userDeviceCache = [[deviceCache objectForKey:userKey] mutableCopy];
        if (!userDeviceCache)
        {
            userDeviceCache = [NSMutableDictionary new];
            [deviceCache setObject:userDeviceCache forKey:userKey];
            
        }
        
        if (_pairedDevice.deviceMetaData)
        {
            [userDeviceCache setObject:[_pairedDevice.deviceMetaData toDictionary] forKey:_pairedDevice.chipID];
        }
        
        [deviceCache setObject:userDeviceCache forKey:userKey];
         */
        
        //[[NSUserDefaults standardUserDefaults] setObject:deviceCache forKey:VNLDeviceManagerCachedDevicesKey];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)pairWithDevice:(VNLDevice *)device
{
    [self performBlockOnInternalQueue:^{
        [self _pairWithDevice:device];
    }];
}

- (void)_pairWithDevice:(VNLDevice *)device
{
    if (_pairedDevice) {
        return;
    }
    
    _scanCount = 0;
    
    @synchronized(_vinliDevices)
    {
        if (![_vinliDevices.allValues containsObject:device])
        {
            NSLog(@"Failed to set Selected Device (%@) - device no longer connected", device);
        }
//        if (![_vinliDevices objectForKey:device.identifier])
//        {
//            NSLog(@"Failed to set Selected Device (%@) - device no longer connected", device);
//        }
    }
    
    _pairedDevice = device;
    
#if VNLDEVICEMANAGER_DEBUG_NOCACHE
#else
    [self cachePairedDevice];
#endif
    
    //Memory Cache
    if (!_deviceMemCache)
    {
        _deviceMemCache = [NSMutableArray new];
        [_deviceMemCache addObject:device.chipID];
    }
    
    
    CBService *streamService = [_pairedDevice.peripheral VNL_serviceWithUUID:VNLServiceUUIDMainStream];
    [_pairedDevice.peripheral discoverCharacteristics:VNLCharacteristicsPaired forService:streamService];
    
    [self stopScanningForDevices];
    
    for (VNLDevice* d in _vinliDevices.allValues)
    {
        if (device != d)
        {
            [self.bluetoothCentralManager cancelPeripheralConnection:d.peripheral];
        }
    }
    
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManager:didConnectDevice:)]) {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManager:self didConnectDevice:device];
        }];
    }
    
    
#if VNLDEVICEMANAGER_DEBUG_NOWIFI
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleIdentifier isEqualToString:@"li.vin.MyVinli"])
    {
        NSString* urlStr = [NSString stringWithFormat:@"myvinli://?bluetooth=yes&token=%@&deviceChipId=%@&redirectUri=%@", self.accessToken, device.chipID, @"testApp://"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
#else
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.service getDeviceCapabilitiesWithId:device.deviceMetaData.deviceId onSuccess:^(NSDictionary *capabilites, NSHTTPURLResponse *response) {
        if (capabilites[@"liveTelemetry"] && ![capabilites[@"liveTelemetry"] boolValue])
        {
             NSLog(@"NO WIFI - need to call myvinl");
        }
        else
        {
            NSLog(@"Device is WIFI connected");
        }

        
    } onFailure:^(NSError *error, NSHTTPURLResponse *response, NSString *bodyString) {
        DebugLog(@"%@", error);
    }];
        
    });
#endif
}

- (void)stopScanningForDevices
{
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManagerDidStopScanningForDevices:)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManagerDidStopScanningForDevices:self];
        }];
    }
    [self.bluetoothCentralManager stopScan];
    
    [self.unknownDevices removeAllObjects];
}

- (void)connectDevice:(VNLDevice *)device
{
    if (device.connected || !device.peripheral) {
        return;
    }
    
    [self.bluetoothCentralManager connectPeripheral:device.peripheral options:nil];
}

- (void)addDeviceForBluetoothPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        return;
    }
    
    __block BOOL deviceAlreadyConnected = NO;
    [self.vinliDevices enumerateKeysAndObjectsUsingBlock:^(id key, VNLDevice* d, BOOL *stop) {
        if ([d.peripheral.identifier isEqual:peripheral.identifier])
        {
            deviceAlreadyConnected = YES;
            *stop = YES;
        }
    }];
    
    if (deviceAlreadyConnected) {
        return;
    }
    
    VNLDevice *device = [[VNLDevice alloc] initWithPeripheral:peripheral];
    
    @synchronized (_vinliDevices) {
        NSMutableDictionary *mutableDevices = _vinliDevices ? [_vinliDevices mutableCopy] : [[NSMutableDictionary alloc] init];
        [mutableDevices setObject:device forKey:device.identifier];
        _vinliDevices = mutableDevices;
    }
    
    [self performBlockOnInternalQueue:^{
        [self connectDevice:device];
    }];
    
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManager:didDiscoverDevice:)]) {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManager:self didDiscoverDevice:device];
            
        }];
    }

}

- (VNLDevice *)deviceForIdentifier:(NSString *)identifier
{
    if (!identifier) {
        return nil;
    }
    
    return [self.vinliDevices objectForKey:identifier];
}

- (VNLDevice *)deviceForBluetoothPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        return nil;
    }
    
    return [self.vinliDevices objectForKey:[peripheral.identifier UUIDString]];
}

- (void)didIdentifyDevice:(VNLDevice *)device
{
    if (!device.chipID) { return; }
    //NSLog(@"Did identify device: %@", device);
    
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManager:didIdentifyDevice:)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManager:self didIdentifyDevice:device];
        }];
    }
    
    [self performBlockOnInternalQueue:^{
        
    
    if (_pairedDevice)
    {
        if (device != _pairedDevice)
        {
            [self.bluetoothCentralManager cancelPeripheralConnection:device.peripheral];
        }
    }
    else
    {
#if VNLDEVICEMANAGER_DEBUG_NOMEMCACHE
#else
        // Check memory cache
        if ([_deviceMemCache containsObject:device.chipID])
        {
            // TODO: load cached device info
            if ([self.deviceObserver respondsToSelector:@selector(deviceManager:log:)])
            {
                [self performBlockOnDelegateQueue:^{
                    [self.deviceObserver deviceManager:self log:@"Pairing with memcached device"];
                }];
              
            }
            NSLog(@"Pairing with memcached device");
            [self pairWithDevice:device];
        }
#endif
    }
    }];
    
}

#pragma mark - Characteristics

- (void)readTroubleCodesCharacteristicForDeviceWithIdentifier:(NSString *)identifier
{
    VNLDevice *device = [self deviceForIdentifier:identifier];
    if (!device) {
        return;
    }
    
    CBCharacteristic *troubleCodesCharacteristic = device.troubleCodesCharacteristic;
    if (!troubleCodesCharacteristic) {
        return;
    }
    
    [device.peripheral readValueForCharacteristic:troubleCodesCharacteristic];
}

#pragma mark - Queues

- (void)performBlockOnDelegateQueue:(void (^)())block
{
    [NSThread isMainThread] ? block() : dispatch_async(self.delegateQueue, block);
}

- (void)performBlockOnInternalQueue:(void (^)())block
{
    dispatch_async(self.workerQueue, block);
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)manager
{
    if (manager != _bluetoothCentralManager) {
        return;
    }
    
    switch (manager.state) {
        case CBCentralManagerStatePoweredOn:
            
            if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManagerDidInitialize:)]) {
                [self performBlockOnDelegateQueue:^{
                    [self findConnectedDevices];
                    [self.deviceObserver deviceManagerDidInitialize:self];
                }];
            } else { self.bluetoothManagerHasInitalized = YES;}
            
            break;
        default:
            [self reset];
            break;
    }
}

- (void)centralManager:(CBCentralManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (manager != _bluetoothCentralManager) {
        return;
    }
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    //NSLog(@"Discover peripheral = %@", localName);
    
    
    if (([self hasVinliIdentifier:peripheral.name] || [self hasVinliIdentifier:localName]) && peripheral.state == CBPeripheralStateDisconnected)
    {
        [self addDeviceForBluetoothPeripheral:peripheral];
        return;
    }
    
    if (!peripheral.name)
    {
        [self.unknownDevices setObject:peripheral forKey:peripheral.identifier];
        [self.bluetoothCentralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)manager didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"peripheral name = %@", peripheral.name);
    
    if ([self hasVinliIdentifier:peripheral.name])
    {
        [self addDeviceForBluetoothPeripheral:peripheral];
    }
    else
    {
        [self.bluetoothCentralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[VNLServiceUUIDMainStream]];
    [peripheral readRSSI];
    
    VNLDevice *device = [self deviceForBluetoothPeripheral:peripheral];
    if (!device) {
        return;
    }
}

- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    if (![self hasVinliIdentifier:peripheral.name]) {
        return;
    }
    
    
    VNLDevice *device = [self deviceForBluetoothPeripheral:peripheral];
    if (!device) {
        return;
    }
    
    NSString* disconnect = [NSString stringWithFormat:@"Diconnecting device: %@",device];
    if ([self.deviceObserver respondsToSelector:@selector(deviceManager:log:)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManager:self log:disconnect];
        }];
    }
    
    @synchronized (_vinliDevices)
    {
        NSMutableDictionary* devices = [_vinliDevices mutableCopy];
        [devices removeObjectForKey:device.identifier];
        _vinliDevices = devices;
    }
    
        
    @synchronized (_pairedDevice)
    {
        if (_pairedDevice && [_pairedDevice isEqual:device])
        {
            _pairedDevice = nil;
            [self scanForDevices];
            
            if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManager:didDisconnectDevice:)]) {
                if (!device) {
                    return;
                }
                [self performBlockOnDelegateQueue:^{
                    [self.deviceObserver deviceManager:self didDisconnectDevice:device];
                }];
            }

        }
    }
}

- (void)centralManager:(CBCentralManager *)manager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceManager:failedToConnectDevice:withError:)]) {
        VNLDevice *device = [self deviceForBluetoothPeripheral:peripheral];
        if (!device) {
            return;
        }
        
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver deviceManager:self failedToConnectDevice:device withError:error];
        }];
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", error);
    }
    
    CBService *streamService = [peripheral VNL_serviceWithUUID:VNLServiceUUIDMainStream];
    if (streamService)
    {
        [peripheral discoverCharacteristics:@[VNLCharacteristicUUIDChipID] forService:streamService];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", error);
    }
    
    VNLDevice *device = [self deviceForBluetoothPeripheral:peripheral];
    if (!device) {
        return;
    }
    
    CBCharacteristic *chipIDCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDChipID];
    if (chipIDCharacteristic) {
        [peripheral readValueForCharacteristic:chipIDCharacteristic];
    }
    
    CBCharacteristic *VINCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDVIN];
    if (VINCharacteristic) {
        [peripheral readValueForCharacteristic:VINCharacteristic];
    }
    
    [self readTroubleCodesCharacteristicForDeviceWithIdentifier:device.identifier];
    
    CBCharacteristic *streamCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDMainStream];
    if (streamCharacteristic) {
        [peripheral setNotifyValue:YES forCharacteristic:streamCharacteristic];
    }
    
    CBCharacteristic *RPMCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDRPM];
    if (RPMCharacteristic) {
        [peripheral setNotifyValue:YES forCharacteristic:RPMCharacteristic];
    }
    
    CBCharacteristic *accelerometerCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDAccelerometer];
    if (accelerometerCharacteristic) {
        [peripheral setNotifyValue:YES forCharacteristic:accelerometerCharacteristic];
    }
    
    CBCharacteristic *supportedPidsCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDSupportedPIDs];
    if (supportedPidsCharacteristic)
    {
        [peripheral readValueForCharacteristic:supportedPidsCharacteristic];
    }
    
    CBCharacteristic *vehiclePowerStatus = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDVehiclePowerStatus];
    if (vehiclePowerStatus)
    {
        [peripheral readValueForCharacteristic:vehiclePowerStatus];
    }
    
    /*CBCharacteristic *crashCharacteristic = [service VNL_characteristicWithUUID:VNLCharacteristicUUIDCrash];
    if (crashCharacteristic) {
        [peripheral setNotifyValue:YES forCharacteristic:crashCharacteristic];
    }*/
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error updating characteristic value: %@", error);
    }
    
    VNLDevice *device = [self deviceForBluetoothPeripheral:peripheral];
    if (!device) {
        return;
    }
    
    NSString* rawValueStr = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
    //NSLog(@"RAW DATA: %@", rawValueStr);
    
    if ([characteristic.UUID isEqual:VNLCharacteristicUUIDChipID]) {
          device.chipID = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
         [self didIdentifyDevice:device];
    } else if ([characteristic.UUID isEqual:VNLCharacteristicUUIDVIN]) {
        BOOL notifyDelegate = (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceDidInitialize:)]);
        
        [self performBlockOnDelegateQueue:^{
            device.vehicleIdentificationNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
        
            if (notifyDelegate) {
                [self.deviceObserver deviceDidInitialize:device];
            }
        }];
    } else if ([characteristic.UUID isEqual:VNLCharacteristicUUIDAccelerometer]) {
        BOOL previousCollisionValue = device.collisionDetected;
        BOOL notifyCollisionDelegate = (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceDidDetectCollision:)]);
        
        BOOL notifyAccelerometerDelegate = (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:didUpdateAccelerometerState:)]);
        
        [self performBlockOnDelegateQueue:^{
            [device updateAccelerometerInfoWithData:characteristic.value];
            
            if (notifyAccelerometerDelegate) {
                [self.deviceObserver device:device didUpdateAccelerometerState:device.accelerometerInfo];
            }
            
            if (notifyCollisionDelegate && (!previousCollisionValue && device.collisionDetected)) {
                [self.deviceObserver deviceDidDetectCollision:device];
            }
        }];
    } else if ([characteristic.UUID isEqual:VNLCharacteristicUUIDTroubleCodes]) {
        BOOL notifyDelegate = (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:didUpdateTroubleCodes:)]);
        
        [self performBlockOnDelegateQueue:^{
            [device updateDiagnosticTroubleCodesWithData:characteristic.value];
            
            NSArray *troubleCodes = device.diagnosticTroubleCodes;
            if (troubleCodes.count < 1) {
                return;
            }
          
            if (notifyDelegate && (troubleCodes.count > 0)) {
                [self.deviceObserver device:device didUpdateTroubleCodes:troubleCodes];
            }
        }];
        
        NSString *deviceIdentifier = device.identifier;
        NSTimeInterval pollingInterval = device.diagnosticTroubleCodePollingInterval;
        
        if (pollingInterval > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pollingInterval * NSEC_PER_SEC)), self.workerQueue, ^{
                [self readTroubleCodesCharacteristicForDeviceWithIdentifier:deviceIdentifier];
            });
        }
    } else if ([characteristic.UUID isEqual:VNLCharacteristicUUIDSupportedPIDs])
    {
        device.supportedPidsHexString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(deviceDidUpdateSupportedPids:)])
        {
            [self performBlockOnDelegateQueue:^{
                [self.deviceObserver deviceDidUpdateSupportedPids:device];
            }];
        }
        
    }
    else if ([characteristic.UUID isEqual:VNLCharacteristicUUIDVehiclePowerStatus])
    {
        if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:didUpdateVehiclePowerStatus:)])
        {
            [self performBlockOnDelegateQueue:^{
                NSString* dataStr = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
                [self.deviceObserver device:device didUpdateVehiclePowerStatus:[dataStr boolValue]];
            }];
        }
    }
    else if ([characteristic.UUID isEqual:VNLCharacteristicUUIDMainStream] || [characteristic.UUID isEqual:VNLCharacteristicUUIDRPM]) {
        
        //NSLog(@"Raw value = %@", rawValueStr);
        
        if ([rawValueStr containsString:@"P"])
        {
            if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:didUpdateVehiclePowerStatus:)])
            {
                [self performBlockOnDelegateQueue:^{
                    [self.deviceObserver device:device didUpdateVehiclePowerStatus:[rawValueStr containsString:@"1"]];
                }];
                
            }
            
            return;
        }
        else if ([rawValueStr containsString:@"B:"])
        {
            //.006
            char *buffer = malloc(characteristic.value.length);
            [characteristic.value getBytes:buffer range:NSMakeRange(2, 4)];
            NSInteger voltage = (NSInteger)strtol(buffer, NULL, 16);
            voltage *= .006f;
            
            if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:didUpdateBatterVoltage:)])
            {
                [self performBlockOnDelegateQueue:^{
                    [self.deviceObserver device:device didUpdateBatterVoltage:voltage];
                }];
            }
            
            return;
        }
        
        NSDictionary *values = [VNLPID valuesForPIDData:characteristic.value];
        
        BOOL delegateResponds = (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:updatedValue:forProperty:)]);
        [self performBlockOnDelegateQueue:^{
            [values enumerateKeysAndObjectsUsingBlock:^(id key, VNLPID* pid, BOOL *stop)
            {
                [device updateValue:pid.rawValue forProperty:key];
                
                if (delegateResponds && [self shouldSendUpdateToDeviceObserverForProperty:key]) {
                    [self.deviceObserver device:device updatedValue:pid.rawValue forProperty:key];
                }
                
                // Selectors
//                if (self.propertySelectors[key])
//                {
//                    SEL propertySelector = [[self.propertySelectors objectForKey:key] pointerValue];
//                    if ([self.deviceObserver respondsToSelector:propertySelector]) {
//                        [self.deviceObserver performSelector:propertySelector];
//                    }
//                }
                
            }];
        }];
        
        
        if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(device:updatedPid:forProperty:)])
        {
            [self performBlockOnDelegateQueue:^{
                
                [values enumerateKeysAndObjectsUsingBlock:^(id key, VNLPID* pid, BOOL *stop) {
                    [device updateValue:pid.rawValue forProperty:key];
                    
                    if ([self shouldSendUpdateToDeviceObserverForProperty:key])
                    {
                        [self.deviceObserver device:device updatedPid:pid forProperty:key];
                    }
                    
                }];
            }];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if (error) {
        return;
    }
    
    VNLDevice *device = [self deviceForBluetoothPeripheral:peripheral];
    if (!device) {
        return;
    }
    
    [device setRSSI:RSSI];
}

- (void)clearDeviceTroubleCodes
{
    if (!self.pairedDevice) {
        return;
    }
    
    CBCharacteristic* clearTroubleCodesCharacteristic = _pairedDevice.clearTroubleCodesCharacteristic;
    if (!clearTroubleCodesCharacteristic)
    {
        return;
    }
    NSString* dataStr = @"1";
    [_pairedDevice.peripheral writeValue:[dataStr dataUsingEncoding:NSASCIIStringEncoding] forCharacteristic:clearTroubleCodesCharacteristic type:CBCharacteristicWriteWithResponse];

}

- (void)clearDeviceCrash
{
    if (!_pairedDevice) {
        return;
    }
    
    CBCharacteristic* clearCrashCharacteristic = _pairedDevice.clearCrashCharacteristic;
    if (!clearCrashCharacteristic)
    {
        return;
    }
    NSString* dataStr = @"1";
    [_pairedDevice.peripheral writeValue:[dataStr dataUsingEncoding:NSASCIIStringEncoding] forCharacteristic:clearCrashCharacteristic type:CBCharacteristicWriteWithResponse];
    
    [self.pairedDevice clearCollision];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error writing value for characteristic: %@", error);
    }
    //NSLog(@"Wrote to characteristic %@ with error: %@", characteristic, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error updating notification state for characteristic: %@", error);
    }
    
    //NSLog(@"Updated notification state for characteristic: %@", characteristic);
}

#pragma mark - CLLocationManager

- (void)handleEnterRegion
{
    NSLog(@"Enter Region");
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = nil;
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.alertBody = @"Did enter region";
    notification.soundName = nil;
    
    //[[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)handleExitRegion
{
    NSLog(@"Exit Region");
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = nil;
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.alertBody = @"Did exit region";
    notification.soundName = nil;
    
    //[[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //[self handleEnterRegion];
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(didEnterRegion)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver didEnterRegion];
        }];
    }
    
    //[self.locationManager startRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    //[self handleExitRegion];
    if (self.deviceObserver && [self.deviceObserver respondsToSelector:@selector(didExitRegion)])
    {
        [self performBlockOnDelegateQueue:^{
            [self.deviceObserver didExitRegion];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //NSLog(@"Ranged beacons: %@ in region: %@", beacons, region);
    for (CLBeacon* beacon in beacons)
    {
        if (![beacon.proximityUUID isEqual:[[NSUUID alloc] initWithUUIDString:@"e2c56db5-dffb-48d2-b060-d0f5a71096e0"]])
        {
            continue;
        }
        
        int16_t majorInt = [beacon.major intValue];
        majorInt = CFSwapInt16BigToHost(majorInt);
        
        int16_t minorInt = [beacon.minor intValue];
        minorInt = CFSwapInt16BigToHost(minorInt);
        
        NSString* strMajor = [[NSString alloc] initWithBytes:&majorInt length:2 encoding:NSASCIIStringEncoding];
        NSString* strMinor = [[NSString alloc] initWithBytes:&minorInt length:2 encoding:NSASCIIStringEncoding];
        
        NSString* last4DigitsofChipId = [NSString stringWithFormat:@"%@%@", strMajor, strMinor];
        NSLog(@"Last 4 Digits of Chip Id = %@", last4DigitsofChipId);
        
        NSDictionary* deviceCache = [[NSUserDefaults standardUserDefaults] objectForKey:VNLDeviceManagerCachedDevicesKey];
        if (!deviceCache) {
            return;
        }
        
        [deviceCache enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
            if ([last4DigitsofChipId isEqualToString:[key substringWithRange:NSMakeRange(key.length - 4, 4)]])
            {
                NSLog(@"Beacon matches cached Device!");
            }
        }];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside)
    {
        [self handleEnterRegion];
    }
    else if (state == CLRegionStateOutside)
    {
        [self handleExitRegion];
    }
    else
    {
        NSLog(@"Location Manager did determine state unknown");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // TODO
}

- (void)locationManager:(CLLocationManager *) manager didStartMonitoringForRegion:(CLRegion *) region {
    [manager requestStateForRegion:region];
}

#pragma mark - VNLDevicePickerDelegate Methods

- (void)devicePicker:(VNLDevicePickerViewController *)devicePicker didSelectDevice:(VNLDevice *)device
{
    [self performBlockOnInternalQueue:^{
        [self pairWithDevice:device];
    }];
}


- (void)subscribeSelector:(SEL)selector forProperty:(NSString *)property
{
    [self.propertySelectors setObject:[NSValue valueWithPointer:selector] forKey:property];
}

- (BOOL)hasVinliIdentifier:(NSString *)identifier
{
    NSString* vinliIdentifier = @"vinli";
    if (identifier.length < vinliIdentifier.length) {
        return NO;
    }
    
    identifier = [identifier substringWithRange:NSMakeRange(0, vinliIdentifier.length)];
    return [identifier.lowercaseString isEqualToString:vinliIdentifier];
}

@end


#pragma mark - Categories

@implementation VNLDevice (Bluetooth)

#pragma mark - Services

- (CBService *)mainService
{
    return [self.peripheral VNL_serviceWithUUID:VNLServiceUUIDMainStream];
}

#pragma mark - Characteristics

- (CBCharacteristic *)streamCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDMainStream];
}

- (CBCharacteristic *)chipIDCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDChipID];
}

- (CBCharacteristic *)troubleCodesCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDTroubleCodes];
}

- (CBCharacteristic *)clearTroubleCodesCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDClearTroubleCodes];
}

- (CBCharacteristic *)VINCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDVIN];
}

- (CBCharacteristic *)RPMCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDRPM];
}

- (CBCharacteristic *)accelerometerCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDAccelerometer];
}

- (CBCharacteristic *)clearCrashCharacteristic
{
    return [self.mainService VNL_characteristicWithUUID:VNLCharacteristicUUIDClearCrash];
}

//- (void)setRSSI:(NSNumber *)RSSI
//{
//    self.RSSI = RSSI;//[self setRSSI:RSSI];
//}

@end

@implementation NSArray (VNLConveniences)

- (CBAttribute *)VNL_objectMatchingCBUUID:(CBUUID *)UUID
{
    if (self.count < 1) {
        return nil;
    }
    
    __block CBAttribute *matchingObject = nil;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[CBAttribute class]]) {
            return;
        }
        
        CBAttribute *attributeObject = (CBAttribute *)obj;
        if ([attributeObject.UUID isEqual:UUID]) {
            matchingObject = attributeObject;
        }
    }];
    
    return matchingObject;
}

@end


@implementation CBPeripheral (VNLConveniences)

- (CBService *)VNL_serviceWithUUID:(CBUUID *)UUID
{
    return (CBService *)[self.services VNL_objectMatchingCBUUID:UUID];
}

@end


@implementation CBService (VNLConveniences)

- (CBCharacteristic *)VNL_characteristicWithUUID:(CBUUID *)UUID
{
    return (CBCharacteristic *)[self.characteristics VNL_objectMatchingCBUUID:UUID];
}

@end

