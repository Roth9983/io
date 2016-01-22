//
//  SearchViewController.m
//  iTag
//
//  Created by Jason Tsai on 2015/12/22.
//  Copyright © 2015年 NFC. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize connectStateImageView;
@synthesize searchWordImageView;
@synthesize radar1ImageView, radar2ImageView, radar3ImageView, radar4ImageView, radar5ImageView;
@synthesize ioAnimationImageView;
@synthesize searchBackButton;
@synthesize peripheralArrayS;
@synthesize sensor;

NSUserDefaults *searchUdf;
AlertViewController *alertVCSearch;
UIView *alertViewSearch;
NSTimer *beepTimer;
int beepCount;
ScanViewController *ScanS;

UIImageView *searchLightImageView;
UIButton *beepButton;

UIImageView *tapAlertAnimationImageView;

#pragma mark search view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    searchUdf = [NSUserDefaults standardUserDefaults];
    alertVCSearch = [AlertViewController new];
    ScanS = [ScanViewController new];
    
    [self setSearchUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"search");
    self.sensor.delegate = (SearchViewController *) self;
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udfHandle) name:NSUserDefaultsDidChangeNotification object:nil];
    
    beepButton.enabled = false;
    if([[searchUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
        NSLog(@"pair io");
        [self searchRLightAnimation];
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
        alertViewSearch = [alertVCSearch alertCustom:@"Please pair the io !"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
        [alertViewSearch addGestureRecognizer:tap];
        [self.view addSubview:alertViewSearch];
    }else if(![[searchUdf objectForKey:@"connect"] isEqualToString:@"y"] && ![[searchUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
        NSLog(@"no connect");
        
        searchWordImageView.image = [UIImage imageNamed:@"search1"];
        
        [self searchRLightAnimation];
        
        [ScanS autoConnectTag];
        
    }else{
        beepButton.enabled = true;
        
        [self connectedWordAnimation];
        [self searchGLightAnimation];
        
        [self startRadarAnimation];
        
        BleController *shareBERController = [BleController sharedController];
        sensor = shareBERController.sensor;
        sensor.delegate = self;
    }
    
    NSLog(@"Name : %@",sensor.activePeripheral.name);
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(![[searchUdf objectForKey:@"connect"] isEqualToString:@"y"])
        [ScanS stopScan];
    
    NSLog(@"search exit"); //view 將要結束
    self.sensor.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark search UI setting
- (void)setSearchUI{
    float wRatio = [alertVCSearch getSizeWRatio];
    float hRatio = [alertVCSearch getSizeHRatio];
    
    [self.view addSubview:[alertVCSearch setBGImageView:[UIImage imageNamed:@"bg_find"]]];
    
    UITapGestureRecognizer *tapToAlert = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAlert)];
    tapToAlert.delegate = self;
    
    UIView *tapView = [[UIView alloc] init];
    [tapView addGestureRecognizer:tapToAlert];
    
    [searchBackButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [connectStateImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [searchWordImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [radar1ImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [radar2ImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [radar3ImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [radar4ImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [radar5ImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        UIImageView *bg2ImageView;
        UIImageView *bgImageView_state;
        float radarRatio = (wRatio+hRatio)/2;
        
        [tapView setFrame:CGRectMake(0, 271*hRatio, [alertVCSearch getSizeW], 356*hRatio)];
        
        tapAlertAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22*wRatio, 348*hRatio, 370*wRatio, 205*hRatio)];
        tapAlertAnimationImageView.image = [UIImage imageNamed:@"m_01.png"];
        
        bgImageView_state = [[UIImageView alloc] initWithFrame:CGRectMake(33*wRatio, 99*hRatio, 347*wRatio, 126*hRatio)];
        bgImageView_state.image = [UIImage imageNamed:@"bg_find_state"];
        bgImageView_state.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:bgImageView_state];
        
        searchLightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(48*wRatio, 150*hRatio, 323*wRatio, 64*hRatio)];
        
        [searchBackButton setFrame:CGRectMake(32*wRatio, 15*hRatio, searchBackButton.imageView.image.size.width*wRatio, searchBackButton.imageView.image.size.height*hRatio)];
        [connectStateImageView setFrame:CGRectMake(139*wRatio, 107*hRatio, connectStateImageView.image.size.width*wRatio, connectStateImageView.image.size.height*hRatio)];
        connectStateImageView.center = CGPointMake(158*wRatio, 126*hRatio);
        [searchWordImageView setFrame:CGRectMake(66*wRatio, 176*hRatio, searchWordImageView.image.size.width*wRatio, searchWordImageView.image.size.height*hRatio)];
        
        bg2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(26*radarRatio, 271*radarRatio, 363*radarRatio, 356*radarRatio)];
        bg2ImageView.center = CGPointMake(207*wRatio, 449*hRatio);
        bg2ImageView.image = [UIImage imageNamed:@"bg_find2"];
        bg2ImageView.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:bg2ImageView];
        
        beepButton = [[UIButton alloc] initWithFrame:CGRectMake(130*wRatio, 249*hRatio, 155*wRatio, 49*hRatio)];
        
        [radar1ImageView setFrame:CGRectMake(72*wRatio, 317*hRatio, radar1ImageView.image.size.width*radarRatio, radar1ImageView.image.size.height*radarRatio)];
        radar1ImageView.center = CGPointMake(207*wRatio, 452*hRatio);
        [radar2ImageView setFrame:CGRectMake(112*wRatio, 357*hRatio, radar2ImageView.image.size.width*radarRatio, radar2ImageView.image.size.height*radarRatio)];
        radar2ImageView.center = CGPointMake(207*wRatio, 452*hRatio);
        [radar3ImageView setFrame:CGRectMake(127*wRatio, 372*hRatio, radar3ImageView.image.size.width*radarRatio, radar3ImageView.image.size.height*radarRatio)];
        radar3ImageView.center = CGPointMake(207*wRatio, 452*hRatio);
        [radar4ImageView setFrame:CGRectMake(303*wRatio, 546*hRatio, radar4ImageView.image.size.width*radarRatio, radar4ImageView.image.size.height*radarRatio)];
        radar4ImageView.center = CGPointMake(336*radarRatio, 579*radarRatio);
        radar4ImageView.center = CGPointMake(bg2ImageView.frame.origin.x+bg2ImageView.frame.size.width-53*radarRatio, bg2ImageView.frame.origin.y+bg2ImageView.frame.size.height-48*radarRatio);
        [radar5ImageView setFrame:CGRectMake(40*wRatio, 532*hRatio, radar5ImageView.image.size.width*radarRatio, radar5ImageView.image.size.height*radarRatio)];
        radar5ImageView.center = CGPointMake(57*radarRatio, 549*radarRatio);
        radar5ImageView.center = CGPointMake(bg2ImageView.frame.origin.x+31*radarRatio, bg2ImageView.frame.origin.y+bg2ImageView.frame.size.height-78*radarRatio);
        
        ioAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(147*radarRatio, 392*radarRatio, 120*radarRatio, 120*radarRatio)];
        ioAnimationImageView.center = CGPointMake(207*wRatio, 452*hRatio);
        
    }else{
        [tapView setFrame:CGRectMake(0, 410*hRatio, [alertVCSearch getSizeW], 576*hRatio)];
        
        tapAlertAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(23*wRatio, 492*hRatio, 723*wRatio, 400*hRatio)];
        tapAlertAnimationImageView.image = [UIImage imageNamed:@"m_01.png"];
        
        searchLightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(89*wRatio, 264*hRatio, 600*wRatio, 87*hRatio)];
        
        [searchBackButton setFrame:CGRectMake(63*wRatio, 28*hRatio, searchBackButton.imageView.image.size.width*wRatio, searchBackButton.imageView.image.size.height*hRatio)];
        [connectStateImageView setFrame:CGRectMake(266*wRatio, 192*hRatio, connectStateImageView.image.size.width*wRatio, connectStateImageView.image.size.height*hRatio)];
        [searchWordImageView setFrame:CGRectMake(119*wRatio, 304*hRatio, searchWordImageView.image.size.width*wRatio, searchWordImageView.image.size.height*hRatio)];
        
        beepButton = [[UIButton alloc] initWithFrame:CGRectMake(268*wRatio, 374*hRatio, 235*wRatio, 65*hRatio)];
        
        [radar1ImageView setFrame:CGRectMake(160*wRatio, 470*hRatio, radar1ImageView.image.size.width*wRatio, radar1ImageView.image.size.height*hRatio)];
        [radar2ImageView setFrame:CGRectMake(227*wRatio, 537*hRatio, radar2ImageView.image.size.width*wRatio, radar2ImageView.image.size.height*hRatio)];
        [radar3ImageView setFrame:CGRectMake(251*wRatio, 562*hRatio, radar3ImageView.image.size.width*wRatio, radar3ImageView.image.size.height*hRatio)];
        [radar4ImageView setFrame:CGRectMake(544*wRatio, 851*hRatio, radar4ImageView.image.size.width*wRatio, radar4ImageView.image.size.height*hRatio)];
        [radar5ImageView setFrame:CGRectMake(109*wRatio, 828*hRatio, radar5ImageView.image.size.width*wRatio, radar5ImageView.image.size.height*hRatio)];
        
        ioAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(284*wRatio, 590*hRatio, 200*wRatio, 200*hRatio)];
    }
    
    [self.view addSubview:searchLightImageView];
    
    [searchBackButton setImage:[UIImage imageNamed:@"back02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:searchBackButton];
    
    if([[searchUdf objectForKey:@"connect"] isEqualToString:@"y"]){
        connectStateImageView.image = [UIImage imageNamed:@"light_g"];
    }else{
        connectStateImageView.image = [UIImage imageNamed:@"light_r"];
    }
    [self.view bringSubviewToFront:connectStateImageView];
    
    searchWordImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view bringSubviewToFront:searchWordImageView];
    
    [beepButton addTarget:self action:@selector(beepButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [beepButton setImage:[UIImage imageNamed:@"beep1"] forState:UIControlStateNormal];
    [beepButton setImage:[UIImage imageNamed:@"beep2"] forState:UIControlStateHighlighted];
    [beepButton setImage:[UIImage imageNamed:@"beep2"] forState:UIControlStateDisabled];
    
    radar1ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view bringSubviewToFront:radar1ImageView];
    
    radar2ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view bringSubviewToFront:radar2ImageView];
    
    radar3ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view bringSubviewToFront:radar3ImageView];
    
    radar4ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view bringSubviewToFront:radar4ImageView];
    
    radar5ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view bringSubviewToFront:radar5ImageView];
 
    ioAnimationImageView.backgroundColor = [UIColor clearColor];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        ioAnimationImageView.image = [UIImage imageNamed:@"20151222.01.png"];
    else
        ioAnimationImageView.image = [UIImage imageNamed:@"20151222.01a.png"];
    [self.view addSubview:ioAnimationImageView];
    
    [self.view addSubview:tapView];
    
    [self.view addSubview:beepButton];
}

