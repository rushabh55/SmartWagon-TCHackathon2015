//
//  WeatherInfo.h
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/20/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherInfo : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *precipitation;
@property (weak, nonatomic) IBOutlet UILabel *Humidity;
@property (weak, nonatomic) IBOutlet UILabel *Pressure;
@property (weak, nonatomic) IBOutlet UILabel *Place;
@property (weak, nonatomic) IBOutlet UILabel *Elevation;

@end
