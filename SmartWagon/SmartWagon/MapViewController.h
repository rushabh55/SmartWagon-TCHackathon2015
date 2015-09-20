//
//  MapViewController.h
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/19/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface MapViewController : UIViewController<AGSMapViewLayerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
- (IBAction)backPressed:(id)sender;

@end
