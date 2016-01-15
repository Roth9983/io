//
//  SearchViewController.h
//  iTag
//
//  Created by Jason Tsai on 2015/12/22.
//  Copyright © 2015年 NFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BleController.h"
#import "SmcGATT.h"
#import "AlertViewController.h"

@interface SearchViewController : UIViewController<BTSmartSensorDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *connectStateImageView;
@property (strong, nonatomic) IBOutlet UIImageView *searchWordImageView;
@property (strong, nonatomic) IBOutlet UIImageView *radar1ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *radar2ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *radar3ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *radar4ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *radar5ImageView;
@property (strong, nonatomic) UIImageView *ioAnimationImageView;


@property (strong, nonatomic) NSMutableArray *peripheralArrayS;
@property (strong, nonatomic) SmcGATT *sensor;

@property (strong, nonatomic) IBOutlet UIButton *searchBackButton;

- (IBAction)searchBackButtonPressed:(id)sender;
@end
