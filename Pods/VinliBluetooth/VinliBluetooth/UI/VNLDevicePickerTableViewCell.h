//
//  VNLDevicePickerTableViewCell.h
//  Pods
//
//  Created by Andrew Wells on 8/21/15.
//
//

#import <UIKit/UIKit.h>

@interface VNLDevicePickerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *bluetoothView;

- (void)showBluetoothView:(BOOL)show;


@end
