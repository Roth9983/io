//
//  AlertViewController.m
//  iTag
//
//  Created by Jason Tsai on 2015/12/31.
//  Copyright © 2015年 NFC. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController ()

@end

@implementation AlertViewController
@synthesize peripheralArrayS;
@synthesize sensor;

float w, h, wRatio, hRatio;
float fontSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        w = mainSize.width;
        h = mainSize.height;
        wRatio = mainSize.width/ow;
        hRatio = mainSize.height/oh;
    }else{
        w = mainSize.height;
        h = mainSize.width;
        wRatio = mainSize.height/ow;
        hRatio = mainSize.width/oh;
    }
    
    //NSLog(@"-------------------\nScreen data:\n基準w : %f\n基準h : %f\n螢幕w : %f\n螢幕h : %f\nw ratio : %f\nh ratio : %f\n-------------------", ow, oh, w, h, wRatio, hRatio);
    
    if(w <= 320)
        fontSize = 20;
    else if(w <=414)
        fontSize = 30;
    else
        fontSize = 40;
}

- (float)getSizeW{
    [self getScreenSize];
    return w;
}

- (float)getSizeH{
    [self getScreenSize];
    return h;
}

- (float)getSizeWRatio{
    [self getScreenSize];
    return wRatio;
}

- (float)getSizeHRatio{
    [self getScreenSize];
    return hRatio;
}

- (UIButton *)getTryBurtton{
    UIButton *tryButton;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        tryButton = [[UIButton alloc] initWithFrame:CGRectMake(69*[self getSizeWRatio], 385*[self getSizeHRatio], 123*[self getSizeWRatio], 37*[self getSizeHRatio])];
    else
        tryButton = [[UIButton alloc] initWithFrame:CGRectMake(132*[self getSizeWRatio], 541*[self getSizeHRatio], 226*[self getSizeWRatio], 67*[self getSizeHRatio])];
    [tryButton setImage:[UIImage imageNamed:@"try01"] forState:UIControlStateNormal];
    [tryButton setImage:[UIImage imageNamed:@"try02"] forState:UIControlStateHighlighted];
    tryButton.tag = 0;
    
    return tryButton;
}

- (UIButton *)getCancelButton{
    UIButton *cancelButton;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(223*[self getSizeWRatio], 385*[self getSizeHRatio], 123*[self getSizeWRatio], 37*[self getSizeHRatio])];
    else
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(411*[self getSizeWRatio], 541*[self getSizeHRatio], 226*[self getSizeWRatio], 67*[self getSizeHRatio])];
    [cancelButton setImage:[UIImage imageNamed:@"cancel01"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"cancel02"] forState:UIControlStateHighlighted];
    cancelButton.tag = 1;
    
    return cancelButton;
}

- (UIImageView *)setBGImageView:(UIImage *)image{
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self getSizeW], [self getSizeH])];
    bgImageView.image = image;
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    return bgImageView;
}

- (UIView *)alertConnectSuccess{
    NSLog(@"alertConnectSuccess");
    [self getScreenSize];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(32*wRatio, 276*hRatio, 351*wRatio, 185*hRatio)];
    else
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(59*wRatio, 340*hRatio, 651*wRatio, 345*hRatio)];
    imageView.image = [UIImage imageNamed:@"already_connect"];
    [bgView addSubview:imageView];
    
    return bgView;
}

- (UIView *)alertConnectError{
    NSLog(@"alertConnectError");
    [self getScreenSize];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(32*wRatio, 229*hRatio, 357*wRatio, 279*hRatio)];
    else
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(59*wRatio, 253*hRatio, 651*wRatio, 518*hRatio)];
    imageView.image = [UIImage imageNamed:@"connect_error"];
    [bgView addSubview:imageView];
    
    return bgView;
}

- (UIView *)alertIONotFound{
    NSLog(@"alertIONotFound");
    [self getScreenSize];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(32*wRatio, 229*hRatio, 357*wRatio, 279*hRatio)];
    else
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(59*wRatio, 253*hRatio, 651*wRatio, 518*hRatio)];
    imageView.image = [UIImage imageNamed:@"ionotfound"];
    [bgView addSubview:imageView];
    
    return bgView;
}

- (UIView *)alertConnecting{
    NSLog(@"alertConnecting");
    [self getScreenSize];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(32*wRatio, 229*hRatio, 351*wRatio, 279*hRatio)];
    else
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(59*wRatio, 253*hRatio, 651*wRatio, 518*hRatio)];
    imageView.image = [UIImage imageNamed:@"warning_bg"];
    [bgView addSubview:imageView];
    
    UILabel *label;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80*hRatio, imageView.bounds.size.width, 50*hRatio)];
    else
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150*hRatio, imageView.bounds.size.width, 50*hRatio)];
    label.text = @"Connecting...";
    label.textColor = [UIColor colorWithRed:47.0/255.0 green:214.0/255.0 blue:255.0/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Heiti TC" size:fontSize];
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    
    UIActivityIndicatorView *connecting = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    connecting.center = CGPointMake(imageView.bounds.size.width/2, imageView.bounds.size.height/2+30*hRatio);
    connecting.color = [UIColor colorWithRed:47.0/255.0 green:214.0/255.0 blue:255.0/255.0 alpha:1.0];
    [connecting startAnimating];
    [imageView addSubview:connecting];
    
    return bgView;
}

- (UIView *)alertCustom:(NSString *)str{
    [self getScreenSize];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(32*wRatio, 229*hRatio, 351*wRatio, 279*hRatio)];
    else
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(59*wRatio, 253*hRatio, 651*wRatio, 518*hRatio)];
    imageView.image = [UIImage imageNamed:@"warning_bg"];
    [bgView addSubview:imageView];
    
    UILabel *label;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bounds.size.height/2-25*hRatio, imageView.bounds.size.width, 50*hRatio)];
    else
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bounds.size.height/2-25*hRatio, imageView.bounds.size.width, 50*hRatio)];
    label.text = str;
    label.textColor = [UIColor colorWithRed:47.0/255.0 green:214.0/255.0 blue:255.0/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Heiti TC" size:fontSize];
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    
    return bgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
