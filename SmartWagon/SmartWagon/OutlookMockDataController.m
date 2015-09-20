//
//  OutlookMockDataController.m
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/20/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import "OutlookMockDataController.h"
//#import <Outlook.h>

NSString* userAuthID = @"";

@implementation OutlookMockDataController

-(void) createServiceReqWithHeaders {
    // init here
}
-(void) initSession {
    // send req to server, get auth ID
//    NSDictionary* userinfo = @{@"username":"rushabh55@live.com", "password":@""};
//    http://api.calendar.outlook.com/api/ff912ba5a9a530cd/userInfo
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setHTTPMethod:@"GET"];
//    NSError *error = [[NSError alloc] init];
//    NSHTTPURLResponse *responseCode = nil;
//    
//    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//    
//    if([responseCode statusCode] != 200){
//        return nil;
//    }
//    NSDictionary *jsonObject=[NSJSONSerialization
//                              JSONObjectWithData:oResponseData
//                              options:NSJSONReadingMutableLeaves
//                              error:nil];
//    return jsonObject;

}
-(NSString*) getAuthID {
    return userAuthID;
}
-(NSDictionary*) mockCalendarAPI {
    NSDictionary* userInfo = @{@"Meeting with Rob":@"Lo Jolla, San Diego", @"Time With Family":@"Golden Gate Bridge"};
    
    return userInfo;
}
@end
