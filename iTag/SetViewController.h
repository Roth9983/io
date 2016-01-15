//
//  SetViewController.h
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/4.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *backSet;
@property (strong, nonatomic) IBOutlet UIView *containerViewSet;

- (IBAction)backSetPressed:(id)sender;
@end
