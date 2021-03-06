//
//  ViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/1.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//
/**
 *	@author Roth, 16-02-25 12:02:30
 *
 *	@brief
        1.設定需要用到的NSUserDefaults key值
        2.處理已配對狀態下，每次開啟時的自動連線
            viewDidAppear - 判斷連線狀態並處理連線、設置sensor delegate
            viewWillDisappear - 記得移除senslr delegate
        3.設定UI介面（詳細說明註解在setMainUI裡，其它頁面的UI設定方法都相似）
        4.設定NSUserDefaults的NSNotification以處理臨時斷線或連線
        5.buttons' action - 前往各頁面
        6.alert設定 - 對各種連線狀態顯示對應alert（每頁面設定方法相似）
 *  @note - 電池電量偵測未完成
 *
 */
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize vCardButton, doorAccessButton, autoPhotoButton, settingsButton, searchButton;
@synthesize powerImageview;
@synthesize peripheralArray;//記錄搜尋到的peripheral用來跟配對的比較，SmcGATT.m有-(void) connect: (CBPeripheral *)peripheral;可以直接連不用比較後再連，但是我測試後都會當機
@synthesize sensor;
NSUserDefaults *mainUdf;
bool firstSet = false;//根據[mainUdf setBool:YES forKey:@"firstUse"]判斷是否為第一次使用。

ScanViewController *scanV;//ScanViewController *scanV; - 若無配對 -> present scan 頁面進行io偵測;已配對 -> 在背後自動連線

AlertViewController *alertVC;//使用各種alert的VC
UIView *alertView;//要顯示alert的view

UIView *flashView;//閃光動畫的view
NSTimer *flashTimer;//閃光動畫的時間間隔

UIScrollView *scrollCircleText;//遮擋一半圓形動畫的scroll view
UIImageView *imageCircleText;//顯示圓形動畫的image view

