//
//  VNLDevicePickerTableViewCell.m
//  Pods
//
//  Created by Andrew Wells on 8/21/15.
//
//

#import "VNLDevicePickerTableViewCell.h"

@interface VNLDevicePickerTableViewCell ()
@property (strong, nonatomic) CALayer* progressLayer;
@property (strong, nonatomic) UIImageView* checkImageView;
@end

@implementation VNLDevicePickerTableViewCell

- (void)awakeFromNib {
    
    self.bluetoothView.hidden = YES;
    [self maskWithCircle:self.imageView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
//    UIView* circleView = [[UIView alloc] initWithFrame:self.thumbnail.frame];
//    CGRect newFrame = circleView.frame;
//    newFrame.size.height += 2.0f;
//    newFrame.size.width += 2.0f;
//    circleView.frame = newFrame;
//    circleView.layer.cornerRadius = ci
//    
    
    //UIBezierPath *bezierPath =
    //[bezierPath addArcWithCenter:center radius:50 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    if (selected)
    {
        if (!_progressLayer)
        {
            CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
            [progressLayer setPath: [UIBezierPath bezierPathWithRoundedRect:self.thumbnail.bounds cornerRadius:self.thumbnail.frame.size.height/2].CGPath];
            
            UIColor *blueColor = [UIColor colorWithRed:36.0f/255.0f green:167/255.0f blue:223.0f/255.0f alpha:1];
            [progressLayer setStrokeColor:blueColor.CGColor];
            [progressLayer setFillColor:[UIColor clearColor].CGColor];
            [progressLayer setLineWidth:3.0f];
            [progressLayer setStrokeEnd:100/100];
            _progressLayer = progressLayer;
        }
        [self.thumbnail.layer addSublayer:_progressLayer];
        
        if (!_checkImageView)
        {
            UIImage* img = [UIImage imageNamed:@"icn_checkmark"];
            _checkImageView = [[UIImageView alloc] initWithImage:img];
        }
        
        CGRect thumbnailFrame = self.thumbnail.frame;
        CGRect checkmarkFrame = self.checkImageView.frame;
        checkmarkFrame.origin.x = thumbnailFrame.origin.x + (thumbnailFrame.size.width * 0.7f);
        checkmarkFrame.origin.y = thumbnailFrame.origin.y;
        _checkImageView.frame = checkmarkFrame;
        
        [self.contentView addSubview:_checkImageView];
    }
    else
    {
        [_checkImageView removeFromSuperview];
        [_progressLayer removeFromSuperlayer];
    }
    
}

- (void)showBluetoothView:(BOOL)show
{
    self.bluetoothView.hidden = !show;
}

#pragma mark - ImageView Masking

-(void)maskWithCircle:(UIImageView*)imgView{
    
    CAShapeLayer *aCircle=[CAShapeLayer layer];
    aCircle.path=[UIBezierPath bezierPathWithRoundedRect:imgView.bounds cornerRadius:imgView.frame.size.height/2].CGPath; // Considering the ImageView is square in Shape
    
    aCircle.fillColor=[UIColor blackColor].CGColor;
    imgView.layer.mask=aCircle;
}

@end
