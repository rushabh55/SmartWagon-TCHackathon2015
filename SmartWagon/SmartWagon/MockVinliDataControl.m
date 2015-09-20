//
//  MockVinliDataControl.m
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/19/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import "MockVinliDataControl.h"


@implementation MockVinliDataControl
-(NSDictionary*)mockData {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"13" forKey:@"Mileage"];
    [dict setObject:@"1.87" forKey:@"AVG_MPG"];
    [dict setObject:@"15.55" forKey:@"MAX_MPG"];
    [dict setObject:@"64.54" forKey:@"FUEL_USED"];
    [dict setObject:@"964" forKey:@"MILES_TRAVELED"];
    [dict setObject:@"158.45" forKey:@"AVG_TRIP_SPEED"];
    [dict setObject:@"40.80" forKey:@"AVG_SPEED"];
    [dict setObject:@"1" forKey:@"HARD_ACCEL"];
    [dict setObject:@"585-xxx-7918" forKey:@"EMERGENCY_CONTACT"];    
    return dict;
}


@end

