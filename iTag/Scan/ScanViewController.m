//
//  ViewController.m
//  SmcUart
//
//  Created by Nick on 2015/3/25.
//  Copyright (c) 2015 Nick. All rights reserved.
//

#import "ScanViewController.h"
//#import "ViewController.h"

#define SCAN_BLE_TIME   5
@interface ScanViewController ()

@end

@implementation ScanViewController
@synthesize bleDeviceTableView;
@synthesize scanBleDeviceButton;
@synthesize sensor;
@synthesize peripheralViewControllerArray;

bool isAuto = false;
/*
 isAuto = true;  在其他viewController背景連線時：首頁、find io時
 isAuto = false;  present scan viewController時：第一次配對、setting unpair/pair時
 */

bool scan_check;

NSUserDefaults *scanUdf;
AlertViewController *alertVCScan;

UIView *alertViewScan;

NSTimer *timeoutTimer;
NSTimer *pairCheckTimer;

int indexOfIO;

bool pairFailed = false;

- (void)viewDidLoad {
    NSLog(@"scan viewdidload");
    [super viewDidLoad];
    
    scan_check = false;//接收io傳來資料的flag，因io傳來資料為連續多個，限制只接收一個資料
    
    self.title = @"Smc Uart";
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    sensor = [[SmcGATT alloc] init];
    [sensor setup];
    sensor.delegate = self;
    
    peripheralViewControllerArray = [[NSMutableArray alloc] init];
    
    scanUdf = [NSUserDefaults standardUserDefaults];
    
    //UI 設定
    alertVCScan = [AlertViewController new];
    [self.view addSubview:[alertVCScan setBGImageView:[UIImage imageNamed:@"bg_first"]]];
    
    [self.view bringSubviewToFront:bleDeviceTableView];
    
    [scanBleDeviceButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [scanBleDeviceButton setFrame:CGRectMake(113*[alertVCScan getSizeWRatio], 651*[alertVCScan getSizeHRatio], scanBleDeviceButton.imageView.image.size.width*[alertVCScan getSizeWRatio], scanBleDeviceButton.imageView.image.size.height*[alertVCScan getSizeHRatio])];
    else{
        [bleDeviceTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [bleDeviceTableView setFrame:CGRectMake(32*[alertVCScan getSizeWRatio], 200*[alertVCScan getSizeHRatio], [alertVCScan getSizeW] - 64*[alertVCScan getSizeWRatio], [alertVCScan getSizeH]-200*[alertVCScan getSizeHRatio]-128*[alertVCScan getSizeHRatio])];
        [scanBleDeviceButton setFrame:CGRectMake(246*[alertVCScan getSizeWRatio], 896*[alertVCScan getSizeHRatio], scanBleDeviceButton.imageView.image.size.width*[alertVCScan getSizeWRatio], scanBleDeviceButton.imageView.image.size.height*[alertVCScan getSizeHRatio])];
    }
    [scanBleDeviceButton setImage:[UIImage imageNamed:@"scan01"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:scanBleDeviceButton];
}

//呼叫出scan頁面時先自動搜尋一次附近裝置
- (void)viewDidAppear:(BOOL)animated{
    isAuto = false;
    [self scanBLEDevice];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float height;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        height = 44;
    else
        height = 88;
    
    return height;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.peripheralViewControllerArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    indexOfIO = (int)[indexPath row];
    BleController *controller = [peripheralViewControllerArray objectAtIndex:row];
    
    if (sensor.activePeripheral && sensor.activePeripheral != controller.peripheral) {
        [sensor disconnect:sensor.activePeripheral];
    }
    
    sensor.activePeripheral = controller.peripheral;

    [sensor connect:sensor.activePeripheral];
    [sensor stopScan];
    
    BleController *ble = [[BleController alloc] init];
    ble.sensor = sensor;
    
    //[scanBleDeviceButton setTitle:@"Scan" forState:UIControlStateNormal];
    //[self performSegueWithIdentifier:@"goDeviceView" sender:sensor.activePeripheral];
    
    [self showConnectStateAlertScan:0 info:nil];
    
    [self setSensor];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor colorWithRed:47.0/255.0 green:214.0/255.0 blue:255.0/255.0 alpha:1.0];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"peripheral";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    BleController *controller = [peripheralViewControllerArray objectAtIndex:row];
    CBPeripheral *peripheral = [controller peripheral];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %d",peripheral.name,[controller.rssi intValue]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Heiti TC" size:17];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        cell.textLabel.font = [UIFont fontWithName:@"Heiti TC" size:40];
    return cell;
}

//連線成功
-(void)setConnect
{
    NSLog(@"SCAN : OK+CONN");
    //[scanUdf setObject:@"y" forKey:@"connect"];
    
    if(!isAuto){
        //有present scan view controller
        NSLog(@"not auto");
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(receivedPairSingnal) name:@"pairCheck" object:nil];
        
        pairCheckTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pairFailed) userInfo:nil repeats:NO];
        
        [self showConnectStateAlertScan:3 info:@"Press io"];
        
    }else{
        //在背後連線
        [scanUdf setObject:@"y" forKey:@"connect"];
    }
    
