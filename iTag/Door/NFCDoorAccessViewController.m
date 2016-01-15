//
//  NFCDoorAccessViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/9.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//
//
// output action :
// - (IBAction)loadToBandDoorPressed:(id)sender;
//
// output data :
// an array save in
// [[NSUserDefaults standardUserDefaults] objectForKey:@"door"]


#import "NFCDoorAccessViewController.h"

@interface NFCDoorAccessViewController ()

@end

@implementation NFCDoorAccessViewController
@synthesize deleteButton, saveButton, doorBackButton;
@synthesize keyIDTextfield;
@synthesize NFCArray;
@synthesize keyNameArray;
@synthesize loadToBandDoor;
@synthesize sensor;

int chooseIndexOfKey;

CGFloat animatedDistance;

UIImageView *keySelectImageview;

UIButton *key1Button, *key2Button, *key3Button, *key4Button;
UITextField *key1Textfield, *key2Textfield, *key3Textfield, *key4Textfield;
UIImageView *key1ImageView, *key2ImageView, *key3ImageView, *key4ImageView;

AlertViewController *alertVCDoor;
UIView *alertViewDoor;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    chooseIndexOfKey = 4;
    
    alertVCDoor = [AlertViewController new];
    
    [self setDoorUI];
    
    StringArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    saveButton.enabled = false;
    deleteButton.enabled = false;
}

- (int)checkKeyStorage{
    int keyStorage = 0;
    for(int i=0;i<4;i++){
        if([[NFCArray objectAtIndex:i] isEqualToString:@"nil"]){
            keyStorage++;
        }
    }
    if(keyStorage == 0){
        saveButton.enabled = false;
    }
    NSLog(@"storage %d", keyStorage);
    return keyStorage;
}

