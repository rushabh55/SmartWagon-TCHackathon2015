//
//  UserInfoVC.m
//  WeatherAPI
//
//  Created by Gosar, Rushabh on 9/19/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import "UserInfoVC.h"
#import "NetworkingProtocol.h"

@interface UserInfoVC ()

@end

@implementation UserInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self roundCorners];
    [self getWeatherData];
}

-(void) getWeatherData {
    [[NetworkingProtocol instance] sendGETRequest:@"http://api.wunderground.com/api/ff912ba5a9a530cd/conditions/q/CA/San_Francisco.json" delegate:^(id result, NSError * error) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Random Alert" message:[result description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [view show];
    }];
}

-(void) roundCorners {
    _profilePic.layer.cornerRadius = _profilePic.bounds.size.width / 2;
    _profilePic.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
