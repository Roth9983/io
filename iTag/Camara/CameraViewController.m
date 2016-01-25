//
//  CameraViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/2.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//

// input action :
// - (IBAction)snapStillImage:(id)sender;

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CameraPreview.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CameraViewController () <AVCaptureFileOutputRecordingDelegate>
// For use in the storyboards.
@property (nonatomic, weak) IBOutlet CameraPreview *previewView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *stillButton;
@property (strong, nonatomic) IBOutlet UIButton *recCounter;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIButton *openAlbumButton;

- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)back:(id)sender;
- (IBAction)torchTurnOnOff:(id)sender;
- (IBAction)openAlbum:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@end

@implementation CameraViewController

@synthesize cameraButton;
@synthesize stillButton;
@synthesize recordButton;
@synthesize recCounter;
@synthesize backButton;
@synthesize torchButton;
@synthesize openAlbumButton;
NSTimer *myTimer;
int secCounter;
int minCounter;
int hrCounter;
bool rec = false;
AlertViewController *alertVCCam;
UIView *alertViewCam;
UIView *topView, *buttomView, *leftView;
bool on;
bool first;


@synthesize sensor;


- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    alertVCCam = [AlertViewController new];
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    [self setSession:session];
    
    // Setup the preview view
    on = false;
    first = true;
    [self setCameraControlView];
    [[self previewView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            //NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            //NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]){
                if([[UIDevice currentDevice] systemVersion].floatValue < 8)
                    [connection setEnablesVideoStabilizationWhenAvailable:YES];
                else
                    [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeStandard];
            }
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
    
    recCounter.hidden = true;
    
    //廣播取得資料
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(snapStillImage:) name:@"TakePhoto" object:nil];

    camera_check = false;
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"]){
 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(udfHandle)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
        [alertViewCam removeFromSuperview];
        alertViewCam = nil;
        alertViewCam = [alertVCCam alertConnectError];
        
        
        [self.view addSubview:alertViewCam];
        
        UIButton *tryButton = [alertVCCam getTryBurtton];
        [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [alertVCCam getCancelButton];
        [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [alertViewCam addSubview:tryButton];
        [alertViewCam addSubview:cancelButton];
    }
}

- (void) udfHandle{
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"connect"];
    
    if([str isEqualToString:@"y"]){
        NSLog(@"connect state : success");
        
        [alertViewCam removeFromSuperview];
        alertViewCam = nil;
        alertViewCam = [alertVCCam alertConnectSuccess];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
        [alertViewCam addGestureRecognizer:tap];
        
        [self.view addSubview:alertViewCam];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
        
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    }else if([str isEqualToString:@"n"]){
        NSLog(@"connect state : failed");
        
        [alertViewCam removeFromSuperview];
        alertViewCam = nil;
        alertViewCam = [alertVCCam alertConnectError];
        
        [self.view addSubview:alertViewCam];
        
        UIButton *tryButton = [alertVCCam getTryBurtton];
        [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [alertVCCam getCancelButton];
        [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [alertViewCam addSubview:tryButton];
        [alertViewCam addSubview:cancelButton];
        
    }else if([str isEqualToString:@"t"]){
        NSLog(@"connect state : timeout");
        
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
    }
}

- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try");
        ScanViewController *scanV = [[ScanViewController alloc] init];
        [scanV autoConnectTag];
        
        [alertViewCam removeFromSuperview];
        alertViewCam = nil;
        alertViewCam = [alertVCCam alertConnecting];
        [self.view addSubview:alertViewCam];
    }else{
        NSLog(@"cancel");
        [button.superview removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)connectTimeout{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"])
        [[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"connect"];
}

- (void)dismissAlert{
    NSLog(@"dismiss alert");
    if(alertViewCam != nil){
        [alertViewCam removeFromSuperview];
        alertViewCam = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Camera");
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak CameraViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CameraViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
            });
        }]];
        [[self session] startRunning];
    });
    
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    NSLog(@"Name : %@",sensor.activePeripheral.name);
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear"); //view 將要結束
    self.sensor.delegate = nil;
}


- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setCameraControlView{
    float w = [UIScreen mainScreen].bounds.size.width;
    float h = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"%f, %f", w, h);
    
    [self.previewView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [stillButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [backButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [cameraButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [torchButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [openAlbumButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if([[UIDevice currentDevice].systemVersion floatValue] <= 9){
        openAlbumButton.hidden = true;
    }
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        NSLog(@"iphone");
        if((w == 320 && h == 480) || (w == 480 && h == 320)){
            NSLog(@"iphone 4");
            if(topView != nil){
                [topView removeFromSuperview];
                topView = nil;
            }
            if(buttomView != nil){
                [buttomView removeFromSuperview];
                buttomView = nil;
            }
            if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait){
                [self.previewView setFrame:CGRectMake(0, 0, w, h)];
                topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
                buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, h-103, 480, 103)];
                [stillButton setFrame:CGRectMake(w/2-31.5, h-83, 69, 63)];
                [backButton setFrame:CGRectMake(20, 0, 44, 44)];
                [cameraButton setFrame:CGRectMake(w-20-44, 0, 44, 44)];
                [torchButton setFrame:CGRectMake(w-20-44-20-44, 0, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(20, h-30-50, 50, 50)];
                if(alertViewCam != nil){
                    alertViewCam.center = CGPointMake(w/2, h/2);
                }
            }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
                [self.previewView setFrame:CGRectMake(0, 0, h, w)];
                topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 480)];
                buttomView = [[UIView alloc] initWithFrame:CGRectMake(h-103, 0, 103, 480)];
                [stillButton setFrame:CGRectMake(h-86, w/2-31.5, 69, 63)];
                [backButton setFrame:CGRectMake(0, w-20-44, 44, 44)];
                [cameraButton setFrame:CGRectMake(0, 20, 44, 44)];
                [torchButton setFrame:CGRectMake(0, 20+44+20, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(w-30-50, h-20-50, 50, 50)];
                if(alertViewCam != nil){
                    alertViewCam.center = CGPointMake(h/2, w/2);
                }
            }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
                [self.previewView setFrame:CGRectMake(0, 0, h, w)];
                topView = [[UIView alloc] initWithFrame:CGRectMake(h-44, 0, 44, 480)];
                buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 103, 480)];
                [stillButton setFrame:CGRectMake(17, w/2-31.5, 69, 63)];
                [backButton setFrame:CGRectMake(h-44, 20, 44, 44)];
                [cameraButton setFrame:CGRectMake(h-44, w-20-44, 44, 44)];
                [torchButton setFrame:CGRectMake(h-44, w-20-44-20-44, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(30, 20, 50, 50)];
                if(alertViewCam != nil){
                    alertViewCam.center = CGPointMake(h/2, w/2);
                }
            }else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
                
            }else{
                if(w > h){
                    w = [UIScreen mainScreen].bounds.size.height;
                    h = [UIScreen mainScreen].bounds.size.width;
                }
                [self.previewView setFrame:CGRectMake(0, 0, w, h)];
                topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
                buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, h-103, 480, 103)];
                [stillButton setFrame:CGRectMake(w/2-31.5, h-83, 69, 63)];
                [backButton setFrame:CGRectMake(20, 0, 44, 44)];
                [cameraButton setFrame:CGRectMake(w-20-44, 0, 44, 44)];
                [torchButton setFrame:CGRectMake(w-20-44-20-44, 0, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(20, h-30-50, 50, 50)];
                if(alertViewCam != nil){
                    alertViewCam.center = CGPointMake(w/2, h/2);
                }
            }
            topView.backgroundColor = [UIColor blackColor];
            topView.alpha = 0.3;
            buttomView.backgroundColor = [UIColor blackColor];
            buttomView.alpha = 0.3;
            [self.view addSubview:topView];
            [self.view addSubview:buttomView];

            [self.view bringSubviewToFront:cameraButton];
            [self.view bringSubviewToFront:backButton];
            [self.view bringSubviewToFront:stillButton];
            [self.view bringSubviewToFront:torchButton];
        }else{
            NSLog(@"iphone 4 up");
            
            if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait){
                [self.previewView setFrame:CGRectMake(0, 44, w, (w*4/3))];
                [stillButton setFrame:CGRectMake(w/2-31.5, h-20-69, 69, 63)];
                [backButton setFrame:CGRectMake(20, 0, 44, 44)];
                [cameraButton setFrame:CGRectMake(w-20-44, 0, 44, 44)];
                [torchButton setFrame:CGRectMake(w-20-44-20-44, 0, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(20, h-30-50, 50, 50)];
            }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
                [self.previewView setFrame:CGRectMake(44, 0, (h*4/3), h)];
                [stillButton setFrame:CGRectMake(w-20+3-69, h/2-31.5, 69, 63)];
                [backButton setFrame:CGRectMake(0, h-20-44, 44, 44)];
                [cameraButton setFrame:CGRectMake(0, 20, 44, 44)];
                [torchButton setFrame:CGRectMake(0, 20+44+20, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(w-30-50, h-20-50, 50, 50)];
            }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
                [self.previewView setFrame:CGRectMake((w-44-(h*4/3)), 0, (h*4/3), h)];
                [stillButton setFrame:CGRectMake(20-3, h/2-31.5, 69, 63)];
                [backButton setFrame:CGRectMake(w-44, 20, 44, 44)];
                [cameraButton setFrame:CGRectMake(w-44, h-20-44, 44, 44)];
                [torchButton setFrame:CGRectMake(w-44, h-20-44-20-44, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(30, 20, 50, 50)];
            }else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){

            }else{
                if(w > h){
                    w = [UIScreen mainScreen].bounds.size.height;
                    h = [UIScreen mainScreen].bounds.size.width;
                }
                [self.previewView setFrame:CGRectMake(0, 44, w, (w*4/3))];
                [stillButton setFrame:CGRectMake(w/2-31.5, h-20-69, 69, 63)];
                [backButton setFrame:CGRectMake(20, 0, 44, 44)];
                [cameraButton setFrame:CGRectMake(w-20-44, 0, 44, 44)];
                [torchButton setFrame:CGRectMake(w-20-44-20-44, 0, 44, 44)];
                [openAlbumButton setFrame:CGRectMake(20, h-30-50, 50, 50)];
            }
        }
    }else{
        NSLog(@"ipad");
        torchButton.hidden = true;
        if(leftView != nil){
            [leftView removeFromSuperview];
            leftView = nil;
        }
        if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait){
            [self.previewView setFrame:CGRectMake(0, 0, w, h)];
            leftView = [[UIView alloc] initWithFrame:CGRectMake(w-103, 0, 103, 1024)];
            [backButton setFrame:CGRectMake(w-73.5, 20, 44, 44)];
            [stillButton setFrame:CGRectMake(w-86, h/2-31.5, 69, 63)];
            [cameraButton setFrame:CGRectMake(w-73.5, h-64, 44, 44)];
            [openAlbumButton setFrame:CGRectMake(w-73.5, h-64-20-44, 44, 44)];
        }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
            [self.previewView setFrame:CGRectMake(0, 0, w, h)];
            leftView = [[UIView alloc] initWithFrame:CGRectMake(w-103, 0, 103, 1024)];
            [backButton setFrame:CGRectMake(w-73.5, 20, 44, 44)];
            [stillButton setFrame:CGRectMake(w-86, h/2-31.5, 69, 63)];
            [cameraButton setFrame:CGRectMake(w-73.5, h-64, 44, 44)];
            [openAlbumButton setFrame:CGRectMake(w-73.5, h-64-20-44, 44, 44)];
        }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
            [self.previewView setFrame:CGRectMake(0, 0, w, h)];
            leftView = [[UIView alloc] initWithFrame:CGRectMake(w-103, 0, 103, 1024)];
            [backButton setFrame:CGRectMake(w-73.5, 20, 44, 44)];
            [stillButton setFrame:CGRectMake(w-86, h/2-31.5, 69, 63)];
            [cameraButton setFrame:CGRectMake(w-73.5, h-64, 44, 44)];
            [openAlbumButton setFrame:CGRectMake(w-73.5, h-64-20-44, 44, 44)];
        }else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
            NSLog(@"~ upsidedown");
            [self.previewView setFrame:CGRectMake(0, 0, w, h)];
            leftView = [[UIView alloc] initWithFrame:CGRectMake(w-103, 0, 103, 1024)];
            [backButton setFrame:CGRectMake(w-73.5, 20, 44, 44)];
            [stillButton setFrame:CGRectMake(w-86, h/2-31.5, 69, 63)];
            [cameraButton setFrame:CGRectMake(w-73.5, h-64, 44, 44)];
            [openAlbumButton setFrame:CGRectMake(w-73.5, h-64-20-44, 44, 44)];
            if(alertViewCam != nil){
                alertViewCam.center = CGPointMake(w/2, h/2);
            }
        }else{
            if(w > h){
                w = [UIScreen mainScreen].bounds.size.height;
                h = [UIScreen mainScreen].bounds.size.width;
            }
            [self.previewView setFrame:CGRectMake(0, 0, w, h)];
            leftView = [[UIView alloc] initWithFrame:CGRectMake(w-103, 0, 103, 1024)];
            [backButton setFrame:CGRectMake(w-73.5, 20, 44, 44)];
            [stillButton setFrame:CGRectMake(w-86, h/2-31.5, 69, 63)];
            [cameraButton setFrame:CGRectMake(w-73.5, h-64, 44, 44)];
            [openAlbumButton setFrame:CGRectMake(w-73.5, h-64-20-44, 44, 44)];
        }
        leftView.backgroundColor = [UIColor blackColor];
        leftView.alpha = 0.3;
        [self.view addSubview:leftView];

        [self.view bringSubviewToFront:cameraButton];
        [self.view bringSubviewToFront:backButton];
        [self.view bringSubviewToFront:stillButton];
        [self.view bringSubviewToFront:openAlbumButton];
    }
    
    if(first){
        NSLog(@"PHFetchOptions");
        first = false;
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        PHAsset *lastAsset = [fetchResult lastObject];
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:openAlbumButton.bounds.size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        CGRect rect = CGRectMake(0,0,50,50);
                                                        UIGraphicsBeginImageContext( rect.size );
                                                        [result drawInRect:rect];
                                                        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
                                                        UIGraphicsEndImageContext();
                                                    
                                                        NSData *imageData = UIImagePNGRepresentation(picture1);
                                                        UIImage *img=[UIImage imageWithData:imageData];
                                                        //[openAlbumButton setImage:img forState:UIControlStateNormal];
                                                        [openAlbumButton setBackgroundImage:img forState:UIControlStateNormal];
                                                    });
                                                }];
    }
    
    NSLog(@"preview : %f, %f, %f, %f", self.previewView.frame.origin.x, self.previewView.frame.origin.y, self.previewView.frame.size.width, self.previewView.frame.size.height);
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    [UIView setAnimationsEnabled:false];
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            NSLog(@"UIDeviceOrientationPortrait");
            if(alertViewCam != nil){
                alertViewCam.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            }
            [self setCameraControlView];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            [self setCameraControlView];
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            if(alertViewCam != nil){
                alertViewCam.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            }
            [self setCameraControlView];
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"UIDeviceOrientationLandscapeRight");
            if(alertViewCam != nil){
                alertViewCam.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            }
            [self setCameraControlView];
            break;
        case UIDeviceOrientationFaceUp:
            NSLog(@"UIDeviceOrientationFaceUp");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"UIDeviceOrientationFaceDown");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"UIDeviceOrientationUnknown");
            break;
        default:
            break;
    }
    return ![self lockInterfaceRotation];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                [[self cameraButton] setEnabled:NO];
                [[self recordButton] setTitle:NSLocalizedString(@"", @"Recording button stop title") forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
            else
            {
                [[self cameraButton] setEnabled:YES];
                [[self recordButton] setTitle:NSLocalizedString(@"", @"Recording button record title") forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [[self cameraButton] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
                [[self stillButton] setEnabled:YES];
            }
            else
            {
                [[self cameraButton] setEnabled:NO];
                [[self recordButton] setEnabled:NO];
                [[self stillButton] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)initializeTimer {
    hrCounter = 0;
    minCounter = 0;
    secCounter = 0;
    //設定Timer觸發的頻率，每秒30次
    float theInterval = 1.0/1.0;
    
    [recCounter setTitle:@"00:00:00" forState:UIControlStateNormal];
    
    //正式啟用Timer，selector是設定Timer觸發時所要呼叫的函式
    myTimer = [NSTimer scheduledTimerWithTimeInterval:theInterval
                                               target:self
                                             selector:@selector(recTotalTime)
                                             userInfo:nil
                                              repeats:YES];
}

-(void) recTotalTime{
    [recCounter setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", hrCounter, minCounter, secCounter] forState:UIControlStateNormal];
    secCounter++;
    if(secCounter == 60){
        secCounter = 0;
        minCounter++;
    }
    if(minCounter == 60){
        minCounter = 0;
        hrCounter++;
    }
}

#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
    [[self recordButton] setEnabled:NO];
    if(rec == false){
        //start rec
        //NSLog(@"toggleMovieRecording %d", takeCount);
        recCounter.hidden = false;
        [self initializeTimer];
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            [recordButton setImage:[UIImage imageNamed:@"rec_2_iphone.png"] forState:UIControlStateNormal];
            [recCounter setBackgroundImage:[UIImage imageNamed:@"rec_time_iphone.png"] forState:UIControlStateNormal];
        }else{
            [recordButton setImage:[UIImage imageNamed:@"rec_2_ipad.png"] forState:UIControlStateNormal];
            [recCounter setBackgroundImage:[UIImage imageNamed:@"rec_time_ipad.png"] forState:UIControlStateNormal];
            recCounter.titleLabel.font = [UIFont systemFontOfSize:24];
        }
        rec = true;
    }else{
        //stop rec
        recCounter.hidden = true;
        [myTimer invalidate];
        myTimer = nil;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            [recordButton setImage:[UIImage imageNamed:@"rec_1_iphone.png"] forState:UIControlStateNormal];
        }else{
            [recordButton setImage:[UIImage imageNamed:@"rec_1_ipad.png"] forState:UIControlStateNormal];
        }
        rec = false;
    }
    
    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Turning OFF flash for video recording
            [CameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
            
            // Start recording to a temporary file.
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else
        {
            [[self movieFileOutput] stopRecording];
        }
    });
}

- (IBAction)changeCamera:(id)sender
{
    [[self cameraButton] setEnabled:NO];
    [[self recordButton] setEnabled:NO];
    [[self stillButton] setEnabled:NO];
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self cameraButton] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
        });
    });
}