#pragma mark main view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    scanV = [ScanViewController new];
    alertVC = [AlertViewController new];
    mainUdf = [NSUserDefaults standardUserDefaults];
    
    if(![mainUdf objectForKey:@"firstUse"]){
        NSLog(@"first use");
        firstSet = true;
        [mainUdf setBool:YES forKey:@"firstUse"];
        [mainUdf setObject:@"defaultID" forKey:@"tagID"];
        [mainUdf setObject:[[NSDictionary alloc] init] forKey:@"vCard"];
        [mainUdf setInteger:3 forKey:@"beepTime"];
        [mainUdf setObject:[[NSArray alloc] init] forKey:@"door"];
        [mainUdf setObject:[[NSArray alloc] init] forKey:@"keyName"];
    }

    [mainUdf setObject:@"n" forKey:@"connect"];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self setMainUI];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    self.sensor.delegate = nil;
    
    [flashTimer invalidate];
    flashTimer = nil;
    
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
            UIViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"scan"];
            [self presentViewController:scan animated:YES completion:nil];
        }else if(![[mainUdf objectForKey:@"connect"] isEqualToString:@"y"] && ![[mainUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
            NSLog(@"no connect");
            
            [scanV autoConnectTag];
            [self showConnectStateAlert:0 info:nil];
        }else{
            BleController *shareBERController = [BleController sharedController];
            sensor = shareBERController.sensor;
            sensor.delegate = self;
        }
    }
    NSLog(@"finish auto connect");
    
    NSLog(@"Name : %@",sensor.activePeripheral.name);
    
    flashTimer = [NSTimer timerWithTimeInterval:6 target:self selector:@selector(handleFlash) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
    
    [self runSpinAnimationOnView:imageCircleText clockwise:1 rotation:0.05];
}

#pragma mark main UI setting
- (void)setMainUI{
    //先取得螢幕比例
    float wRatio = [alertVC getSizeWRatio];
    float hRatio = [alertVC getSizeHRatio];
    NSLog(@"ratio : %f, %f", wRatio, hRatio);
    
    if([alertVC getSizeH] != 480)
        [self.view addSubview:[alertVC setBGImageView:[UIImage imageNamed:@"bg_main"]]];
    else{
        [self.view addSubview:[alertVC setBGImageView:[UIImage imageNamed:@"bg_main35_1"]]];
        UIImageView *bgMain2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 85*hRatio, [alertVC getSizeW], [alertVC getSizeH]-85)];
        bgMain2.contentMode = UIViewContentModeScaleAspectFit;
        bgMain2.image = [UIImage imageNamed:@"bg_main35_2"];
        [self.view addSubview:bgMain2];
    }
    
    //初始化、setImage、setFrame要分開處理
    //1.各個object先初始化
    powerImageview = [UIImageView new];
    settingsButton = [UIButton new];
    vCardButton = [UIButton new];
    doorAccessButton = [UIButton new];
    autoPhotoButton = [UIButton new];
    searchButton = [UIButton new];
    
    //2.設定圖片(Normal、Highlight)
    [settingsButton setImage:[UIImage imageNamed:@"setting01"] forState:UIControlStateNormal];
    [vCardButton setImage:[UIImage imageNamed:@"vcard01"] forState:UIControlStateNormal];
    [doorAccessButton setImage:[UIImage imageNamed:@"key01"] forState:UIControlStateNormal];
    [autoPhotoButton setImage:[UIImage imageNamed:@"selfie01"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"find01"] forState:UIControlStateNormal];
    
    [settingsButton setImage:[UIImage imageNamed:@"setting02"] forState:UIControlStateHighlighted];
    [vCardButton setImage:[UIImage imageNamed:@"vcard02"] forState:UIControlStateHighlighted];
    [doorAccessButton setImage:[UIImage imageNamed:@"key02"] forState:UIControlStateHighlighted];
    [autoPhotoButton setImage:[UIImage imageNamed:@"selfie02"] forState:UIControlStateHighlighted];
    [searchButton setImage:[UIImage imageNamed:@"find02"] forState:UIControlStateHighlighted];
    
    powerImageview.image = [UIImage imageNamed:@"power01"];

    //3.先設定好圖片再設定frame，就不用一一輸入圖片size，可以用object.imageView.image.size.width(height)代替
    //  不然就得一直開啟原始圖檔抓取圖片大小做size運算
    //  配合小毛的圖檔設計，分別處理ipad跟iphone
    //  3.5"螢幕通常要另外處理
    float cRatio = (wRatio+hRatio)/2;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        flashView = [[UIView alloc] initWithFrame:CGRectMake(-600, 0, 600, 735)];
        
        if([alertVC getSizeH] != 480){
            scrollCircleText = [[UIScrollView alloc] initWithFrame:CGRectMake(67*wRatio, 85*hRatio, 280*cRatio, 140*cRatio)];
            scrollCircleText.center = CGPointMake([alertVC getSizeW]/2, 85*hRatio+(140*cRatio)/2);
            scrollCircleText.contentSize = CGSizeMake(280*cRatio, 280*cRatio);
            imageCircleText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280*cRatio, 280*cRatio)];
        
            [powerImageview setFrame:CGRectMake(222*wRatio, 26*hRatio, powerImageview.image.size.width*wRatio, powerImageview.image.size.height*hRatio)];
            [settingsButton setFrame:CGRectMake(296*wRatio, 15*hRatio, settingsButton.imageView.image.size.width*wRatio, settingsButton.imageView.image.size.height*hRatio)];
            [vCardButton setFrame:CGRectMake(108*wRatio, 268*hRatio, vCardButton.imageView.image.size.width*wRatio, vCardButton.imageView.image.size.height*hRatio)];
            [doorAccessButton setFrame:CGRectMake(222*wRatio, 369*hRatio, doorAccessButton.imageView.image.size.width*wRatio, doorAccessButton.imageView.image.size.height*hRatio)];
            [autoPhotoButton setFrame:CGRectMake(113*wRatio, 468*hRatio, autoPhotoButton.imageView.image.size.width*wRatio, autoPhotoButton.imageView.image.size.height*hRatio)];
            [searchButton setFrame:CGRectMake(216*wRatio, 568*hRatio, searchButton.imageView.image.size.width*wRatio, searchButton.imageView.image.size.height*hRatio)];
        }else{
            scrollCircleText = [[UIScrollView alloc] initWithFrame:CGRectMake(67*wRatio, 85*hRatio, 280*hRatio, 130*hRatio)];
            scrollCircleText.center = CGPointMake([alertVC getSizeW]/2, 85*hRatio+(140*hRatio)/2);
            scrollCircleText.contentSize = CGSizeMake(280*hRatio, 280*hRatio);
            imageCircleText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280*hRatio, 280*hRatio)];
            
            [powerImageview setFrame:CGRectMake(222*wRatio, 26*hRatio, powerImageview.image.size.width*wRatio, powerImageview.image.size.height*hRatio)];
            [settingsButton setFrame:CGRectMake(296*wRatio, 15*hRatio, settingsButton.imageView.image.size.width*wRatio, settingsButton.imageView.image.size.height*hRatio)];
            [vCardButton setFrame:CGRectMake(108*wRatio+11.5, 268*hRatio+2.5, vCardButton.imageView.image.size.width*hRatio, vCardButton.imageView.image.size.height*hRatio)];
            [doorAccessButton setFrame:CGRectMake(222*wRatio-1, 369*hRatio+3, doorAccessButton.imageView.image.size.width*hRatio, doorAccessButton.imageView.image.size.height*hRatio)];
            [autoPhotoButton setFrame:CGRectMake(113*wRatio+11.5, 468*hRatio+5, autoPhotoButton.imageView.image.size.width*hRatio, autoPhotoButton.imageView.image.size.height*hRatio)];
            [searchButton setFrame:CGRectMake(216*wRatio-0.5, 568*hRatio+6, searchButton.imageView.image.size.width*hRatio, searchButton.imageView.image.size.height*hRatio)];
        }
    }else{
        flashView = [[UIView alloc] initWithFrame:CGRectMake(-835, 0, 835, 1024)];
        
        scrollCircleText = [[UIScrollView alloc] initWithFrame:CGRectMake(174*wRatio, 158*hRatio, 420*wRatio, 192*hRatio)];
        scrollCircleText.contentSize = CGSizeMake(420*wRatio, 420*hRatio);
        imageCircleText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 420*wRatio, 420*hRatio)];
        
        [powerImageview setFrame:CGRectMake(412*wRatio, 47*hRatio, powerImageview.image.size.width*wRatio, powerImageview.image.size.height*hRatio)];
        [settingsButton setFrame:CGRectMake(550*wRatio, 28*hRatio, settingsButton.imageView.image.size.width*wRatio, settingsButton.imageView.image.size.height*hRatio)];
        [vCardButton setFrame:CGRectMake(243*wRatio, 394*hRatio, vCardButton.imageView.image.size.width*wRatio, vCardButton.imageView.image.size.height*hRatio)];
        [doorAccessButton setFrame:CGRectMake(406*wRatio, 537*hRatio, doorAccessButton.imageView.image.size.width*wRatio, doorAccessButton.imageView.image.size.height*hRatio)];
        [autoPhotoButton setFrame:CGRectMake(251*wRatio, 679*hRatio, autoPhotoButton.imageView.image.size.width*wRatio, autoPhotoButton.imageView.image.size.height*hRatio)];
        [searchButton setFrame:CGRectMake(398*wRatio, 823*hRatio, searchButton.imageView.image.size.width*wRatio, searchButton.imageView.image.size.height*hRatio)];
    }
    
    [settingsButton addTarget:self action:@selector(toSet:) forControlEvents:UIControlEventTouchUpInside];
    [vCardButton addTarget:self action:@selector(toVCard:) forControlEvents:UIControlEventTouchUpInside];
    [doorAccessButton addTarget:self action:@selector(toDoorAccess:) forControlEvents:UIControlEventTouchUpInside];
    [autoPhotoButton addTarget:self action:@selector(toAutoTake:) forControlEvents:UIControlEventTouchUpInside];
    [searchButton addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:powerImageview];
    [self.view addSubview:settingsButton];
    [self.view addSubview:vCardButton];
    [self.view addSubview:doorAccessButton];
    [self.view addSubview:autoPhotoButton];
    [self.view addSubview:searchButton];

    CGPoint bottomOffset = CGPointMake(0, scrollCircleText.contentSize.height - scrollCircleText.bounds.size.height);
    [scrollCircleText setContentOffset:bottomOffset animated:YES];
    scrollCircleText.scrollEnabled = false;
    
    imageCircleText.image = [UIImage imageNamed:@"circletext"];
    [scrollCircleText addSubview:imageCircleText];

    [self.view addSubview:scrollCircleText];
    
    [flashView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_flash.png"]]];
    [self.view addSubview:flashView];
    
    powerImageview.hidden = true;
}