- (void)setDoorUI{
    float wRatio = [alertVCDoor getSizeWRatio];
    float hRatio = [alertVCDoor getSizeHRatio];
    float w = [alertVCDoor getSizeW];
    
    [self.view addSubview:[alertVCDoor setBGImageView:[UIImage imageNamed:@"bg_key"]]];
    
    UIView *noTapView;
    
    [doorBackButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [keyIDTextfield setTranslatesAutoresizingMaskIntoConstraints:YES];
    [deleteButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [saveButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [loadToBandDoor setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        noTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 80*hRatio, w, 200*hRatio)];
        [doorBackButton setFrame:CGRectMake(32*wRatio, 15*hRatio, doorBackButton.imageView.image.size.width*wRatio, doorBackButton.imageView.image.size.height*hRatio)];
        [keyIDTextfield setFrame:CGRectMake(102*wRatio, 145*hRatio, (w-145-30)*wRatio, 20*hRatio)];
        [deleteButton setFrame:CGRectMake(128*wRatio, 202*hRatio, deleteButton.imageView.image.size.width*wRatio, deleteButton.imageView.image.size.height*hRatio)];
        [saveButton setFrame:CGRectMake(141*wRatio, 269*hRatio, saveButton.imageView.image.size.width*wRatio, saveButton.imageView.image.size.height*hRatio)];
        [loadToBandDoor setFrame:CGRectMake(113*wRatio, 651*hRatio, loadToBandDoor.imageView.image.size.width*wRatio, loadToBandDoor.imageView.image.size.height*hRatio)];
    }else{
        noTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 100*hRatio, w, 150*hRatio)];
        [doorBackButton setFrame:CGRectMake(63*wRatio, 28*hRatio, doorBackButton.imageView.image.size.width*wRatio, doorBackButton.imageView.image.size.height*hRatio)];
        [keyIDTextfield setFrame:CGRectMake(206*wRatio, 234*hRatio, (w-206)*wRatio, 40*hRatio)];
        [deleteButton setFrame:CGRectMake(267.5*wRatio, 309*hRatio, deleteButton.imageView.image.size.width*wRatio, deleteButton.imageView.image.size.height*hRatio)];
        [saveButton setFrame:CGRectMake(288*wRatio, 400*hRatio, saveButton.imageView.image.size.width*wRatio, saveButton.imageView.image.size.height*hRatio)];
        [loadToBandDoor setFrame:CGRectMake(246*wRatio, 896*hRatio, loadToBandDoor.imageView.image.size.width*wRatio, loadToBandDoor.imageView.image.size.height*hRatio)];
    }
    
    noTapView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:noTapView];
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAtnoTapView)];
    [noTapView addGestureRecognizer:tap0];
    [self.view bringSubviewToFront:noTapView];
    
    [doorBackButton setImage:[UIImage imageNamed:@"back02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:doorBackButton];
    
    keyIDTextfield.textColor = [UIColor whiteColor];
    keyIDTextfield.delegate = self;
    [keyIDTextfield addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view bringSubviewToFront:keyIDTextfield];
    
    [deleteButton setImage:[UIImage imageNamed:@"delete02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:deleteButton];
    
    [saveButton setImage:[UIImage imageNamed:@"save02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:saveButton];
    
    [loadToBandDoor setImage:[UIImage imageNamed:@"upload02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:loadToBandDoor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActive:)];
    [self .view addGestureRecognizer:tap];
    
    [self setKeyUI];
}

- (void)tapAtnoTapView{
    //NSLog(@"tapAtnoTapView");
}

- (void)tapActive:(UIGestureRecognizer *)ges{
    //NSLog(@"tap at bg");
    keyIDTextfield.text = nil;
    [keySelectImageview setFrame:CGRectMake(0, 0, 0, 0)];
    deleteButton.enabled = false;
    keyIDTextfield.enabled = true;
    key1Textfield.enabled = false;
    key2Textfield.enabled = false;
    key3Textfield.enabled = false;
    key4Textfield.enabled = false;
    chooseIndexOfKey = 4;
    [self textFieldDone:key1Textfield];
    [self textFieldDone:key2Textfield];
    [self textFieldDone:key3Textfield];
    [self textFieldDone:key4Textfield];
}

- (void)setKeyUI{
    float wRatio = [alertVCDoor getSizeWRatio];
    float hRatio = [alertVCDoor getSizeHRatio];
    
    [self getNFCData];
    [self checkKeyStorage];
    
    keySelectImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_select"]];
    
    UIColor *tintColor = [UIColor colorWithRed:47.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        //key1
        key1Button = [[UIButton alloc] initWithFrame:CGRectMake(24*wRatio, 311*hRatio, 367*wRatio, 88*hRatio)];
        key1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(42*wRatio, (key1Button.bounds.size.height-49*hRatio)/2, 50*wRatio, 49*hRatio)];
        key1Textfield = [[UITextField alloc] initWithFrame:CGRectMake((42+50+10)*wRatio, (key1Button.bounds.size.height-30)/2, key1Button.bounds.size.width-(42+50+30)*wRatio, 30)];
        key1Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
    
        //key2
        key2Button = [[UIButton alloc] initWithFrame:CGRectMake(24*wRatio, 390*hRatio, 367*wRatio, 88*hRatio)];
        key2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(42*wRatio, (key2Button.bounds.size.height-49*hRatio)/2, 50*wRatio, 49*hRatio)];
        key2Textfield = [[UITextField alloc] initWithFrame:CGRectMake((42+50+10)*wRatio, (key2Button.bounds.size.height-30)/2, key2Button.bounds.size.width-(42+50+30)*wRatio, 30)];
        key2Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
    
        //key3
        key3Button = [[UIButton alloc] initWithFrame:CGRectMake(24*wRatio, 469*hRatio, 367*wRatio, 88*hRatio)];
        key3ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(42*wRatio, (key3Button.bounds.size.height-49*hRatio)/2, 50*wRatio, 49*hRatio)];
        key3Textfield = [[UITextField alloc] initWithFrame:CGRectMake((42+50+10)*wRatio, (key3Button.bounds.size.height-30)/2, key3Button.bounds.size.width-(42+50+30)*wRatio, 30)];
        key3Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
    
        //key4
        key4Button = [[UIButton alloc] initWithFrame:CGRectMake(24*wRatio, 548*hRatio, 367*wRatio, 88*hRatio)];
        key4ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(42*wRatio, (key4Button.bounds.size.height-49*hRatio)/2, 50*wRatio, 49*hRatio)];
        key4Textfield = [[UITextField alloc] initWithFrame:CGRectMake((42+50+10)*wRatio, (key4Button.bounds.size.height-30)/2, key4Button.bounds.size.width-(42+50+30)*wRatio, 30)];
        key4Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
    }else{
        //key1
        key1Button = [[UIButton alloc] initWithFrame:CGRectMake(118*wRatio, 462*hRatio, 536*wRatio, 121*hRatio)];
        key1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(58*wRatio, (key1Button.bounds.size.height-78*hRatio)/2, 74*wRatio, 78*hRatio)];
        key1Textfield = [[UITextField alloc] initWithFrame:CGRectMake((58+74+20)*wRatio, (key1Button.bounds.size.height-50)/2, key1Button.bounds.size.width-(58+74+60)*wRatio, 50)];
        key1Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
        
        //key2
        key2Button = [[UIButton alloc] initWithFrame:CGRectMake(118*wRatio, 564*hRatio, 536*wRatio, 121*hRatio)];
        key2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(58*wRatio, (key2Button.bounds.size.height-78*hRatio)/2, 74*wRatio, 78*hRatio)];
        key2Textfield = [[UITextField alloc] initWithFrame:CGRectMake((58+74+20)*wRatio, (key2Button.bounds.size.height-50)/2, key2Button.bounds.size.width-(58+74+60)*wRatio, 50)];
        key2Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
        
        
        //key3
        key3Button = [[UIButton alloc] initWithFrame:CGRectMake(118*wRatio, 667*hRatio, 536*wRatio, 121*hRatio)];
        key3ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(58*wRatio, (key3Button.bounds.size.height-78*hRatio)/2, 74*wRatio, 78*hRatio)];
        key3Textfield = [[UITextField alloc] initWithFrame:CGRectMake((58+74+20)*wRatio, (key3Button.bounds.size.height-50)/2, key3Button.bounds.size.width-(58+74+60)*wRatio, 50)];
        key3Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
        
        
        //key4
        key4Button = [[UIButton alloc] initWithFrame:CGRectMake(118*wRatio, 769*hRatio, 536*wRatio, 121*hRatio)];
        key4ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(58*wRatio, (key4Button.bounds.size.height-78*hRatio)/2, 74*wRatio, 78*hRatio)];
        key4Textfield = [[UITextField alloc] initWithFrame:CGRectMake((58+74+20)*wRatio, (key4Button.bounds.size.height-50)/2, key4Button.bounds.size.width-(58+74+60)*wRatio, 50)];
        key4Textfield.font = [UIFont fontWithName:@"Heiti TC" size:17];
    }
    
    //key1
    [key1Button addTarget:self action:@selector(keyButtonPressed:) forControlEvents:UIControlEventAllTouchEvents];
    [key1Button addSubview:key1ImageView];
    key1Textfield.delegate = self;
    key1Textfield.tintColor = tintColor;
    key1Textfield.textColor = [UIColor whiteColor];
    [key1Textfield addTarget:self action:@selector(keySelect:) forControlEvents:UIControlEventEditingDidBegin];
    [key1Textfield addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [key1Button addSubview:key1Textfield];
    NSString *key = [NFCArray objectAtIndex:0];
    if([key isEqualToString:@"nil"]){
        key1Textfield.enabled = false;
        key1ImageView.image = [UIImage imageNamed:@"key1_01"];
    }else{
        key1Textfield.enabled = true;
        key1ImageView.image = [UIImage imageNamed:@"key1_02"];
        if(![[keyNameArray objectAtIndex:0] isEqualToString:@"nil"])
            key1Textfield.text = [keyNameArray objectAtIndex:0];
    }
    [self.view addSubview:key1Button];
    
    //key2
    [key2Button addTarget:self action:@selector(keyButtonPressed:) forControlEvents:UIControlEventAllTouchEvents];
    [key2Button addSubview:key2ImageView];
    key2Textfield.delegate = self;
    key2Textfield.tintColor = tintColor;
    key2Textfield.textColor = [UIColor whiteColor];
    [key2Textfield addTarget:self action:@selector(keySelect:) forControlEvents:UIControlEventEditingDidBegin];
    [key2Textfield addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [key2Button addSubview:key2Textfield];
    key = [NFCArray objectAtIndex:1];
    if([key isEqualToString:@"nil"]){
        key2Textfield.enabled = false;
        key2ImageView.image = [UIImage imageNamed:@"key2_01"];
    }else{
        key2Textfield.enabled = true;
        key2ImageView.image = [UIImage imageNamed:@"key2_02"];
        if(![[keyNameArray objectAtIndex:1] isEqualToString:@"nil"])
            key2Textfield.text = [keyNameArray objectAtIndex:1];
    }
    [self.view addSubview:key2Button];

    //key3
    [key3Button addTarget:self action:@selector(keyButtonPressed:) forControlEvents:UIControlEventAllTouchEvents];
    [key3Button addSubview:key3ImageView];
    key3Textfield.delegate = self;
    key3Textfield.tintColor = tintColor;
    key3Textfield.textColor = [UIColor whiteColor];
    [key3Textfield addTarget:self action:@selector(keySelect:) forControlEvents:UIControlEventEditingDidBegin];
    [key3Textfield addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [key3Button addSubview:key3Textfield];
    key = [NFCArray objectAtIndex:2];
    if([key isEqualToString:@"nil"]){
        key3Textfield.enabled = false;
        key3ImageView.image = [UIImage imageNamed:@"key3_01"];
    }else{
        key3Textfield.enabled = true;
        key3ImageView.image = [UIImage imageNamed:@"key3_02"];
        if(![[keyNameArray objectAtIndex:2] isEqualToString:@"nil"])
            key3Textfield.text = [keyNameArray objectAtIndex:2];
    }
    [self.view addSubview:key3Button];
    
    //key4
    [key4Button addTarget:self action:@selector(keyButtonPressed:) forControlEvents:UIControlEventAllTouchEvents];
    [key4Button addSubview:key4ImageView];
    key4Textfield.delegate = self;
    key4Textfield.tintColor = tintColor;
    key4Textfield.textColor = [UIColor whiteColor];
    [key4Textfield addTarget:self action:@selector(keySelect:) forControlEvents:UIControlEventEditingDidBegin];
    [key4Textfield addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [key4Button addSubview:key4Textfield];
    key = [NFCArray objectAtIndex:3];
    if([key isEqualToString:@"nil"]){
        key4Textfield.enabled = false;
        key4ImageView.image = [UIImage imageNamed:@"key4_01"];
    }else{
        key4Textfield.enabled = true;
        key4ImageView.image = [UIImage imageNamed:@"key4_02"];
        if(![[keyNameArray objectAtIndex:3] isEqualToString:@"nil"])
            key4Textfield.text = [keyNameArray objectAtIndex:3];
    }
    [self.view addSubview:key4Button];
}

- (void)textFieldDone:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(216 * heightFraction);
    }
    else
    {
        animatedDistance = floor(162 * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textfield{
    if(textfield == keyIDTextfield){
        saveButton.enabled = true;
    }else if(textfield == key1Textfield && textfield.text.length>0){
        [keyNameArray removeObjectAtIndex:0];
        [keyNameArray insertObject:textfield.text atIndex:0];
    }else if(textfield == key2Textfield && textfield.text.length>0){
        [keyNameArray removeObjectAtIndex:1];
        [keyNameArray insertObject:textfield.text atIndex:1];
    }else if(textfield == key3Textfield && textfield.text.length>0){
        [keyNameArray removeObjectAtIndex:2];
        [keyNameArray insertObject:textfield.text atIndex:2];
    }else if(textfield == key4Textfield && textfield.text.length>0){
        [keyNameArray removeObjectAtIndex:3];
        [keyNameArray insertObject:textfield.text atIndex:3];
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)keySelect:(UITextField *)textField{
    float wRatio = [alertVCDoor getSizeWRatio];
    float hRatio = [alertVCDoor getSizeHRatio];
    
    deleteButton.enabled = true;
    
    if(textField == key1Textfield){
        NSLog(@"key 1 selected");
        chooseIndexOfKey = 0;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 311*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 462*hRatio, 536*wRatio, 121*hRatio)];
    }else if(textField == key2Textfield){
        NSLog(@"key 2 selected");
        chooseIndexOfKey = 1;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 390*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 564*hRatio, 536*wRatio, 121*hRatio)];
    }else if(textField == key3Textfield){
        NSLog(@"key 3 selected");
        chooseIndexOfKey = 2;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 469*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 667*hRatio, 536*wRatio, 121*hRatio)];
    }else if(textField == key4Textfield){
        NSLog(@"key 4 selected");
        chooseIndexOfKey = 3;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 548*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 769*hRatio, 536*wRatio, 121*hRatio)];
    }
    [self checkKeyAtIndexNotEmptyToDelete:chooseIndexOfKey];
    [self.view addSubview:keySelectImageview];
}