- (void)handleTapAlert{
    NSLog(@"handleTapAlert");
    [self.view addSubview:tapAlertAnimationImageView];
    
    [self ioAnimation2];
    
//    [tapAlertAnimationImageView removeFromSuperview];
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

#pragma mark search light, radar, io animation setting
- (void)startRadarAnimation{
    [self runSpinAnimationOnView:radar1ImageView clockwise:1 rotation:0.5];
    [self runSpinAnimationOnView:radar2ImageView clockwise:-1 rotation:0.3];
    [self runSpinAnimationOnView:radar3ImageView clockwise:1 rotation:0.25];
    [self runSpinAnimationOnView:radar4ImageView clockwise:-1 rotation:0.5];
    [self runSpinAnimationOnView:radar5ImageView clockwise:1 rotation:0.5];
}

- (void)stopRadarAnimation{
    NSLog(@"stopRadarAnimation");
    [self runSpinAnimationOnView:radar1ImageView clockwise:1 rotation:0];
    [self runSpinAnimationOnView:radar2ImageView clockwise:-1 rotation:0];
    [self runSpinAnimationOnView:radar3ImageView clockwise:1 rotation:0];
    [self runSpinAnimationOnView:radar4ImageView clockwise:-1 rotation:0];
    [self runSpinAnimationOnView:radar5ImageView clockwise:1 rotation:0];
}

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

- (void)ioAnimation{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(int i=1;i<31;i++){
        NSLog(@"%@", [NSString stringWithFormat:@"20151222.%02d.png", (i*2-1)]);
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"20151222.%02d.png", (i*2-1)]]];
        else
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"20151222.%02da.png", (i*2-1)]]];
        
    }
    ioAnimationImageView.animationImages = images;
    ioAnimationImageView.animationDuration = 1;
    ioAnimationImageView.animationRepeatCount = 0;
    
    [ioAnimationImageView startAnimating];
}

