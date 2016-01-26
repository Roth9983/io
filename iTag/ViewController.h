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
@property (strong, nonatomic) IBOutlet UIButton *vCardButton;
@property (strong, nonatomic) IBOutlet UIButton *doorAccessButton;
@property (strong, nonatomic) IBOutlet UIButton *autoPhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIImageView *powerImageview;



//actions
- (IBAction)toVCard:(id)sender;
- (IBAction)toDoorAccess:(id)sender;
- (IBAction)toAutoTake:(id)sender;
- (IBAction)toSet:(id)sender;
- (IBAction)toSearch:(id)sender;

@end