//    [self showOkayCancelAlert:@"iTag connected\niTag連線成功"];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

//斷線
-(void)setDisconnect
{
    NSLog(@"SCAN : OK+LOST");
    [scanUdf setObject:@"n" forKey:@"connect"];
    
    if(!isAuto){
        NSLog(@"not auto");
        if(!pairFailed){
            [self showConnectStateAlertScan:2 info:nil];
        }
    }
    
    //[self showOkayCancelAlert:@"iTag disconnected\niTag連線失敗"];
    //[self dismissViewControllerAnimated:NO completion:nil];
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

//取得資料整理
-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    NSLog(@"data     %@",value);
    
    //接收假配對確認資料
    if(value.length == 18){
        NSScanner *scanner;
        unsigned result = 0;
        scanner = [[NSScanner alloc] initWithString:[value substringWithRange:NSMakeRange(2,2)]];
        [scanner scanHexInt:&result];
        if([[value substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"] && result<=4 && scan_check == false){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pairCheck" object:nil];
            scan_check = true;
        }else{
            if(scan_check == true){
                scan_check = false;
            }else{
                scan_check = false;
            }
        }
    }
    
}

//假配對成功
- (void)receivedPairSingnal{
    NSLog(@"receivedPairSingnal");
    pairFailed = false;
    
    [scanUdf setObject:@"y" forKey:@"connect"];
    
    [pairCheckTimer invalidate];
    pairCheckTimer = nil;
    
    [self showConnectStateAlertScan:1 info:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pairCheck" object:nil];
}

//假配對失敗
- (void)pairFailed{
    NSLog(@"pairFailed");
    
    pairFailed = true;
    
    [scanUdf setObject:@"n" forKey:@"connect"];
    
    [scanUdf setObject:@"defaultID" forKey:@"tagID"];
    NSLog(@"remember ID : %@", [scanUdf objectForKey:@"tagID"]);
    
    BleController *controller = [peripheralViewControllerArray objectAtIndex:indexOfIO];;
    
    if (sensor.activePeripheral && sensor.activePeripheral != controller.peripheral) {
        [sensor disconnect:sensor.activePeripheral];
    }
    
    sensor.delegate = nil;
    
    [self showConnectStateAlertScan:2 info:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pairCheck" object:nil];
}

- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try connect");
        [alertViewScan removeFromSuperview];
        alertViewScan = nil;
        [self scanBLEDevice];
    }else{
        NSLog(@"cancel connect");
        [button.superview removeFromSuperview];
    }
}

- (void)dismissAlert{
    if(alertViewScan != nil){
        [alertViewScan removeFromSuperview];
        alertViewScan = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark connect and auto connect
- (IBAction)scanBleDevicePressed:(id)sender{
    NSLog(@"scanBleDevicePressed");
    isAuto = false;
    [self scanBLEDevice];
}

- (void)autoConnectTag{
    NSLog(@"autoConnectTag");
    isAuto = true;
    
    sensor = [[SmcGATT alloc] init];
    [sensor setup];
    sensor.delegate = self;
    
    peripheralViewControllerArray = [[NSMutableArray alloc] init];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scanBLEDevice) userInfo:nil repeats:NO];
    
    scanUdf = [NSUserDefaults standardUserDefaults];
}

- (void)scanBLEDevice{
    NSLog(@"scanBleDevice");
    if ([sensor activePeripheral]) {
        if (sensor.activePeripheral.state == CBPeripheralStateConnected) {
            [sensor.manager cancelPeripheralConnection:sensor.activePeripheral];
            sensor.activePeripheral = nil;
        }
    }
    
    if ([sensor peripherals]) {
        sensor.peripherals = nil;
        [peripheralViewControllerArray removeAllObjects];
        [bleDeviceTableView reloadData];
    }
    
    sensor.delegate = self;
    printf("now we are searching device...\n");
    //[scanBleDeviceButton setTitle:@"Scanning..." forState:UIControlStateNormal];
    //timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:SCAN_BLE_TIME target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    timeoutTimer = [NSTimer timerWithTimeInterval:SCAN_BLE_TIME target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timeoutTimer forMode:NSDefaultRunLoopMode];
    
    [sensor findHMSoftPeripherals:5];
}

-(void) scanTimer:(NSTimer *)timer
{
    //[scanBleDeviceButton setTitle:@"Scan" forState:UIControlStateNormal];
    if(![[scanUdf objectForKey:@"connect"] isEqualToString:@"y"]){
        [scanUdf setObject:@"t" forKey:@"connect"];
        NSLog(@"scan time out");
    }
}

- (void)setSensor{
    NSLog(@"setSensor");
    
    if([[scanUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
        [scanUdf setObject:[self UUIDtoString:sensor.activePeripheral.identifier] forKey:@"tagID"];
        
        NSLog(@"remember ID : %@", [scanUdf objectForKey:@"tagID"]);
    }
    
    BleController *shareBERController = [BleController sharedController];
    [shareBERController setupControllerForSmcGATT:sensor];
}

- (void)connectSensor:(BleController *)inController{
    NSLog(@"connectSensor\n%@\n%@", [self UUIDtoString:inController.peripheral.identifier], [scanUdf objectForKey:@"tagID"]);
    if([[self UUIDtoString:inController.peripheral.identifier] isEqualToString:[scanUdf objectForKey:@"tagID"]]){
        BleController *controller = inController;
        
        if (sensor.activePeripheral && sensor.activePeripheral != controller.peripheral) {
            [sensor disconnect:sensor.activePeripheral];
        }
        
        sensor.activePeripheral = controller.peripheral;
        
        [sensor connect:sensor.activePeripheral];
        [sensor stopScan];
        
        BleController *ble = [[BleController alloc] init];
        ble.sensor = sensor;
        
        [self setSensor];
    }
}

- (void)stopScan{
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    [sensor stopScan];
}

- (NSString *)UUIDtoString:(NSUUID *)UUID{
    CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef)UUID);
    NSString *myid = (__bridge NSString *)(s);
    return myid;
}


#pragma mark handle segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"goDeviceView"]) {
//        NSLog(@"the destination is View 2 !\n");
//        //ViewController* deviceView = segue.destinationViewController;
//        //the destination is View 2
//        //deviceView.sensor = sensor;
//        
//        
//        BleController *shareBERController = [BleController sharedController];
//        [shareBERController setupControllerForSmcGATT:sensor];
//    }
//}

#pragma mark - HMSoftSensorDelegate
-(void)sensorReady
{
    //TODO: it seems useless right now.
}

-(void) peripheralFound:(CBPeripheral *)peripheral rssi:(NSNumber *)rssi
{
    NSLog(@"peripheralFound");
    BleController *controller = [[BleController alloc] init];
    controller.peripheral = peripheral;
    controller.sensor = sensor;
    controller.rssi = rssi;
    [peripheralViewControllerArray addObject:controller];
    [bleDeviceTableView reloadData];
    if(isAuto){
        [self connectSensor:controller];
    }
}

-(IBAction)backToFirst:(UIStoryboardSegue *) segue {
    NSLog(@"back to FirstPage");
}

#pragma mark - alert
- (void)showConnectStateAlertScan:(int)state info:(NSString *)info{
    [alertViewScan removeFromSuperview];
    alertViewScan = nil;
    switch (state) {
        case 0:
            //connecting
            alertViewScan = [alertVCScan alertConnecting];
            break;
        case 1:{
            //connect success
            alertViewScan = [alertVCScan alertConnectSuccess];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
            [alertViewScan addGestureRecognizer:tap];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
        }
            break;
        case 2:{
            //connect failed
            alertViewScan = [alertVCScan alertConnectError];
            
            UIButton *tryButton = [alertVCScan getTryBurtton];
            [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *cancelButton = [alertVCScan getCancelButton];
            [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [alertViewScan addSubview:tryButton];
            [alertViewScan addSubview:cancelButton];
        }
            break;
        case 3:
            //custom alert
            alertViewScan = [alertVCScan alertCustom:info];
            break;
        default:
            break;
    }
    [self.view addSubview:alertViewScan];
}
@end