- (void)keyButtonPressed:(UIButton *)sender{
    float wRatio = [alertVCDoor getSizeWRatio];
    float hRatio = [alertVCDoor getSizeHRatio];
    
    if(sender == key1Button){
        NSLog(@"key 1 selected");
        chooseIndexOfKey = 0;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 311*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 462*hRatio, 536*wRatio, 121*hRatio)];
        [self textFieldDone:key2Textfield];
        [self textFieldDone:key3Textfield];
        [self textFieldDone:key4Textfield];
    }else if(sender == key2Button){
        NSLog(@"key 2 selected");
        chooseIndexOfKey = 1;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 390*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 564*hRatio, 536*wRatio, 121*hRatio)];
        [self textFieldDone:key1Textfield];
        [self textFieldDone:key3Textfield];
        [self textFieldDone:key4Textfield];
    }else if(sender == key3Button){
        NSLog(@"key 3 selected");
        chooseIndexOfKey = 2;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 469*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 667*hRatio, 536*wRatio, 121*hRatio)];
        [self textFieldDone:key1Textfield];
        [self textFieldDone:key2Textfield];
        [self textFieldDone:key4Textfield];
    }else if(sender == key4Button){
        NSLog(@"key 4 selected");
        chooseIndexOfKey = 3;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            [keySelectImageview setFrame:CGRectMake(24*wRatio, 548*hRatio, 367*wRatio, 88*hRatio)];
        else
            [keySelectImageview setFrame:CGRectMake(118*wRatio, 769*hRatio, 536*wRatio, 121*hRatio)];
        [self textFieldDone:key1Textfield];
        [self textFieldDone:key2Textfield];
        [self textFieldDone:key3Textfield];
    }
    [self checkKeyAtIndexNotEmptyToDelete:chooseIndexOfKey];
    [self.view addSubview:keySelectImageview];
}

