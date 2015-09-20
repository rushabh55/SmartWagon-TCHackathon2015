//
//  NetworkingProtocol.m
//  WeatherAPI
//
//  Created by Gosar, Rushabh on 9/19/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import "NetworkingProtocol.h"
#import <AFNetworking.h>
#import <AFHTTPRequestOperation.h>
NetworkingProtocol* m_instance;
@interface NetworkingProtocol()
@end

@implementation NetworkingProtocol
-(id) init {
    self = [super init];
    if (self) {
        
    }
    
    return  self;
}

+(id) instance {
    if (!m_instance) {
        m_instance = [[NetworkingProtocol alloc] init];
    }
    return m_instance;
}

-(void) sendGETRequest:(NSString*)requestURL delegate:(void (^)(id, NSError*))completionHandler {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         completionHandler(nil, error);
    }];
}


-(void) sendPOSTRequest:(NSString*)requestURL withParams:(NSDictionary*)params delegate:(void (^)(id, NSError*))completionHandler {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:requestURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil, error);
    }];
    NSLog(@"%@", kAppIdVinli);
}


@end
