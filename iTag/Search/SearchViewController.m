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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    searchUdf = [NSUserDefaults standardUserDefaults];
    alertVCSearch = [AlertViewController new];
    ScanS = [ScanViewController new];
    
    [self setSearchUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [self runSpinAnimationOnView:radar1ImageView clockwise:1 rotation:0.5];
    [self runSpinAnimationOnView:radar2ImageView clockwise:-1 rotation:0.3];
    [self runSpinAnimationOnView:radar3ImageView clockwise:1 rotation:0.25];
    [self runSpinAnimationOnView:radar4ImageView clockwise:-1 rotation:0.5];
    [self runSpinAnimationOnView:radar5ImageView clockwise:1 rotation:0.5];
}

- (void)setSearchUI{
    float wRatio = [alertVCSearch getSizeWRatio];
    float hRatio = [alertVCSearch getSizeHRatio];
    
    [self.view addSubview:[alertVCSearch setBGImageView:[UIImage imageNamed:@"bg_find"]]];
    
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
        float radarRatio = (wRatio+hRatio)/2;
        
        [searchBackButton setFrame:CGRectMake(32*wRatio, 15*hRatio, searchBackButton.imageView.image.size.width*wRatio, searchBackButton.imageView.image.size.height*hRatio)];
        [connectStateImageView setFrame:CGRectMake(139*wRatio, 107*hRatio, connectStateImageView.image.size.width*wRatio, connectStateImageView.image.size.height*hRatio)];
        connectStateImageView.center = CGPointMake(158*wRatio, 126*hRatio);
        [searchWordImageView setFrame:CGRectMake(66*wRatio, 176*hRatio, searchWordImageView.image.size.width*wRatio, searchWordImageView.image.size.height*hRatio)];
        
        bg2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(26*radarRatio, 271*radarRatio, 363*radarRatio, 356*radarRatio)];
        bg2ImageView.center = CGPointMake(207*wRatio, 449*hRatio);
        bg2ImageView.image = [UIImage imageNamed:@"bg_find2"];
        bg2ImageView.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:bg2ImageView];
        
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
        
        ioAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(147*wRatio, 392*hRatio, 120*wRatio, 120*hRatio)];
        
    }else{
        [searchBackButton setFrame:CGRectMake(63*wRatio, 28*hRatio, searchBackButton.imageView.image.size.width*wRatio, searchBackButton.imageView.image.size.height*hRatio)];
        [connectStateImageView setFrame:CGRectMake(266*wRatio, 192*hRatio, connectStateImageView.image.size.width*wRatio, connectStateImageView.image.size.height*hRatio)];
        [searchWordImageView setFrame:CGRectMake(119*wRatio, 304*hRatio, searchWordImageView.image.size.width*wRatio, searchWordImageView.image.size.height*hRatio)];
        
        [radar1ImageView setFrame:CGRectMake(160*wRatio, 470*hRatio, radar1ImageView.image.size.width*wRatio, radar1ImageView.image.size.height*hRatio)];
        [radar2ImageView setFrame:CGRectMake(227*wRatio, 537*hRatio, radar2ImageView.image.size.width*wRatio, radar2ImageView.image.size.height*hRatio)];
        [radar3ImageView setFrame:CGRectMake(251*wRatio, 562*hRatio, radar3ImageView.image.size.width*wRatio, radar3ImageView.image.size.height*hRatio)];
        [radar4ImageView setFrame:CGRectMake(544*wRatio, 851*hRatio, radar4ImageView.image.size.width*wRatio, radar4ImageView.image.size.height*hRatio)];
        [radar5ImageView setFrame:CGRectMake(109*wRatio, 828*hRatio, radar5ImageView.image.size.width*wRatio, radar5ImageView.image.size.height*hRatio)];
        
        ioAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(284*wRatio, 590*hRatio, 200*wRatio, 200*hRatio)];
    }
    
    
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
    [self ioAnimation];
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

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"search");
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    NSLog(@"Name : %@",sensor.activePeripheral.name);
    [self searchTag];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"search exit"); //view 將要結束
    self.sensor.delegate = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)searchBackButtonPressed:(id)sender {
    [beepTimer invalidate];
    beepTimer = nil;
    [sensor SendBuzzer:0 ontime:0 offtime:0 count:0];
    [ScanS stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)beepWithCount{
    int count = (int)[searchUdf integerForKey:@"beepTime"];
    if (count == 0) {
        beepCount = 10;
        beepTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendBuzzer) userInfo:nil repeats:YES];
    }else if(count == 3){
        beepCount = 3;
    }else if(count == 5){
        beepCount = 5;
    }
    [self sendBuzzer];
}