- (BOOL)checkKeyAtIndexNotEmptyToDelete:(int)index{
    BOOL isFull = false;
    //isEdit = false;
    if(![[NFCArray objectAtIndex:index] isEqualToString:@"nil"]){
        isFull = true;
        
        deleteButton.enabled = true;
        keyIDTextfield.enabled = false;
    }else{
        isFull = false;
        
        deleteButton.enabled = false;
        keyIDTextfield.enabled = true;
    }
    return isFull;
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"door");
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    NSLog(@"Name : %@",sensor.activePeripheral.name);
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"door exit"); //view 將要結束
    self.sensor.delegate = nil;
}


- (void)getNFCData{
    if([[NSUserDefaults standardUserDefaults] arrayForKey:@"door"].count != 0){
        NFCArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"door"]];
        keyNameArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"keyName"]];
    }else{
        NFCArray = [[NSMutableArray alloc] initWithObjects:@"nil", @"nil", @"nil", @"nil", nil];
        keyNameArray = [[NSMutableArray alloc] initWithObjects:@"nil", @"nil", @"nil", @"nil", nil];
    }
}

- (void)setNFCData{
    [[NSUserDefaults standardUserDefaults] setObject:NFCArray forKey:@"door"];
    [[NSUserDefaults standardUserDefaults] setObject:keyNameArray forKey:@"keyName"];
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

- (IBAction)backDoorPressed:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)loadToBandDoorPressed:(id)sender {
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"]){
        [self sendData];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(udfHandle)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
        [alertViewDoor removeFromSuperview];
        alertViewDoor = nil;
        alertViewDoor = [alertVCDoor alertConnectError];
        
        [self.view addSubview:alertViewDoor];
        
        UIButton *tryButton = [alertVCDoor getTryBurtton];
        [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [alertVCDoor getCancelButton];
        [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [alertViewDoor addSubview:tryButton];
        [alertViewDoor addSubview:cancelButton];
    }
}

- (void)sendData{
    //load data to band
    NSString *index=@"";
    [StringArray removeAllObjects];
    int j=0;
    count = 0;
    for(int i=0;i<[NFCArray count];i++){
        
        if(j==0)
            index = @"F0";
        if(j==1)
            index = @"F4";
        if(j==2)
            index = @"F8";
        if(j==3)
            index = @"FC";
        
        
        NSString *key = [NFCArray objectAtIndex:i];
        if(key != nil){
            NSString *data = [NSString stringWithFormat:@"0223%@04000004%@000000000000000%lu",index,[NFCArray objectAtIndex:i],(unsigned long)[NFCArray count]];
            [StringArray addObject:data];
        }
        
        j++;
    }
    [sensor SendData:[StringArray objectAtIndex:0]];
}

- (void) udfHandle{
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"connect"];
    
    if([str isEqualToString:@"y"]){
        NSLog(@"connect state : success");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
        
        [self sendData];
        
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    }else if([str isEqualToString:@"n"]){
        NSLog(@"connect state : failed");
        
        [alertViewDoor removeFromSuperview];
        alertViewDoor = nil;
        alertViewDoor = [alertVCDoor alertConnectError];
        
        [self.view addSubview:alertViewDoor];
        
        UIButton *tryButton = [alertVCDoor getTryBurtton];
        [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [alertVCDoor getCancelButton];
        [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [alertViewDoor addSubview:tryButton];
        [alertViewDoor addSubview:cancelButton];
        
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
        
        [alertViewDoor removeFromSuperview];
        alertViewDoor = nil;
        alertViewDoor = [alertVCDoor alertConnecting];
        [self.view addSubview:alertViewDoor];
    }else{
        NSLog(@"cancel");
        [button.superview removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    }
}

- (void)connectTimeout{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"])
        [[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"connect"];
}

- (void)dismissAlert{
    NSLog(@"dismiss alert");
    if(alertViewDoor != nil){
        [alertViewDoor removeFromSuperview];
        alertViewDoor = nil;
    }
}

- (void)changeKeyUI:(int)index{
    //delete or save
    bool editEnable;
    NSString *keytype;
    if([[NFCArray objectAtIndex:index] isEqualToString:@"nil"]){
        keytype = @"1";
        editEnable = false;
        [keyNameArray removeObjectAtIndex:index];
        [keyNameArray insertObject:@"nil" atIndex:index];
    }else{
        keytype = @"2";
        editEnable = true;
    }
    switch (index) {
        case 0:
            key1Textfield.text = nil;
            key1Textfield.enabled = editEnable;
            key1ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"key%d_0%@", index+1, keytype]];
            break;
        case 1:
            key2Textfield.text = nil;
            key2Textfield.enabled = editEnable;
            key2ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"key%d_0%@", index+1, keytype]];
            break;
        case 2:
            key3Textfield.text = nil;
            key3Textfield.enabled = editEnable;
            key3ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"key%d_0%@", index+1, keytype]];
            break;
        case 3:
            key4Textfield.text = nil;
            key4Textfield.enabled = editEnable;
            key4ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"key%d_0%@", index+1, keytype]];
            break;
        default:
            break;
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    [NFCArray removeObjectAtIndex:chooseIndexOfKey];
    [NFCArray insertObject:@"nil" atIndex:chooseIndexOfKey];
    [self changeKeyUI:chooseIndexOfKey];
}

