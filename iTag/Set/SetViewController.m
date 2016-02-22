//
//  SetViewController.m
//  iTag
//
//  Created by Jason Tsai on 2015/12/22.
//  Copyright © 2015年 NFC. All rights reserved.
//

#import "SetViewController.h"

@interface SetViewController ()

@end

@implementation SetViewController
@synthesize setBsckButton, pairButton, alarmDurationButton, aboutUsButton;
@synthesize versionLabel;

NSUserDefaults *setUdf;

AlertViewController *alertVCSet;

- (void)viewDidLoad {
    [super viewDidLoad];

    setUdf = [NSUserDefaults standardUserDefaults];
    
    alertVCSet = [AlertViewController new];
    
    [self setSetUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"set");
    if(![[setUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
    BleController *shareBERController = [BleController sharedController];
    self.sensor = shareBERController.sensor;
    self.sensor.delegate = self;
    }
    NSLog(@"Name : %@",self.sensor.activePeripheral.name);
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"set exit"); //view 將要結束
    self.sensor.delegate = nil;
}


#pragma mark set UI setting
- (void)setSetUI{
    float wRatio = [alertVCSet getSizeWRatio];
    float hRatio = [alertVCSet getSizeHRatio];

    [self.view addSubview:[alertVCSet setBGImageView:[UIImage imageNamed:@"bg_setting"]]];
    
    [setBsckButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [pairButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [alarmDurationButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [versionLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
    [aboutUsButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        [setBsckButton setFrame:CGRectMake(32*wRatio, 15*hRatio, setBsckButton.imageView.image.size.width*wRatio, setBsckButton.imageView.image.size.height*hRatio)];
        [pairButton setFrame:CGRectMake(67*wRatio, 138*hRatio, pairButton.imageView.image.size.width*wRatio, pairButton.imageView.image.size.height*hRatio)];
        [alarmDurationButton setFrame:CGRectMake(224*wRatio, 217*hRatio, alarmDurationButton.imageView.image.size.width*wRatio, alarmDurationButton.imageView.image.size.height*hRatio)];
        [versionLabel setFrame:CGRectMake(196*wRatio, 302*hRatio, 100*wRatio, 30*hRatio)];
        [aboutUsButton setFrame:CGRectMake(67*wRatio, 376*hRatio, aboutUsButton.imageView.image.size.width*wRatio, aboutUsButton.imageView.image.size.height*hRatio)];
    }else{
        [setBsckButton setFrame:CGRectMake(63*wRatio, 28*hRatio, setBsckButton.imageView.image.size.width*wRatio, setBsckButton.imageView.image.size.height*hRatio)];
        [pairButton setFrame:CGRectMake(126*wRatio, 256*hRatio, pairButton.imageView.image.size.width*wRatio, pairButton.imageView.image.size.height*hRatio)];
        [alarmDurationButton setFrame:CGRectMake(418*wRatio, 403*hRatio, alarmDurationButton.imageView.image.size.width*wRatio, alarmDurationButton.imageView.image.size.height*hRatio)];
        [versionLabel setFrame:CGRectMake(373*wRatio, 565*hRatio, 100*wRatio, 40*hRatio)];
        versionLabel.font = [UIFont fontWithName:@"Heiti TC" size:40];
        [aboutUsButton setFrame:CGRectMake(126*wRatio, 698*hRatio, aboutUsButton.imageView.image.size.width*wRatio, aboutUsButton.imageView.image.size.height*hRatio)];
    }

    [setBsckButton setImage:[UIImage imageNamed:@"back02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:setBsckButton];

    if(![[setUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
        [pairButton setImage:[UIImage imageNamed:@"unpair01"] forState:UIControlStateNormal];
        [pairButton setImage:[UIImage imageNamed:@"unpair02"] forState:UIControlStateHighlighted];
    }else{
        [pairButton setImage:[UIImage imageNamed:@"pair01"] forState:UIControlStateNormal];
        [pairButton setImage:[UIImage imageNamed:@"pair02"] forState:UIControlStateHighlighted];
    }
    [self.view bringSubviewToFront:pairButton];

    NSInteger beepTime = [setUdf integerForKey:@"beepTime"];
    if(beepTime == 3){
        [alarmDurationButton setImage:[UIImage imageNamed:@"3sec01"] forState:UIControlStateNormal];
        [alarmDurationButton setImage:[UIImage imageNamed:@"3sec02"] forState:UIControlStateHighlighted];
    }else if(beepTime == 5){
        [alarmDurationButton setImage:[UIImage imageNamed:@"5sec01"] forState:UIControlStateNormal];
        [alarmDurationButton setImage:[UIImage imageNamed:@"5sec02"] forState:UIControlStateHighlighted];
    }else if(beepTime == 0){
        [alarmDurationButton setImage:[UIImage imageNamed:@"continuous01"] forState:UIControlStateNormal];
        [alarmDurationButton setImage:[UIImage imageNamed:@"continuous02"] forState:UIControlStateHighlighted];
    }
    [self.view bringSubviewToFront:alarmDurationButton];

    versionLabel.text = [setUdf objectForKey:@"version"];
    [self.view bringSubviewToFront:versionLabel];

    [aboutUsButton setImage:[UIImage imageNamed:@"aboutus02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:aboutUsButton];
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

#pragma mark set connect handle
- (void)udfHandle{
    if([[setUdf objectForKey:@"connect"] isEqualToString:@"y"]){
        [pairButton setImage:[UIImage imageNamed:@"unpair01"] forState:UIControlStateNormal];
        [pairButton setImage:[UIImage imageNamed:@"unpair02"] forState:UIControlStateHighlighted];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:setUdf name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark set button actions
- (IBAction)setBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pairButtonPressed:(id)sender {
    if(![[setUdf objectForKey:@"tagID"] isEqualToString:@"defaultID"]){
        BleController *controller = [BleController sharedController];
        
        if (self.sensor.activePeripheral && self.sensor.activePeripheral != controller.peripheral) {
            [self.sensor disconnect:self.sensor.activePeripheral];
        }
        self.sensor.delegate = nil;
        
        [setUdf setObject:@"defaultID" forKey:@"tagID"];
        [setUdf setObject:@"n" forKey:@"connect"];
        [pairButton setImage:[UIImage imageNamed:@"pair01"] forState:UIControlStateNormal];
        [pairButton setImage:[UIImage imageNamed:@"pair02"] forState:UIControlStateHighlighted];
    }else{
        //TODO
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udfHandle) name:NSUserDefaultsDidChangeNotification object:nil];
        
        UIViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"scan"];
        [self presentViewController:scan animated:YES completion:nil];
    }
}

- (IBAction)alarmDurationButtonPressed:(id)sender {
    NSInteger beepTime = [setUdf integerForKey:@"beepTime"];
    
    if(beepTime == 3){
        beepTime = 5;
        [alarmDurationButton setImage:[UIImage imageNamed:@"5sec01"] forState:UIControlStateNormal];
        [alarmDurationButton setImage:[UIImage imageNamed:@"5sec02"] forState:UIControlStateHighlighted];
    }else if(beepTime == 5){
        beepTime = 0;
        [alarmDurationButton setImage:[UIImage imageNamed:@"continuous01"] forState:UIControlStateNormal];
        [alarmDurationButton setImage:[UIImage imageNamed:@"continuous02"] forState:UIControlStateHighlighted];
    }else if(beepTime == 0){
        beepTime = 3;
        [alarmDurationButton setImage:[UIImage imageNamed:@"3sec01"] forState:UIControlStateNormal];
        [alarmDurationButton setImage:[UIImage imageNamed:@"3sec02"] forState:UIControlStateHighlighted];
    }
    
    [setUdf setInteger:beepTime forKey:@"beepTime"];
}

- (IBAction)aboutUsButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.ihoin.com/about.html"];
    //[[UIApplication sharedApplication] openURL:url];
    SFSafariViewController *sfViewController = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:sfViewController animated:YES completion:nil];
}

-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    NSLog(@"set     %@",value);
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