- (void)sendBuzzer{
    [sensor SendBuzzer:(BOOL *)true ontime:5 offtime:5 count:beepCount];
}

- (void)searchTag{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"]){
        [self beepWithCount];
    }else{
        [ScanS autoConnectTag];
        //[self autoConnectTag];
    }
}

- (NSString *)UUIDtoString:(NSUUID *)UUID{
    CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef)UUID);
    NSString *myid = (__bridge NSString *)(s);
    return myid;
}

- (void)setSensor{
    NSLog(@"search setSensor");
    
    
    BleController *shareBERController = [BleController sharedController];
    [shareBERController setupControllerForSmcGATT:sensor];
    
    //[sensor SendBuzzer:true ontime:1 offtime:1 count:3];
}

//- (void)connectSensor:(BleController *)inController{
//    NSLog(@"connectSensor\n%@\n%@", [self UUIDtoString:inController.peripheral.identifier], [[NSUserDefaults standardUserDefaults] objectForKey:@"tagID"]);
//    if([[self UUIDtoString:inController.peripheral.identifier] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"tagID"]]){
//        BleController *controller = inController;
//        
//        if (sensor.activePeripheral && sensor.activePeripheral != controller.peripheral) {
//            [sensor disconnect:sensor.activePeripheral];
//        }
//        
//        sensor.activePeripheral = controller.peripheral;
//        
//        [sensor connect:sensor.activePeripheral];
//        [sensor stopScan];
//        
//        BleController *ble = [[BleController alloc] init];
//        ble.sensor = sensor;
//        
//        [self setSensor];
//    }
//}
//
//- (void)autoConnectTag{
//    NSLog(@"autoConnectTag");
//    
//    sensor = [[SmcGATT alloc] init];
//    [sensor setup];
//    sensor.delegate = self;
//    
//    peripheralArrayS = [[NSMutableArray alloc] init];
//    
//    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scanBLEDevice) userInfo:nil repeats:NO];
//}
//- (void)scanBLEDevice{
//    NSLog(@"scanBleDevice Search");
//    if ([sensor activePeripheral]) {
//        if (sensor.activePeripheral.state == CBPeripheralStateConnected) {
//            [sensor.manager cancelPeripheralConnection:sensor.activePeripheral];
//            sensor.activePeripheral = nil;
//        }
//    }
//    
//    if ([sensor peripherals]) {
//        sensor.peripherals = nil;
//        [peripheralArrayS removeAllObjects];
//    }
//    
//    sensor.delegate = self;
//    printf("S : now we are searching device...\n");
//    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
//    
//    [sensor findHMSoftPeripherals:5];
//}

//-(void) scanTimer:(NSTimer *)timer
//{
//    NSLog(@"S : Auto connect : %ld", self.peripheralArrayS.count);
//    
//    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
//}

//-(void) peripheralFound:(CBPeripheral *)peripheral rssi:(NSNumber *)rssi
//{
//    NSLog(@"S : peripheralFound");
//    BleController *controller = [[BleController alloc] init];
//    controller.peripheral = peripheral;
//    controller.sensor = sensor;
//    controller.rssi = rssi;
//    [peripheralArrayS addObject:controller];
//    
//    [self connectSensor:controller];
//}

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
    [self beepWithCount];
    connectStateImageView.image = [UIImage imageNamed:@"light_g"];

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
}

- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try");
        searchWordImageView.image = [UIImage imageNamed:@"search1"];
        
        [ScanS autoConnectTag];
        //[self autoConnectTag];
        
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
    }else{
        NSLog(@"cancel");
        [button.superview removeFromSuperview];
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)connectTimeout{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"connect"];
    
        if(![[searchUdf objectForKey:@"connect"] isEqualToString:@"y"]){
            searchWordImageView.image = [UIImage imageNamed:@"search2"];
            
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
        }
    }
}

- (void)dismissAlert{
    NSLog(@"dismiss alert");
    if(alertViewSearch != nil){
        [alertViewSearch removeFromSuperview];
        alertViewSearch = nil;
    }
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

@end