- (void)ioAnimation2{
    NSLog(@"ioAnimation2");
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(int i=1;i<25;i++){
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"m_%02d.png", i]]];
    }
    if([[searchUdf objectForKey:@"connect"] isEqualToString:@"y"]){
        for (int i=0; i<50; i++) {
            [images addObject:[UIImage imageNamed:@"m_25.png"]];
        }
    }else{
        for (int i=0; i<50; i++) {
            [images addObject:[UIImage imageNamed:@"m_26.png"]];
        }
    }
    for(int i=24;i>0;i--){
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"m_%02d.png", i]]];
    }
    tapAlertAnimationImageView.animationImages = images;
    tapAlertAnimationImageView.animationDuration = 4;
    tapAlertAnimationImageView.animationRepeatCount = 1;
    
    [tapAlertAnimationImageView startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(dismissAnimateView) userInfo:nil repeats:NO];
}

- (void)dismissAnimateView{
    [tapAlertAnimationImageView removeFromSuperview];
}

- (void)searchGLightAnimation{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(int i=1;i<11;i++){
        NSLog(@"%@", [NSString stringWithFormat:@"g_light_%02d.png", i]);
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"g_light_%02d.png", i]]];
    }
    searchLightImageView.animationImages = images;
    searchLightImageView.animationDuration = 0.5;
    searchLightImageView.animationRepeatCount = 0;
    
    [searchLightImageView startAnimating];
}