- (IBAction)saveButtonPressed:(id)sender {
    if(keyIDTextfield.text.length>0){
        for(int i=0;i<4;i++){
            if([[NFCArray objectAtIndex:i] isEqualToString:@"nil"]){
                [NFCArray removeObjectAtIndex:i];
                [NFCArray insertObject:keyIDTextfield.text atIndex:i];
                [self changeKeyUI:i];
                break;
            }
        }
        keyIDTextfield.text = nil;
        [self checkKeyStorage];
    }
    NSLog(@"~~key :\ncount : %ld\n1 : %@\n2 : %@\n3 : %@\n4 : %@", NFCArray.count, [NFCArray objectAtIndex:0], [NFCArray objectAtIndex:1], [NFCArray objectAtIndex:2], [NFCArray objectAtIndex:3]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//取得資料整理
-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    if([value isEqualToString:@"010d0c"]){
        count++;
        if (count < StringArray.count)
        {
           [sensor SendData:[StringArray objectAtIndex:count]];
        } else if (count == StringArray.count)
        {
            [sensor EndData];// 結束
            //[self showOkayCancelAlert:@"發送結束"];
            
            [self uploadSuccess];
            
            [StringArray removeAllObjects];
        } else if(StringArray.count==0 && count==1)
        {
            [sensor EndData];// 結束
            //[self showOkayCancelAlert:@"發送結束"];
            
            [self uploadSuccess];
        }
    } if([value isEqualToString:@"010e0f"]){
        if (count < StringArray.count){
            //sleep(100);
            [sensor SendData:[StringArray objectAtIndex:count]];
        } else if (count == StringArray.count) {
            [sensor EndData];// 結束
            //[self showOkayCancelAlert:@"發送結束"];
            
            [self uploadSuccess];
        }
    }
}

- (void)uploadSuccess{
    [self setNFCData];
    [alertViewDoor removeFromSuperview];
    alertViewDoor = nil;
    alertViewDoor = [alertVCDoor alertCustom:@"Upload success"];
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