- (IBAction)snapStillImage:(id)sender
{
    [UIView setAnimationsEnabled:YES];
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                [openAlbumButton setImage:image forState:UIControlStateNormal];
            }
        }];
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)torchTurnOnOff:(id)sender {
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!on) {
                on = true;
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                on = false;
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (IBAction)openAlbum:(id)sender {
    NSLog(@"openAlbum");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Photos://"]];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    //if (error)
        //NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        //if (error)
            //NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            //NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            //NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}



//取得資料整理
-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    //DataText.text = value;
    NSLog(@"camera     %@",value);
    
    if(value.length == 18){
        NSScanner *scanner;
        unsigned result = 0;
        scanner = [[NSScanner alloc] initWithString:[value substringWithRange:NSMakeRange(2,2)]];
        [scanner scanHexInt:&result];
        if([[value substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"] && result<=4 && camera_check == false){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TakePhoto" object:nil];
            camera_check = true;
        }else{
            if(camera_check == true){
                camera_check = false;
            }else{
                camera_check = false;
            }
        }
    }
}


//連線成功
-(void)setConnect
{
    NSLog(@"OK+CONN");
    [[NSUserDefaults standardUserDefaults] setObject:@"y" forKey:@"connect"];
    //[self showOkayCancelAlert:@"iTag connected\niTag連線成功"];
}


//斷線
-(void)setDisconnect
{
    NSLog(@"OK+LOST");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(udfHandle)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
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



@end