- (void)searchRLightAnimation{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(int i=1;i<11;i++){
        NSLog(@"%@", [NSString stringWithFormat:@"r_light_%02d.png", i]);
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"r_light_%02d.png", i]]];
    }
    searchLightImageView.animationImages = images;
    searchLightImageView.animationDuration = 0.5;
    searchLightImageView.animationRepeatCount = 0;
    
    [searchLightImageView startAnimating];
}

- (void)connectedWordAnimation{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    [images addObject:[UIImage imageNamed:@"search3"]];
    [images addObject:[UIImage imageNamed:@"search5"]];
    searchWordImageView.animationImages = images;
    searchWordImageView.animationDuration = 4;
    searchWordImageView.animationRepeatCount = 0;
    
    [searchWordImageView startAnimating];
}

#pragma mark beep setting
- (void)beepButtonPressed{
    NSLog(@"beepButtonPressed");
    beepButton.enabled = false;
    if(!searchWordImageView.isAnimating){
        [searchWordImageView stopAnimating];
        searchWordImageView.image = [UIImage imageNamed:@"search4"];
    }
    [self ioAnimation];
    [self beepWithCount];
}

- (void)beepWithCount{
    int count = (int)[searchUdf integerForKey:@"beepTime"];
    if (count == 0) {
        beepCount = 10;
        beepTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendBuzzer) userInfo:nil repeats:YES];
    }else if(count == 3){
        beepCount = 3;
        [NSTimer scheduledTimerWithTimeInterval:beepCount target:self selector:@selector(beepFinish) userInfo:nil repeats:NO];
    }else if(count == 5){
        beepCount = 5;
        [NSTimer scheduledTimerWithTimeInterval:beepCount target:self selector:@selector(beepFinish) userInfo:nil repeats:NO];
    }
    
    [self sendBuzzer];
}

