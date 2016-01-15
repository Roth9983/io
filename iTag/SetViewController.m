//
//  SetViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/4.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import "SetViewController.h"

@interface SetViewController ()

@end

@implementation SetViewController
@synthesize backSet;
@synthesize containerViewSet;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:backSet];
    [self.view bringSubviewToFront:containerViewSet];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backSetPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
