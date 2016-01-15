//
//  AlarmViewController.h
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/3.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmTableViewCell.h"
#import <math.h>

@interface AlarmViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *backAlarm;
@property (strong, nonatomic) IBOutlet UIButton *addAlarmButton;
@property (strong, nonatomic) IBOutlet UIButton *loadToBandAlarm;
@property (strong, nonatomic) IBOutlet UIButton *addCounterButton;
@property (strong, nonatomic) IBOutlet UITextField *counterTextField;
@property (strong, nonatomic) IBOutlet UITableView *alarmTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightOfTableView;

@property (strong, nonatomic) NSMutableDictionary *alarmInfo;
@property (strong, nonatomic) NSMutableDictionary *counterInfo;

@property (strong, nonatomic) NSMutableArray *arrayOfAlarms;

- (IBAction)alarmBack:(id)sender;
- (IBAction)addAlarm:(id)sender;
- (IBAction)loadAlarm:(id)sender;
- (IBAction)addCounter:(id)sender;

@end