- (void)beepFinish{
    beepButton.enabled = true;
    [self connectedWordAnimation];
    [ioAnimationImageView stopAnimating];
}

- (void)sendBuzzer{
    [sensor SendBuzzer:(BOOL *)true ontime:5 offtime:5 count:beepCount];
}

#pragma mark search handl connect state
- (void)udfHandle{
    //TODO
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    
    NSString *str = [searchUdf objectForKey:@"connect"];
    
    if([str isEqualToString:@"y"]){
        NSLog(@"S connect state : success");
        
        beepButton.enabled = true;
        connectStateImageView.image = [UIImage imageNamed:@"light_g"];
        [self connectedWordAnimation];
        
        if(![searchLightImageView isAnimating])
            [self searchGLightAnimation];
        else{
            [searchLightImageView stopAnimating];
            [self searchGLightAnimation];
        }
        
        if(![radar1ImageView isAnimating])
            [self startRadarAnimation];
        
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
        alertViewSearch = [alertVCSearch alertConnectSuccess];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
        [alertViewSearch addGestureRecognizer:tap];
        
        [self.view addSubview:alertViewSearch];
        
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    }else if([str isEqualToString:@"n"]){
        NSLog(@"S connect state : failed");
        
        beepButton.enabled = false;
        connectStateImageView.image = [UIImage imageNamed:@"light_r"];
        if(searchWordImageView.isAnimating){
            [searchWordImageView stopAnimating];
            searchWordImageView.image = [UIImage imageNamed:@"search2"];
        }
        
        if(![searchLightImageView isAnimating])
            [self searchRLightAnimation];
        else{
            [searchLightImageView stopAnimating];
            [self searchRLightAnimation];
        }
        
        [self stopRadarAnimation];
        
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
        alertViewSearch = [alertVCSearch alertConnectError];
        
        [self.view addSubview:alertViewSearch];
        
        UIButton *tryButton = [alertVCSearch getTryBurtton];
        [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [alertVCSearch getCancelButton];
        [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [alertViewSearch addSubview:tryButton];
        [alertViewSearch addSubview:cancelButton];
        
    }else if([str isEqualToString:@"t"]){
        NSLog(@"S connect state : timeout");
        
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
    }

}

- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try");
        [self searchRLightAnimation];
        if(!searchWordImageView.isAnimating){
            [searchWordImageView stopAnimating];
            searchWordImageView.image = [UIImage imageNamed:@"search1"];
        }
        
        [ScanS autoConnectTag];
        
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
    }else{
        NSLog(@"cancel");
        [button.superview removeFromSuperview];
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)connectTimeout{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"connect"];
    }
}

- (void)dismissAlert{
    NSLog(@"dismiss alert");
    if(alertViewSearch != nil){
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
    }
}

- (IBAction)searchBackButtonPressed:(id)sender {
    [beepTimer invalidate];
    beepTimer = nil;
    [sensor SendBuzzer:0 ontime:0 offtime:0 count:0];
    beepButton.enabled = true;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BTSmartSensorDelegate
//取得資料整理
-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    NSLog(@"S : data     %@",value);
}


//連線成功
-(void)setConnect
{
    NSLog(@"S : OK+CONN");
    [[NSUserDefaults standardUserDefaults] setObject:@"y" forKey:@"connect"];
    //[self showOkayCancelAlert:@"iTag connected\niTag連線成功"];
}

//斷線
-(void)setDisconnect
{
    NSLog(@"S : OK+LOST");
    connectStateImageView.image = [UIImage imageNamed:@"light_r"];
    [[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"connect"];
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
