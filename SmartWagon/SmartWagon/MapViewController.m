//
//  MapViewController.m
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/19/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    NSURL* url = [NSURL URLWithString:@"http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [_mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
    
    self.mapView.layerDelegate = self;
    //to focus on the location
    [self.mapView.locationDisplay startDataSource];
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeCompassNavigation ;
    self.mapView.locationDisplay.navigationPointHeightFactor  = 0.5; //50% along the center line from the bottom edge to the top edge
     CLLocationManager *locationManager;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self maps];
}

-(void) maps {
    NSDictionary* dict = [self loadData];
    NSDictionary* currObs = dict[@"geoLocation"];
    float lat = [currObs[@"lat"] floatValue];
    float lng = [currObs[@"lng"] floatValue];
    [self setlocation:lat withLong:lng];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    
//    if (currentLocation != nil) {
//        longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
//        latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
//    }
}

- (void)setlocation:(float)lat withLong:(float)lng {
    //Set the parameters
    AGSLocatorFindParameters *findParams = [[AGSLocatorFindParameters alloc] init];
    findParams.text = @"Gas Station";
    findParams.outFields = @[@"*"];
    findParams.outSpatialReference = self.mapView.spatialReference;
    AGSPoint* p = [AGSPoint pointWithX:lat y:lng spatialReference:nil];
    findParams.location = p;
    
    self.locator = [AGSLocator locator];
    self.locator.delegate = self;
    
    [self.locator findWithParameters:findParams];
   
};


-(BOOL)mapView:(AGSMapView *)mapView shouldHitTestLayer:(AGSLayer *)layer atPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    
    return true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapViewDidLoad:(AGSMapView *) mapView {
    //do something now that the map is loaded
    //for example, show the current location on the map
    [mapView.locationDisplay startDataSource];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
