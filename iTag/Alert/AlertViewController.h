//
//  AlertViewController.h
//  iTag
//
//  Created by Jason Tsai on 2015/12/31.
//  Copyright © 2015年 NFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleController.h"
#import "SmcGATT.h"

@interface AlertViewController : UIViewController<BTSmartSensorDelegate>

@property (strong, nonatomic) NSMutableArray *peripheralArrayS;
@property (strong, nonatomic) SmcGATT *sensor;

- (UIView *)alertConnectSuccess;
- (UIView *)alertConnectError;
- (UIView *)alertConnecting;
- (UIView *)alertCustom:(NSString *)str;
- (UIImageView *)setBGImageView:(UIImage *)image;
- (UIButton *)getTryBurtton;
- (UIButton *)getCancelButton;

- (float)getSizeW;
- (float)getSizeH;
- (float)getSizeWRatio;
- (float)getSizeHRatio;

@end
