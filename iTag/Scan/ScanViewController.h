//
//  ViewController.h
//  SmcUart
//
//  Created by Nick on 2015/3/25.
//  Copyright (c) 2015 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleController.h"
#import "SmcGATT.h"
#import "AlertViewController.h"

@class ViewController;
@interface ScanViewController : UIViewController <BTSmartSensorDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) SmcGATT *sensor;

@property (strong, retain) NSMutableArray *peripheralViewControllerArray;

@property (strong, nonatomic) IBOutlet UIButton *scanBleDeviceButton;
@property (strong, nonatomic) IBOutlet UITableView *bleDeviceTableView;
- (IBAction)scanBleDevicePressed:(id)sender;
- (void)autoConnectTag;
- (void)stopScan;
@end

