//
//  SetViewController.h
//  iTag
//
//  Created by Jason Tsai on 2015/12/22.
//  Copyright © 2015年 NFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmcGATT.h"
#import "AlertViewController.h"
#import <SafariServices/SafariServices.h>

@interface SetViewController : UIViewController<BTSmartSensorDelegate>
@property (strong, nonatomic) SmcGATT *sensor;
@property (strong, nonatomic) UIButton *setBsckButton;
@property (strong, nonatomic) UIButton *pairButton;
@property (strong, nonatomic) UIButton *alarmDurationButton;
@property (strong, nonatomic) UIButton *aboutUsButton;
@property (strong, nonatomic) UILabel *versionLabel;


- (void)setBackPressed:(id)sender;
- (void)pairButtonPressed:(id)sender;
- (void)alarmDurationButtonPressed:(id)sender;
- (void)aboutUsButtonPressed:(id)sender;

@end
