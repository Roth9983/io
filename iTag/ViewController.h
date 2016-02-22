//
//  ViewController.h
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/1.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import "SmcGATT.h"
#import "Scan/ScanViewController.h"
#import "AlertViewController.h"
#import "AlertConnectSuccess.h"
@class SmcGATT;

@interface ViewController : UIViewController<BTSmartSensorDelegate>
@property (strong, nonatomic) SmcGATT *sensor;
@property (strong, nonatomic) NSMutableArray *peripheralArray;


//for UI
@property (strong, nonatomic) UIButton *vCardButton;
@property (strong, nonatomic) UIButton *doorAccessButton;
@property (strong, nonatomic) UIButton *autoPhotoButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) UIImageView *powerImageview;



//actions
- (void)toVCard:(id)sender;
- (void)toDoorAccess:(id)sender;
- (void)toAutoTake:(id)sender;
- (void)toSet:(id)sender;
- (void)toSearch:(id)sender;

@end

