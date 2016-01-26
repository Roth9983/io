//
//  AlertConnectSuccess.m
//  iTag
//
//  Created by Jason Tsai on 2016/1/26.
//  Copyright © 2016年 NFC. All rights reserved.
//

#import "AlertConnectSuccess.h"
#import "ScanViewController.h"
@implementation AlertConnectSuccess
float w1, h1, wRatio1, hRatio1;
float fontSize1;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    NSLog(@"uiview alertConnecting %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [self getScreenSize];

    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(32*wRatio1, 229*hRatio1, 351*wRatio1, 279*hRatio1)];
    else
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(59*wRatio1, 253*hRatio1, 651*wRatio1, 518*hRatio1)];
    imageView.image = [UIImage imageNamed:@"warning_bg"];
    [self addSubview:imageView];
    
    UILabel *label;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80*hRatio1, imageView.bounds.size.width, 50*hRatio1)];
    else
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150*hRatio1, imageView.bounds.size.width, 50*hRatio1)];
    label.text = @"Connecting...";
    label.textColor = [UIColor colorWithRed:47.0/255.0 green:214.0/255.0 blue:255.0/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Heiti TC" size:fontSize1];
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    
    UIActivityIndicatorView *connecting = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    connecting.center = CGPointMake(imageView.bounds.size.width/2, imageView.bounds.size.height/2+30*hRatio1);
    connecting.color = [UIColor colorWithRed:47.0/255.0 green:214.0/255.0 blue:255.0/255.0 alpha:1.0];
    [connecting startAnimating];
    [imageView addSubview:connecting];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToStopConnect)];
    [self addGestureRecognizer:tap];
    
    return self;
}

- (void)tapToStopConnect{
    NSLog(@"uiview alert taptostop");
    [self removeFromSuperview];
    
    [[ScanViewController new] stopScan];
}

- (void)getScreenSize{
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    float ow, oh;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        ow = 414;
        oh = 736;
    }else{
        ow = 768;
        oh = 1024;
    }
    
    if(mainSize.width < mainSize.height){
        w1 = mainSize.width;
        h1 = mainSize.height;
        wRatio1 = mainSize.width/ow;
        hRatio1 = mainSize.height/oh;
    }else{
        w1 = mainSize.height;
        h1 = mainSize.width;
        wRatio1 = mainSize.height/ow;
        hRatio1 = mainSize.width/oh;
    }
    
    //NSLog(@"-------------------\nScreen data:\n基準w : %f\n基準h : %f\n螢幕w : %f\n螢幕h : %f\nw ratio : %f\nh ratio : %f\n-------------------", ow, oh, w, h, wRatio, hRatio);
    
    if(w1 <= 320)
        fontSize1 = 20;
    else if(w1 <=414)
        fontSize1 = 30;
    else
        fontSize1 = 40;
}

@end
