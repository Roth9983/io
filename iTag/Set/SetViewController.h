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

@interface SetViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *setBsckButton;
@property (strong, nonatomic) IBOutlet UIButton *pairButton;
@property (strong, nonatomic) IBOutlet UIButton *alarmDurationButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutUsButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;


- (IBAction)setBackPressed:(id)sender;
- (IBAction)pairButtonPressed:(id)sender;
- (IBAction)alarmDurationButtonPressed:(id)sender;
- (IBAction)aboutUsButtonPressed:(id)sender;

@end
