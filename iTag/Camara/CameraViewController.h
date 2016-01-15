//
//  CameraViewController.h
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/2.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleController.h"
#import "SmcGATT.h"
#import "AlertViewController.h"
#import "ScanViewController.h"

@class SmcGATT;
@interface CameraViewController : UIViewController<BTSmartSensorDelegate>{
    Boolean camera_check;

}
@property (strong, nonatomic) SmcGATT *sensor;

@end
