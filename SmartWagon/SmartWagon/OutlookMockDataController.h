//
//  OutlookMockDataController.h
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/20/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlookMockDataController : NSObject
-(void) createServiceReqWithHeaders;
-(void) initSession;
-(NSString*) getAuthID;
-(NSDictionary*) mockCalendarAPI;
@end