//字串圖轉圈動畫
- (void)runSpinAnimationOnView:(UIView*)view clockwise:(int)clockwise rotation:(float)rotation{
    NSLog(@"~ animation");
    CABasicAnimation* rotationAnimation;
    CGFloat duration = 1.0;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * (rotation * clockwise) * duration];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = FLT_MAX;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//閃光動畫
- (void)handleFlash{
    NSLog(@"handleFlash");
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [flashView setFrame:CGRectMake(-600, 0, 600, 735)];
    }else{
        [flashView setFrame:CGRectMake(-835, 0, 835, 1024)];
    }
    [UIView animateWithDuration:1 animations:^{
        flashView.center = CGPointMake([alertVC getSizeW] + flashView.frame.size.width/2, [alertVC getSizeH]/2);
    }];
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

#pragma mark main handle connect state
- (void) udfHandle{
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    
    NSString *str = [mainUdf objectForKey:@"connect"];
    
    if([str isEqualToString:@"y"]){
        NSLog(@"connect state : success");
        [self showConnectStateAlert:1 info:nil];
        
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    }else if([str isEqualToString:@"n"]){
        NSLog(@"connect state : failed");
        [self showConnectStateAlert:2 info:nil];
        
    }else if([str isEqualToString:@"t"]){
        NSLog(@"connect state : timeout");
        
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
    }
    
    if([mainUdf boolForKey:@"fore"])
        [self runSpinAnimationOnView:imageCircleText clockwise:1 rotation:0.05];
}

