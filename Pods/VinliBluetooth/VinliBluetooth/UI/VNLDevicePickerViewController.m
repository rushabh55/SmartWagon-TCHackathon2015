//
//  VNLDevicPickerViewController.m
//  Vinli
//
//  Created by Andrew Wells on 8/11/15.
//  Copyright (c) 2015 Vinli. All rights reserved.
//

#import "VNLDevicePickerViewController.h"
#import "VNLDevice.h"
#import "VNLDevicePickerTableViewCell.h"
@import CoreText;

static CGFloat const VNLDevicePickerContinueButtonHeight        = 49.0f;
static CGFloat const VNLDevicePickerTableViewCellHeight         = 60.0f;
static CGFloat const VNLDevicePickerTableViewYMargin            = 14.0f;

@interface VNLDevicePickerViewController ()
@property (assign, nonatomic) NSInteger nearestDeviceCellIdx;
@end

@implementation VNLDevicePickerViewController

#pragma mark - LifeCycle

- (void)dynamicallyLoadFontWithName:(NSString *)fontName
{
    //NSString *resourceName = [NSString stringWithFormat:@"%@/%@", kBundle, name];
    NSURL *url = [[NSBundle mainBundle] URLForResource:fontName withExtension:@"otf"];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            NSLog(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

- (void)awakeFromNib
{
    [self dynamicallyLoadFontWithName:@"WhitneyHTF-Light"];
    [self dynamicallyLoadFontWithName:@"WhitneyHTF-Medium"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Select Device", @"");
    
    self.detailTextLabel.font = [UIFont fontWithName:@"WhitneyHTF-Light" size:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.5;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
    
    NSString* detailText = NSLocalizedString(@"You may choose to pair with a nearby Vinli device over bluetooth to continue to send data without LTE connection.", @"");
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:detailText
                                           attributes:attributes];
    self.detailTextLabel.attributedText = attributedText;
    
   
    self.continueButton.titleLabel.text = NSLocalizedString(@"Continue", @"");
    
    
    // border radius
    [self.contentView.layer setCornerRadius:4.0f];
    
    // border
    UIColor* greyColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
    [self.contentView.layer setBorderColor:greyColor.CGColor];
    [self.contentView.layer setBorderWidth:1.0f];
    self.contentView.layer.masksToBounds=YES;
    
    // drop shadow
    [self.contentView.layer setShadowColor:[UIColor clearColor].CGColor];
    [self.contentView.layer setShadowOpacity:0.1f];
    [self.contentView.layer setShadowRadius:1.5f];
    [self.contentView.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.separatorColor = [UIColor colorWithRed:(235.0f/255.0f) green:(235.0f/255.0f) blue:(235.0f/255.0f) alpha:1];
    
    _nearestDeviceCellIdx = -1;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.devices.count == 0)
    {
        // Handle this error
        return;
    }
    
    NSInteger maxCellCount = 3;
    self.contentViewHeightConstraint.constant = (2 * VNLDevicePickerTableViewYMargin) + VNLDevicePickerContinueButtonHeight + (MIN(self.devices.count, maxCellCount) * VNLDevicePickerTableViewCellHeight);
    if (self.devices.count <= maxCellCount)
    {
        self.tableView.scrollEnabled = NO;
    }
    
    NSIndexPath* firstCell = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:firstCell];
    [cell layoutSubviews];
 
    
    [self.tableView selectRowAtIndexPath:firstCell animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_devices) {
        return;
    }
    
    NSInteger closestDeviceIdx = 0;
    for (int i = 0; i < _devices.count; i++)
    {
        VNLDevice* closestDevice = _devices[closestDeviceIdx];
        VNLDevice* device = _devices[i];
        if (![device connected]) {
            continue;
        }
        
        if (device.RSSI > closestDevice.RSSI)
        {
            closestDeviceIdx = i;
        }
    }
    
    _nearestDeviceCellIdx = closestDeviceIdx;

    VNLDevicePickerTableViewCell* cell = (VNLDevicePickerTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:closestDeviceIdx inSection:0]];
    if (!cell) {
        return;
    }
    
    [cell showBluetoothView:YES];
}

#pragma mark - Tableview DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

#pragma mark - Tableview Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VNLDevicePickerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VNLDevicePickerTableViewCell class])];
    
    VNLDevice* device = self.devices[indexPath.row];
    cell.nameLabel.text = device.deviceMetaData.name ? device.deviceMetaData.name : device.chipID;
    
    [self maskWithCircle:cell.thumbnail];
    
    BOOL isLastCell = indexPath.row == self.devices.count - 1;
    cell.separatorInset = isLastCell ? UIEdgeInsetsMake(0.0f, cell.bounds.size.width, 0.0f, 0.0f) : UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    
    
    [cell showBluetoothView:indexPath.row == _nearestDeviceCellIdx];
    
    
    __weak VNLDevicePickerTableViewCell* weakCell = cell;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:device.deviceMetaData.iconURL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                if (error) {
                    return;
                }
                
                // handle response
                VNLDevicePickerTableViewCell* strongCell = weakCell;
                if (!strongCell) {
                    return;
                }
                
                UIImage* image = [UIImage imageWithData:data];
                if (!image) {
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.2f animations:^{
                        strongCell.thumbnail.image = image;
                    }];
                });
              
                
            }] resume];
    
    return cell;
}

- (IBAction)onContinueButton:(id)sender {
    if (self.devices.count > 0 && [self.delegate respondsToSelector:@selector(devicePicker:didSelectDevice:)])
    {
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
        VNLDevice* device = self.devices[selectedIndexPath.row];
        [self.delegate devicePicker:self didSelectDevice:device];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Class Methods

+ (instancetype)instantiate
{    
    if (![[NSBundle mainBundle] pathForResource:@"Vinli" ofType:@"storyboardc"])
    {
        return nil;
    }
    
    VNLDevicePickerViewController* devicePicker = [[UIStoryboard storyboardWithName:@"Vinli" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return devicePicker;
}

+ (instancetype)instantiateAndPresentDevicePickerWithTarget:(UIViewController *)target
                                                   delegate:(id<VNLDevicePickerViewControllerDelegate>)delegate
                                                    devices:(NSArray *)devices
                                                 completion:(void (^)(void))completion
{
    VNLDevicePickerViewController* devicePicker = [VNLDevicePickerViewController instantiate];
    devicePicker.delegate = delegate;
    devicePicker.devices = devices;
    /*
     ios7:
     presentingVC.modalPresentationStyle = UIModalPresentationCurrentContext;
     
     
     ios8:
     modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
     modalVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     
     and then in both:
     [presentingVC presentViewController:modalVC animated:YES completion:nil];
     */
    
    devicePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    devicePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
//    [UIView animateWithDuration:0.1 animations:^{
//        [target presentViewController:devicePicker animated:YES completion:^{
//            [devicePicker.view layoutIfNeeded];
//        }];
//    }];
    [target presentViewController:devicePicker animated:YES completion:completion];
    return devicePicker;
}

-(void)maskWithCircle:(UIImageView*)imgView {
    
    CAShapeLayer *aCircle=[CAShapeLayer layer];
    aCircle.path=[UIBezierPath bezierPathWithRoundedRect:imgView.bounds cornerRadius:imgView.frame.size.height/2].CGPath; // Considering the ImageView is square in Shape
    
    aCircle.fillColor=[UIColor blackColor].CGColor;
    imgView.layer.mask=aCircle;
    
}



@end
