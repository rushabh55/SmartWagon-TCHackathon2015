//
//  CarInfoTVCTableViewController.h
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/20/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarInfoTVCTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, atomic) NSDictionary* dataSource;
- (IBAction)backPressed:(id)sender;

@end
