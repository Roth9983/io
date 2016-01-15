//
//  ViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/1.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize vCardButton, doorAccessButton, autoPhotoButton, settingsButton, searchButton;
@synthesize powerImageview;
@synthesize peripheralArray;

NSUserDefaults *mainUdf;
bool firstSet = false;

ScanViewController *scanV;

AlertViewController *alertVC;
UIView *alertView;

@synthesize sensor;

#pragma mark view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    mainUdf = [NSUserDefaults standardUserDefaults];
    //[mainUdf removeObjectForKey:@"firstUse"];
    if(![mainUdf objectForKey:@"firstUse"]){
        NSLog(@"first use");
        firstSet = true;
        [mainUdf setBool:YES forKey:@"firstUse"];
        [mainUdf setObject:@"defaultID" forKey:@"tagID"];
        [mainUdf setObject:[[NSArray alloc] init] forKey:@"vCard"];
        [mainUdf setInteger:3 forKey:@"beepTime"];
        [mainUdf setObject:[[NSArray alloc] init] forKey:@"door"];
        [mainUdf setObject:[[NSArray alloc] init] forKey:@"keyName"];
    }else{
        NSLog(@"! first use\n%@", [mainUdf objectForKey:@"tagID"]);
    }
    [mainUdf setObject:@"1.0" forKey:@"version"];
    [mainUdf setObject:@"n" forKey:@"connect"];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
   // self.sensor.delegate = (ViewController *) self;
    
    alertVC = [[AlertViewController alloc] init];
    scanV = [[ScanViewController alloc] init];
    
    [self setMainUI];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    self.sensor.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    
    self.sensor.delegate = (ViewController *) self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");//View 呈現後
    
    //CBPeripheral *cp = (CBPeripheral*)[[mainUdf arrayForKey:@"device"] objectAtIndex:0];
    //NSLog(@"cp : %@", cp.identifier);
    if(firstSet){
        NSLog(@"first use scan");
        firstSet = false;
        UIViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"scan"];
        [self presentViewController:scan animated:NO completion:nil];
        BleController *shareBERController = [BleController sharedController];
        sensor = shareBERController.sensor;
        sensor.delegate = self;
    }else{
        NSLog(@"auto connect");
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(udfHandle)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
        if([[mainUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
            NSLog(@"pair io");
            [alertView removeFromSuperview];
            alertView = nil;
            alertView = [alertVC alertCustom:@"Please pair the io !"];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
            [alertView addGestureRecognizer:tap];
            [self.view addSubview:alertView];
        }else if(![[mainUdf objectForKey:@"connect"] isEqualToString:@"y"] && ![[mainUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
            NSLog(@"no connect");
            
            [scanV autoConnectTag];
            //[scanV autoConnectTag2:[mainUdf objectForKey:@"tagID"]];
            //NSUUID *uuid = [[NSUUID UUID] initWithUUIDString:[mainUdf objectForKey:@"tagID"]];
            
            [alertView removeFromSuperview];
            alertView = nil;
            alertView = [alertVC alertConnecting];
            
            [self.view addSubview:alertView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToStopConnect)];
            [alertView addGestureRecognizer:tap];
            
        }else{
            BleController *shareBERController = [BleController sharedController];
            sensor = shareBERController.sensor;
            sensor.delegate = self;
        }
    }
    NSLog(@"finish auto connect");
    
    NSLog(@"Name : %@",sensor.activePeripheral.name);
}

#pragma mark main UI setting
- (void)setMainUI{
    float wRatio = [alertVC getSizeWRatio];
    float hRatio = [alertVC getSizeHRatio];
    
    [self.view addSubview:[alertVC setBGImageView:[UIImage imageNamed:@"bg_main"]]];
    
    [self.view bringSubviewToFront:powerImageview];
    [self.view bringSubviewToFront:settingsButton];
    [self.view bringSubviewToFront:vCardButton];
    [self.view bringSubviewToFront:doorAccessButton];
    [self.view bringSubviewToFront:autoPhotoButton];
    [self.view bringSubviewToFront:searchButton];
    
    [powerImageview setTranslatesAutoresizingMaskIntoConstraints:YES];
    [settingsButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [vCardButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [doorAccessButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [autoPhotoButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [searchButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [powerImageview setFrame:CGRectMake(222*wRatio, 26*hRatio, powerImageview.image.size.width*wRatio, powerImageview.image.size.height*hRatio)];
        [settingsButton setFrame:CGRectMake(296*wRatio, 15*hRatio, settingsButton.imageView.image.size.width*wRatio, settingsButton.imageView.image.size.height*hRatio)];
        [vCardButton setFrame:CGRectMake(108*wRatio, 268*hRatio, vCardButton.imageView.image.size.width*wRatio, vCardButton.imageView.image.size.height*hRatio)];
        [doorAccessButton setFrame:CGRectMake(222*wRatio, 369*hRatio, doorAccessButton.imageView.image.size.width*wRatio, doorAccessButton.imageView.image.size.height*hRatio)];
        [autoPhotoButton setFrame:CGRectMake(113*wRatio, 468*hRatio, autoPhotoButton.imageView.image.size.width*wRatio, autoPhotoButton.imageView.image.size.height*hRatio)];
        [searchButton setFrame:CGRectMake(216*wRatio, 568*hRatio, searchButton.imageView.image.size.width*wRatio, searchButton.imageView.image.size.height*hRatio)];
    }else{
        [powerImageview setFrame:CGRectMake(412*wRatio, 47*hRatio, powerImageview.image.size.width*wRatio, powerImageview.image.size.height*hRatio)];
        
        [settingsButton setFrame:CGRectMake(550*wRatio, 28*hRatio, settingsButton.imageView.image.size.width*wRatio, settingsButton.imageView.image.size.height*hRatio)];
        [vCardButton setFrame:CGRectMake(243*wRatio, 394*hRatio, vCardButton.imageView.image.size.width*wRatio, vCardButton.imageView.image.size.height*hRatio)];
        [doorAccessButton setFrame:CGRectMake(406*wRatio, 537*hRatio, doorAccessButton.imageView.image.size.width*wRatio, doorAccessButton.imageView.image.size.height*hRatio)];
        [autoPhotoButton setFrame:CGRectMake(251*wRatio, 679*hRatio, autoPhotoButton.imageView.image.size.width*wRatio, autoPhotoButton.imageView.image.size.height*hRatio)];
        [searchButton setFrame:CGRectMake(398*wRatio, 823*hRatio, searchButton.imageView.image.size.width*wRatio, searchButton.imageView.image.size.height*hRatio)];
    }
    
    [settingsButton setImage:[UIImage imageNamed:@"setting02"] forState:UIControlStateHighlighted];
    [vCardButton setImage:[UIImage imageNamed:@"vcard02"] forState:UIControlStateHighlighted];
    [doorAccessButton setImage:[UIImage imageNamed:@"key02"] forState:UIControlStateHighlighted];
    [autoPhotoButton setImage:[UIImage imageNamed:@"selfie02"] forState:UIControlStateHighlighted];
    [searchButton setImage:[UIImage imageNamed:@"find02"] forState:UIControlStateHighlighted];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark handle connect state
- (void) udfHandle{
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    
    NSString *str = [mainUdf objectForKey:@"connect"];
    
    if([str isEqualToString:@"y"]){
        NSLog(@"connect state : success");
        
        [alertView removeFromSuperview];
        alertView = nil;
        alertView = [alertVC alertConnectSuccess];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
        [alertView addGestureRecognizer:tap];
        
        [self.view addSubview:alertView];
        
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    }else if([str isEqualToString:@"n"]){
        NSLog(@"connect state : failed");
        
        [alertView removeFromSuperview];
        alertView = nil;
        alertView = [alertVC alertConnectError];
        
        [self.view addSubview:alertView];
        
        UIButton *tryButton = [alertVC getTryBurtton];
        [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [alertVC getCancelButton];
        [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [alertView addSubview:tryButton];
        [alertView addSubview:cancelButton];
        
    }else if([str isEqualToString:@"t"]){
        NSLog(@"connect state : timeout");
        
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
    }
}

- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try");
        [scanV autoConnectTag];
        
        [alertView removeFromSuperview];
        alertView = nil;
        alertView = [alertVC alertConnecting];
        [self.view addSubview:alertView];
    }else{
        NSLog(@"cancel");
        [button.superview removeFromSuperview];
    }
}

- (void)connectTimeout{
    NSLog(@"%@", [mainUdf objectForKey:@"connect"]);
    if(![[mainUdf objectForKey:@"connect"] isEqualToString:@"y"])
        [mainUdf setObject:@"n" forKey:@"connect"];
}

- (void)dismissAlert{
    NSLog(@"dismiss alert");
    if(alertView != nil){
        [alertView removeFromSuperview];
        alertView = nil;
    }
}

- (void)tapToStopConnect{
    [alertView removeFromSuperview];
    alertView = nil;
    
    [scanV stopScan];
}

//- (IBAction)goback:(id)sender {
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
//    
//}

#pragma mark button actions
- (IBAction)toVCard:(id)sender {
    UIViewController *vCard = [self.storyboard instantiateViewControllerWithIdentifier:@"vCard"];
    [self presentViewController:vCard animated:YES completion:nil];
}

- (IBAction)toDoorAccess:(id)sender {
    UIViewController *door = [self.storyboard instantiateViewControllerWithIdentifier:@"door"];
    [self presentViewController:door animated:YES completion:nil];
}


- (IBAction)toAutoTake:(id)sender {
    UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"camera"];
    [self presentViewController:camera animated:YES completion:nil];
}

- (IBAction)toSet:(id)sender {
    UIViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"set"];
    [self presentViewController:set animated:YES completion:nil];
}

- (IBAction)toSearch:(id)sender {
    UIViewController *search = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self presentViewController:search animated:YES completion:nil];
}

#pragma mark BTSmartSensorDelegate
//取得資料整理
-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    NSLog(@"data     %@",value);
}

//連線成功
-(void)setConnect
{
    NSLog(@"MAIN : OK+CONN");
    [mainUdf setObject:@"y" forKey:@"connect"];
    //[self showOkayCancelAlert:@"iTag connected\niTag連線成功"];
}

//斷線
-(void)setDisconnect
{
    NSLog(@"MAIN : OK+LOST");
    [mainUdf setObject:@"n" forKey:@"connect"];
    //[self showOkayCancelAlert:@"iTag disconnected\niTag連線失敗"];
}

-(NSString*) NSDataToHex:(NSData*)data
{
    const unsigned char *dbytes = [data bytes];
    NSMutableString *hexStr =
    [NSMutableString stringWithCapacity:[data length]*2];
    int i;
    for (i = 0; i < [data length]; i++) {
        [hexStr appendFormat:@"%02x", dbytes[i]];
    }
    return [NSString stringWithString: hexStr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
