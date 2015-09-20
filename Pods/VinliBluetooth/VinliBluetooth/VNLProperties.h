//
//  VNLProperty.h
//  Vinli
//
//  Created by Andrew Wells on 8/8/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Vinli Supported Pids
*/



extern NSString * const VNLPropertyNone;

extern NSString * const VNLPropertyVehicleSpeed;
extern NSString * const VNLPropertyRPM;
extern NSString * const VNLPropertyTroubleCodesAndTestInfo;
extern NSString * const VNLPropertyFuelSystemStatus;
extern NSString * const VNLPropertyCalculatedLoadValue;
extern NSString * const VNLPropertyCoolantTemp;
extern NSString * const VNLPropertyShortTermFuelTrimBank1;
extern NSString * const VNLPropertyLongTermFuelTrimBank1;
extern NSString * const VNLPropertyShortTermFuelTrimBank2;
extern NSString * const VNLPropertyLongTermFuelTrimBank2;
extern NSString * const VNLPropertyFuelPressure;
extern NSString * const VNLPropertyIntakeManifoldPressure;
extern NSString * const VNLPropertyTimingAdvance;
extern NSString * const VNLPropertyIntakeAirTemperature;
extern NSString * const VNLPropertyMassAirFlow;
extern NSString * const VNLPropertyAbsoluteThrottleSensorPosition;
extern NSString * const VNLPropertySecondaryAirStatus;
extern NSString * const VNLPropertyOxygenSensorLocations;
extern NSString * const VNLPropertyOxygenSensorVoltage1a;
extern NSString * const VNLPropertyShortTermFuelTrim1a;
extern NSString * const VNLPropertyOxygenSensorVoltage1b;
extern NSString * const VNLPropertyShortTermFuelTrim1b;
extern NSString * const VNLPropertyOxygenSensorVoltage1c;
extern NSString * const VNLPropertyShortTermFuelTrim1c;
extern NSString * const VNLPropertyOxygenSensorVoltage1d;
extern NSString * const VNLPropertyShortTermFuelTrim1d;
extern NSString * const VNLPropertyOxygenSensorVoltage2a;
extern NSString * const VNLPropertyShortTermFuelTrim2a;
extern NSString * const VNLPropertyOxygenSensorVoltage2b;
extern NSString * const VNLPropertyShortTermFuelTrim2b;
extern NSString * const VNLPropertyOxygenSensorVoltage2c;
extern NSString * const VNLPropertyShortTermFuelTrim2c;
extern NSString * const VNLPropertyOxygenSensorVoltage2d;
extern NSString * const VNLPropertyShortTermFuelTrim2d;
extern NSString * const VNLPropertyDesignOBDRequirements;
extern NSString * const VNLPropertyAlternateOxygenSensorLocations;
extern NSString * const VNLPropertyAuxilliaryInputStatus;
extern NSString * const VNLPropertyRunTimeSinceEngineStart;
extern NSString * const VNLPropertyDistanceTraveledMILActivated;
extern NSString * const VNLPropertyFuelRailPressureRelManifold;
extern NSString * const VNLPropertyFuelRailPressure;
extern NSString * const VNLPropertyEquivalenceRatio1a;
extern NSString * const VNLPropertyVoltage1a;
extern NSString * const VNLPropertyEquivalenceRatio1b;
extern NSString * const VNLPropertyVoltage1b;
extern NSString * const VNLPropertyEquivalenceRatio1c;
extern NSString * const VNLPropertyVoltage1c;
extern NSString * const VNLPropertyCommandedExhaustGasRecirculation;
extern NSString * const VNLPropertyExhaustGasRecirculationError;
extern NSString * const VNLPropertyCommandedEvaporativePurge;
extern NSString * const VNLPropertyFuelLevelInput;
extern NSString * const VNLPropertyNumberOfWarmupsSinceDTCsCleared;
extern NSString * const VNLPropertyBarometricPressure;
extern NSString * const VNLPropertyRelativeThrottlePosition;
extern NSString * const VNLPropertyAmbientAirTemperature;
extern NSString * const VNLPropertyAbsoluteThrottlePositionb;
extern NSString * const VNLPropertyAbsoluteThrottlePositionc;
extern NSString * const VNLPropertyAcceleratorPedalPositiond;
extern NSString * const VNLPropertyAcceleratorPedalPositione;
extern NSString * const VNLPropertyAcceleratorPedalPositionf;
extern NSString * const VNLPropertyCommandedThrottleActuatorControl;
extern NSString * const VNLPropertyFuelType;
extern NSString * const VNLPropertyEthanolFuelPercentage;
extern NSString * const VNLPropertyRelativeAcceleratorPosition;
extern NSString * const VNLPropertyHybridBatteryLife;
extern NSString * const VNLPropertyEngineOilTemperature;
extern NSString * const VNLPropertyEmissionReqs;
extern NSString * const VNLPropertyDriversDemandEnginePercentTorque;
extern NSString * const VNLPropertyActualEnginePercentTorque;
extern NSString * const VNLPropertyNoxNTEControlAreaStatus;
extern NSString * const VNLPropertyPmNTEControlAreaStatus;
extern NSString * const VNLPropertyAuxIO;
extern NSString * const VNLPropertyEngineReferenceTorque;
extern NSString * const VNLPropertyEngineFuelRate;
extern NSString * const VNLPropertyFuelInjectionTiming;
extern NSString * const VNLPropertyAbsFuelRailPressure;
extern NSString * const VNLProperty2ndLongTermFuelTrim2;
extern NSString * const VNLProperty2ndLongTermFuelTrim4;
extern NSString * const VNLProperty2ndShortTermFuelTrim2;
extern NSString * const VNLProperty2ndShortTermFuelTrim4;
extern NSString * const VNLProperty2ndLongTermFuelTrim1;
extern NSString * const VNLProperty2ndLongTermFuelTrim3;
extern NSString * const VNLProperty2ndShortTermFuelTrim1;
extern NSString * const VNLProperty2ndShortTermFuelTrim3;
extern NSString * const VNLPropertyEvapSystemVaporPressure2;
extern NSString * const VNLPropertyAbsEvapSystemVaporPressure;
extern NSString * const VNLPropertyEngineRuntimeSinceDTCsCleared;
extern NSString * const VNLPropertyEngineRuntimeWhileMILOn;
extern NSString * const VNLPropertyFuelAirCommandedEquivalenceRatio;
extern NSString * const VNLPropertyAbsoluteLoadValue;
extern NSString * const VNLPropertyControlModuleVoltage;
extern NSString * const VNLPropertyCatalystTemp2b;
extern NSString * const VNLPropertyCatalystTemp1b;
extern NSString * const VNLPropertyCatalystTemp2a;
extern NSString * const VNLPropertyCatalystTemp1a;
extern NSString * const VNLPropertyEvapSystemVaporPressure1;
extern NSString * const VNLPropertyDistanceSinceDTCsCleared;

@interface VNLProperties : NSObject

+ (NSArray *)OxygenSensorVoltages;

@end



