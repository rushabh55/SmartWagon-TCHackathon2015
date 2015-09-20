//
//  VNLProperty.m
//  Vinli
//
//  Created by Andrew Wells on 8/8/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import "VNLProperties.h"

static NSArray * VNLPropertiesOxygenSensorVoltages;

NSString * const VNLPropertyNone = @"none";

NSString * const VNLPropertyVehicleSpeed = @"vehicleSpeed";
NSString * const VNLPropertyRPM = @"rpm";

NSString * const VNLPropertyTroubleCodesAndTestInfo = @"troubleCodesAndTestInfo";
NSString * const VNLPropertyFuelSystemStatus = @"fuelSystemStatus";
NSString * const VNLPropertyCalculatedLoadValue = @"calculatedLoadValue";
NSString * const VNLPropertyCoolantTemp = @"coolantTemp";
NSString * const VNLPropertyShortTermFuelTrimBank1 = @"shortTermFuelTrimBank1";
NSString * const VNLPropertyLongTermFuelTrimBank1 = @"longTermFuelTrimBank1";
NSString * const VNLPropertyShortTermFuelTrimBank2 = @"shortTermFuelTrimBank2";
NSString * const VNLPropertyLongTermFuelTrimBank2 = @"longTermFuelTrimBank2";
NSString * const VNLPropertyFuelPressure = @"fuelPressure";
NSString * const VNLPropertyIntakeManifoldPressure = @"intakeManifoldPressure";
NSString * const VNLPropertyTimingAdvance = @"timingAdvance";
NSString * const VNLPropertyIntakeAirTemperature = @"intakeAirTemperature";
NSString * const VNLPropertyMassAirFlow = @"massAirFlow";
NSString * const VNLPropertyAbsoluteThrottleSensorPosition = @"absoluteThrottleSensorPosition";
NSString * const VNLPropertySecondaryAirStatus = @"secondaryAirStatus";
NSString * const VNLPropertyOxygenSensorLocations = @"oxygenSensorLocations";
NSString * const VNLPropertyOxygenSensorVoltage1a = @"oxygenSensorVoltage1a";
NSString * const VNLPropertyShortTermFuelTrim1a = @"shortTermFuelTrim1a";
NSString * const VNLPropertyOxygenSensorVoltage1b = @"oxygenSensorVoltage1b";
NSString * const VNLPropertyShortTermFuelTrim1b = @"shortTermFuelTrim1b";
NSString * const VNLPropertyOxygenSensorVoltage1c = @"oxygenSensorVoltage1c";
NSString * const VNLPropertyShortTermFuelTrim1c = @"shortTermFuelTrim1c";
NSString * const VNLPropertyOxygenSensorVoltage1d = @"oxygenSensorVoltage1d";
NSString * const VNLPropertyShortTermFuelTrim1d = @"shortTermFuelTrim1d";
NSString * const VNLPropertyOxygenSensorVoltage2a = @"oxygenSensorVoltage2a";
NSString * const VNLPropertyShortTermFuelTrim2a = @"shortTermFuelTrim2a";
NSString * const VNLPropertyOxygenSensorVoltage2b = @"oxygenSensorVoltage2b";
NSString * const VNLPropertyShortTermFuelTrim2b = @"shortTermFuelTrim2b";
NSString * const VNLPropertyOxygenSensorVoltage2c = @"oxygenSensorVoltage2c";
NSString * const VNLPropertyShortTermFuelTrim2c  = @"shortTermFuelTrim2c";
NSString * const VNLPropertyOxygenSensorVoltage2d = @"oxygenSensorVoltage2d";
NSString * const VNLPropertyShortTermFuelTrim2d = @"shortTermFuelTrim2d";
NSString * const VNLPropertyDesignOBDRequirements = @"designOBDRequirements";
NSString * const VNLPropertyAlternateOxygenSensorLocations = @"alternateOxygenSensorLocations";
NSString * const VNLPropertyAuxilliaryInputStatus = @"auxilliaryInputStatus";
NSString * const VNLPropertyRunTimeSinceEngineStart = @"runTimeSinceEngineStart";
NSString * const VNLPropertyDistanceTraveledMILActivated = @"distanceTraveledMILActivated";
NSString * const VNLPropertyFuelRailPressureRelManifold = @"fuelRailPressureRelManifold";
NSString * const VNLPropertyFuelRailPressure = @"fuelRailPressure";
NSString * const VNLPropertyEquivalenceRatio1a = @"equivalenceRatio1a";
NSString * const VNLPropertyVoltage1a = @"voltage1a";
NSString * const VNLPropertyEquivalenceRatio1b = @"equivalenceRatio1b";
NSString * const VNLPropertyVoltage1b  = @"voltage1b";
NSString * const VNLPropertyEquivalenceRatio1c = @"equivalenceRatio1c";
NSString * const VNLPropertyVoltage1c  = @"voltage1c";
NSString * const VNLPropertyCommandedExhaustGasRecirculation = @"commandedExhaustGasRecirculation";
NSString * const VNLPropertyExhaustGasRecirculationError = @"exhaustGasRecirculationError";
NSString * const VNLPropertyCommandedEvaporativePurge = @"commandedEvaporativePurge";
NSString * const VNLPropertyFuelLevelInput = @"fuelLevelInput";
NSString * const VNLPropertyNumberOfWarmupsSinceDTCsCleared = @"numberOfWarmupsSinceDTCsCleared";
NSString * const VNLPropertyBarometricPressure = @"barometricPressure";
NSString * const VNLPropertyRelativeThrottlePosition = @"relativeThrottlePosition";
NSString * const VNLPropertyAmbientAirTemperature = @"ambientAirTemperature";
NSString * const VNLPropertyAbsoluteThrottlePositionb = @"absoluteThrottlePositionb";
NSString * const VNLPropertyAbsoluteThrottlePositionc = @"absoluteThrottlePositionc";
NSString * const VNLPropertyAcceleratorPedalPositiond = @"acceleratorPedalPositiond";
NSString * const VNLPropertyAcceleratorPedalPositione = @"acceleratorPedalPositione";
NSString * const VNLPropertyAcceleratorPedalPositionf = @"acceleratorPedalPositionf";
NSString * const VNLPropertyCommandedThrottleActuatorControl = @"commandedThrottleActuatorControl";
NSString * const VNLPropertyFuelType = @"fuelType";
NSString * const VNLPropertyEthanolFuelPercentage = @"ethanolFuelPercentage";
NSString * const VNLPropertyRelativeAcceleratorPosition = @"relativeAcceleratorPosition";
NSString * const VNLPropertyHybridBatteryLife = @"hybridBatteryLife";
NSString * const VNLPropertyEngineOilTemperature = @"engineOilTemperature";
NSString * const VNLPropertyEmissionReqs = @"emissionReqs";
NSString * const VNLPropertyDriversDemandEnginePercentTorque = @"driversDemandEnginePercentTorque";
NSString * const VNLPropertyActualEnginePercentTorque = @"actualEnginePercentTorque";
NSString * const VNLPropertyNoxNTEControlAreaStatus = @"noxNTEControlAreaStatus";
NSString * const VNLPropertyPmNTEControlAreaStatus = @"pmNTEControlAreaStatus";
NSString * const VNLPropertyAuxIO  = @"auxIO";
NSString * const VNLPropertyEngineReferenceTorque  = @"engineReferenceTorque";
NSString * const VNLPropertyEngineFuelRate = @"engineFuelRate";
NSString * const VNLPropertyFuelInjectionTiming = @"fuelInjectionTiming";
NSString * const VNLPropertyAbsFuelRailPressure = @"absFuelRailPressure";
NSString * const VNLProperty2ndLongTermFuelTrim2 = @"2ndLongTermFuelTrim2";
NSString * const VNLProperty2ndLongTermFuelTrim4  = @"2ndLongTermFuelTrim4";
NSString * const VNLProperty2ndShortTermFuelTrim2 = @"2ndShortTermFuelTrim2";
NSString * const VNLProperty2ndShortTermFuelTrim4  = @"2ndShortTermFuelTrim4";
NSString * const VNLProperty2ndLongTermFuelTrim1  = @"2ndLongTermFuelTrim1";
NSString * const VNLProperty2ndLongTermFuelTrim3  = @"2ndLongTermFuelTrim3";
NSString * const VNLProperty2ndShortTermFuelTrim1  = @"2ndShortTermFuelTrim1";
NSString * const VNLProperty2ndShortTermFuelTrim3  = @"2ndShortTermFuelTrim3";
NSString * const VNLPropertyEvapSystemVaporPressure2  = @"evapSystemVaporPressure2";
NSString * const VNLPropertyAbsEvapSystemVaporPressure = @"absEvapSystemVaporPressure";
NSString * const VNLPropertyEngineRuntimeSinceDTCsCleared = @"engineRuntimeSinceDTCsCleared";
NSString * const VNLPropertyEngineRuntimeWhileMILOn = @"engineRuntimeWhileMILOn";
NSString * const VNLPropertyFuelAirCommandedEquivalenceRatio = @"fuelAirCommandedEquivalenceRatio";
NSString * const VNLPropertyAbsoluteLoadValue = @"absoluteLoadValue";
NSString * const VNLPropertyControlModuleVoltage = @"controlModuleVoltage";
NSString * const VNLPropertyCatalystTemp2b = @"catalystTemp2b";
NSString * const VNLPropertyCatalystTemp1b = @"catalystTemp1b";
NSString * const VNLPropertyCatalystTemp2a = @"catalystTemp2a";
NSString * const VNLPropertyCatalystTemp1a = @"catalystTemp1a";
NSString * const VNLPropertyEvapSystemVaporPressure1 = @"evapSystemVaporPressure1";
NSString * const VNLPropertyDistanceSinceDTCsCleared  = @"distanceSinceDTCsCleared";

@implementation VNLProperties

+ (void)initialize
{
    VNLPropertiesOxygenSensorVoltages = @[VNLPropertyOxygenSensorVoltage1a, VNLPropertyOxygenSensorVoltage1b, VNLPropertyOxygenSensorVoltage1c, VNLPropertyOxygenSensorVoltage1d, VNLPropertyOxygenSensorVoltage2a, VNLPropertyOxygenSensorVoltage2b, VNLPropertyOxygenSensorVoltage2c, VNLPropertyOxygenSensorVoltage2d];
}

+ (NSArray *)OxygenSensorVoltages
{
    return VNLPropertiesOxygenSensorVoltages;
}

@end



