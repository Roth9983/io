//
//  SetTableViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/4.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import "SetTableViewController.h"

@interface SetTableViewController ()

@end

@implementation SetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 6){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ihoin.com/zh/contact.html"]];
    }
    if(indexPath.row == 7){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ihoin.com/zh/about.html"]];
    }
}


@end
