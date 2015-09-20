//
//  VNLPid.h
//  Vinli
//
//  Created by Andrew Wells on 8/8/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VNLPIDType) {
    VNLPIDTypeUnknown = 0xDADB0D,
    VNLPIDTypeCalculatedLoadPercentage = 0x04,
    VNLPIDTypeControlModuleVoltage = 0x42,
    VNLPIDTypeEngineCoolantTemperature = 0x05,
    VNLPIDTypeFuelLevelInput = 0x2F,
    VNLPIDTypeMassAirflowRate = 0x10,
    VNLPIDTypeRuntimeSinceEngineStart = 0x1f,
    VNLPIDTypeSpeed = 0x0D,
    VNLPIDTypeRPM = 0x0C,
    VNLPIDTypeFuelSystemStatus = 0x03,
    VNLPIDTypeBarometricPressure = 0x33,
    VNLPIDTypeAmbientAirTemperature = 0x46,
    VNLPIDTypeIntakeAirTemperature = 0x0F,
    VNLPIDTypeOxygenSensor1A = 0x24,
    VNLPIDTypeOxygenSensor1B = 0x25,
    VNLPIDTypeOxygenSensor1C = 0x26,
    VNLPIDTypeOxygenSensor1D = 0x27,
    VNLPIDTypeOxygenSensor2A = 0x28,
    VNLPIDTypeOxygenSensor2B = 0x29,
    VNLPIDTypeOxygenSensor2C = 0x2A,
    VNLPIDTypeOxygenSensor2D = 0x2B,
    
    VNLPIDTypeTroubleCodesAndTestInfo = 0x01,
    VNLPIDTypeShortTermFuelTrimBank1 = 0x06,
    VNLPIDTypeLongTermFuelTrimBank1 = 0x07,
    VNLPIDTypeShortTermFuelTrimBank2 = 0x08,
    VNLPIDTypeLongTermFuelTrimBank2 = 0x09,
    VNLPIDTypeFuelPressure = 0x0A,
    VNLPIDTypeIntakeManifoldPressure = 0x0B,
    VNLPIDTypeTimingAdvance = 0x0E,
    VNLPIDTypeAbsoluteThrottleSensorPosition = 0x11,
    VNLPIDTypeSecondaryAirStatus = 0x12,
    VNLPIDTypeOxygenSensorLocations = 0x13,
    
    
    VNLPIDTypeRelativeAcceleratorPosition= 0x5A,
    VNLPIDTypeHybridBatteryLife = 0x5B,
    VNLPIDTypeEngineOilTemperature = 0x5C,
    VNLPIDTypeEmissionReqs = 0x5F,
    VNLPIDTypeDriversDemandEnginePercentTorque = 0x61,
    VNLPIDTypeActualEnginePercentTorque = 0x62,
    VNLPIDTypeEngineReferenceTorque = 0x63,
    VNLPIDTypeNoxNTEControlAreaStatus = 0x7D,
    VNLPIDTypePmNTEControlAreaStatus = 0x7E,
    VNLPIDTypeAuxIO = 0x65,
    
    
    VNLPIDTypeEngineFuelRate = 0x5E,
    VNLPIDTypeFuelInjectionTiming = 0x5D,
    VNLPIDTypeAbsFuelRailPressure = 0x59,
    VNLPIDType2ndLongTermFuelTrim2AndTrim4 = 0x58,
    VNLPIDType2ndShortTermFuelTrim2AndTrim4 = 0x57,
    VNLPIDType2ndLongTermFuelTrim1AndTrim3 = 0x56,
    VNLPIDType2ndShortTermFuelTrim1AndTrim3 = 0x55,
    VNLPIDTypeEvapSystemVaporPressure2 = 0x54,
    VNLPIDTypeAbsEvapSystemVaporPressure = 0x53,
    VNLPIDTypeEngineRuntimeSinceDTCsCleared = 0x4E,
    VNLPIDTypeEngineRuntimeWhileMILOn = 0x4D,
    VNLPIDTypeFuelAirCommandedEquivalenceRatio = 0x44,
    VNLPIDTypeAbsoluteLoadValue = 0x43,
    VNLPIDTypeCatalystTemp2b = 0x3F,
    VNLPIDTypeCatalystTemp1b = 0x3E,
    VNLPIDTypeCatalystTemp2a = 0x3D,
    VNLPIDTypeCatalystTemp1a = 0x3C,
    VNLPIDTypeEvapSystemVaporPressure1 = 0x32,
    VNLPIDTypeDistanceSinceDTCsCleared = 0x31,
    VNLPIDTypeFuelRailPressure = 0x23,
    VNLPIDTypeFuelRailPressureRelManifold = 0x22,
    VNLPIDTypeDistanceTraveledMILActivated = 0x21,
    VNLPIDTypeOBDType = 0x1C,
    VNLPIDTypeOxygenSensorVoltage2dAndShortTermFuelTrim2d = 0x1B,
    VNLPIDTypeOxygenSensorVoltage2cAndShortTermFuelTrim2c = 0x1A,
    VNLPIDTypeOxygenSensorVoltage2bAndShortTermFuelTrim2b = 0x19,
    VNLPIDTypeOxygenSensorVoltage2aAndShortTermFuelTrim2a = 0x18,
    VNLPIDTypeOxygenSensorVoltage1dAndShortTermFuelTrim1d = 0x17,
    VNLPIDTypeOxygenSensorVoltage1cAndShortTermFuelTrim1c = 0x16,
    VNLPIDTypeOxygenSensorVoltage1bAndShortTermFuelTrim1b = 0x15,
    VNLPIDTypeOxygenSensorVoltage1aAndShortTermFuelTrim1a = 0x14,
    VNLPIDTypeAlternateOxygenSensorLocations = 0x1D,
    VNLPIDTypeAuxilliaryInputStatus = 0x1E,
    VNLPIDTypeCommandedExhaustGasRecirculation = 0x2C,
    VNLPIDTypeExhaustGasRecirculationError = 0x2D,
    VNLPIDTypeCommandedEvaporativePurge = 0x2E,
    VNLPIDTypeNumberOfWarmupsSinceDTCsCleared = 0x30,
    VNLPIDTypeRelativeThrottlePosition = 0x45,
    VNLPIDTypeAbsoluteThrottlePositionb = 0x47,
    VNLPIDTypeAbsoluteThrottlePositionc = 0x48,
    VNLPIDTypeAcceleratorPedalPositiond = 0x49,
    VNLPIDTypeAcceleratorPedalPositione = 0x4A,
    VNLPIDTypeAcceleratorPedalPositionf = 0x4B,
    VNLPIDTypeCommandedThrottleActuatorControl = 0x4C,
    VNLPIDTypeFuelType = 0x51,
    VNLPIDTypeEthanolFuelPercentage = 0x52,
    
    //0x02: -- Not in pids.json
    
};

typedef struct {
    NSInteger type;
    short a;
    short b;
    short c;
    short d;
    char* hexValue;
} VNLPIDValues;



@interface VNLPID : NSObject

@property (strong, nonatomic) id rawValue;
@property (strong, nonatomic) id convertedValue;
@property (strong, nonatomic) NSDictionary* metadata;
@property (assign, nonatomic) VNLPIDType type;

@property (readonly) NSString* name;
@property (readonly) NSString* units;
@property (readonly, getter=isDecimal) BOOL decimal;

- (instancetype)initWithMetadata:(NSDictionary *)metadata andValue:(id)value;
- (NSString *)getPIDTypeString;

+ (NSDictionary *)valuesForPIDData:(NSData *)data;
+ (void)setPIDInfo:(NSDictionary *)pidInfo;
+ (NSString *)pidForProperty:(NSString *)property;

@end



@interface NSData (VNLConveniences)

- (NSInteger)VNL_startingIndexOfPIDType;
- (VNLPIDValues)VNL_PIDValues;

@end

