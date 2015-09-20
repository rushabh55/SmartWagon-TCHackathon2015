//
//  NetworkingProtocol.h
//  WeatherAPI
//
//  Created by Gosar, Rushabh on 9/19/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VinliNet/VinliSDK.h>
#import "Constants.h"

@interface NetworkingProtocol : NSObject
+(id) instance;
-(void) sendGETRequest:(NSString*)requestURL delegate:(void (^)(id, NSError*))completionHandler;
-(void) sendPOSTRequest:(NSString*)requestURL withParams:(NSDictionary*)params delegate:(void (^)(id, NSError*))completionHandler;

@end
