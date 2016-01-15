//
//  NFCDoorAccessViewController.h
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/9.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleController.h"
#import "SmcGATT.h"
#import "AlertViewController.h"
#import "ScanViewController.h"

@interface NFCDoorAccessViewController : UIViewController<UIGestureRecognizerDelegate, BTSmartSensorDelegate, UITextFieldDelegate>{
    UITextField *myTf;
    int count;
    NSMutableArray *StringArray;
    
}
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *loadToBandDoor;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UITextField *keyIDTextfield;
@property (strong, nonatomic) IBOutlet UIButton *doorBackButton;
@property (strong, nonatomic) NSMutableArray *NFCArray;
@property (strong, nonatomic) NSMutableArray *keyNameArray;

- (IBAction)backDoorPressed:(id)sender;
- (IBAction)loadToBandDoorPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@property (strong, nonatomic) SmcGATT *sensor;

@end
