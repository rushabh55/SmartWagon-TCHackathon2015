//
//  VNLDevicPickerViewController.h
//  Vinli
//
//  Created by Andrew Wells on 8/11/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VNLDevicePickerViewController;
@class VNLDevice;

@protocol VNLDevicePickerViewControllerDelegate <NSObject>

- (void)devicePicker:(VNLDevicePickerViewController *)devicePicker didSelectDevice:(VNLDevice *)device;

@end


@interface VNLDevicePickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id <VNLDevicePickerViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;


@property (weak, nonatomic) IBOutlet UIButton *continueButton;



@property (strong, nonatomic) NSArray* devices;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

- (IBAction)onContinueButton:(id)sender;

+ (instancetype)instantiate;
+ (instancetype)instantiateAndPresentDevicePickerWithTarget:(UIViewController *)target
                                                   delegate:(id<VNLDevicePickerViewControllerDelegate>)delegate
                                                    devices:(NSArray *)devices
                                                 completion:(void (^)(void))completion;

@end
