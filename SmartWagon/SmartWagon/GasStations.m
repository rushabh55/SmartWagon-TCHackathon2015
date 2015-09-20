//
//  GasStations.m
//  SmartWagon
//
//  Created by Hitesh Vyas on 9/20/15.
//  Copyright © 2015 Gosar, Rushabh. All rights reserved.
//

#import "GasStations.h"

@interface GasStations ()

@end

@implementation GasStations

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary* dict = [self loadData];
    NSDictionary* currObs = dict[@"geoLocation"];
    NSString* lat = currObs[@"lat"];
    NSString* lng = currObs[@"lng"];
}

-(NSDictionary*)loadData {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:@"http://devapi.mygasfeed.com/stations/radius/37.759851/-122.383611/5/reg/distance/rfej9napna.json?callback="]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        return nil;
    }
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:oResponseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    return jsonObject;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

