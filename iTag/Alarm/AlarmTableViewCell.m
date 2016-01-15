//
//  AlarmTableViewCell.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/7.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import "AlarmTableViewCell.h"

@implementation AlarmTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)checkbox:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[udf arrayForKey:@"alarms"]];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[array objectAtIndex:tag]];
    if([[dic valueForKey:@"select"] isEqualToString:@"t"]){
        [dic setValue:@"f" forKey:@"select"];
    
        [self.checkboxButton setImage:[UIImage imageNamed:@"select_no.png"] forState:UIControlStateNormal];
    }else{
        [dic setValue:@"t" forKey:@"select"];
        
        [self.checkboxButton setImage:[UIImage imageNamed:@"select_yes.png"] forState:UIControlStateNormal];
    }
    [array replaceObjectAtIndex:tag withObject:dic];
    [udf setObject:array forKey:@"alarms"];
}
@end
