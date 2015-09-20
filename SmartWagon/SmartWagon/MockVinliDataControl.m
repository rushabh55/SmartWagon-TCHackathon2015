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
    
    [dict setObject:@"value" forKey:@"key"];
    
    return dict;
}
@end

