//
//  ActivityTableViewController.h
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/20/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewController : UITableViewController
- (IBAction)backPressed:(id)sender;
@property (atomic, strong) NSArray* dataSource;
@property (atomic, strong) NSMutableArray* timeSource;
@end
