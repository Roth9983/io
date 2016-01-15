//
//  VCardViewController.h
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/1.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleController.h"
#import "SmcGATT.h"
#import "AlertViewController.h"
#import "ScanViewController.h"

@interface VCardViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, BTSmartSensorDelegate>{
    int count;
    NSMutableArray *StringArray;
    NSUserDefaults *userDefaults;
    int nfcindex;
}
@property (strong, nonatomic) IBOutlet UIImageView *lineImageview;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *companyTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextField *companyPhoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *phone2TextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *email2TextField;
@property (strong, nonatomic) IBOutlet UITextField *webTextField;
@property (strong, nonatomic) IBOutlet UITextField *skypeTextField;
@property (strong, nonatomic) IBOutlet UITextField *QQTextField;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;

@property (strong, nonatomic) IBOutlet UIButton *vCardLoadButton;
@property (strong, nonatomic) IBOutlet UIButton *vCardBackButton;

@property (strong, nonatomic) IBOutlet UIScrollView *vCardScrollView;

- (IBAction)vCardBack:(id)sender;
- (IBAction)loadToBandVCard:(id)sender;


@property (strong, nonatomic) SmcGATT *sensor;


@end