//連線錯誤alert搭配的button選項
- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try");
        [scanV autoConnectTag];
        [self showConnectStateAlert:0 info:nil];
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

#pragma mark main button actions
- (void)toVCard:(id)sender {
    UIViewController *vCard = [self.storyboard instantiateViewControllerWithIdentifier:@"vCard"];
    [self presentViewController:vCard animated:YES completion:nil];
}

- (void)toDoorAccess:(id)sender {
    UIViewController *door = [self.storyboard instantiateViewControllerWithIdentifier:@"door"];
    [self presentViewController:door animated:YES completion:nil];
}


- (void)toAutoTake:(id)sender {
    UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"camera"];
    [self presentViewController:camera animated:YES completion:nil];
}

- (void)toSet:(id)sender {
    UIViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"set"];
    [self presentViewController:set animated:YES completion:nil];
}

- (void)toSearch:(id)sender {
    UIViewController *search = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self presentViewController:search animated:YES completion:nil];
}

#pragma mark main BTSmartSensorDelegate
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

#pragma mark - alert
- (void)showConnectStateAlert:(int)state info:(NSString *)info{
    [alertView removeFromSuperview];
    alertView = nil;
    switch (state) {
        case 0:{
            //connecting
            alertView = [alertVC alertConnecting];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToStopConnect)];
            [alertView addGestureRecognizer:tap];
        }
            break;
        case 1:{
            //connect success
            alertView = [alertVC alertConnectSuccess];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
            [alertView addGestureRecognizer:tap];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
        }
            break;
        case 2:{
            //connect failed
            alertView = [alertVC alertConnectError];
            
            UIButton *tryButton = [alertVC getTryBurtton];
            [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *cancelButton = [alertVC getCancelButton];
            [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [alertView addSubview:tryButton];
            [alertView addSubview:cancelButton];
        }
            break;
        case 3:
            //custom alert
            break;
        default:
            break;
    }
    [self.view addSubview:alertView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
