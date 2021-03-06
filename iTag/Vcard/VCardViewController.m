//
//  VCardViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/1.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//
/**
 *	@author Roth, 16-02-25 14:02:15
 *
 *  @brief - 每次編輯完都把textfield跟textview內的資料存進NSUserDefaults
 *
 *	@param IBAction	[[NSUserDefaults standardUserDefaults] setObject:vCardInfo forKey:@"vCardinfo"]
     keys :
       name
       company
       title
       companyPhone
       address
       phone1
       phone2
       email1
       email2
       web
       skype
       QQ
       note
 *
 *
 */

#import "VCardViewController.h"

@interface VCardViewController ()

@end

@implementation VCardViewController
@synthesize lineImageview;
@synthesize nameTextField, companyTextField, titleTextField, companyPhoneTextField, addressTextField, phoneTextField, phone2TextField, emailTextField, email2TextField, webTextField, skypeTextField, QQTextField;
@synthesize noteTextView;
@synthesize vCardLoadButton, vCardBackButton;
@synthesize vCardScrollView;

@synthesize sensor;

NSMutableDictionary *vCardInfo;//存名片資料

AlertViewController *alertVCVCard;
UIView *alertViewVcard;

CGFloat animatedDistanceV;

#pragma mark vCard view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    vCardInfo = [[NSMutableDictionary alloc] initWithDictionary:[userDefaults dictionaryForKey:@"vCard"]];
    alertVCVCard = [AlertViewController new];
    
    StringArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    [self setVCardUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"vCard");
    BleController *shareBERController = [BleController sharedController];
    sensor = shareBERController.sensor;
    sensor.delegate = self;
    NSLog(@"Name : %@",sensor.activePeripheral.name);
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"vcard exit"); //view 將要結束
    self.sensor.delegate = nil;
}

#pragma mark vCard UI setting
- (void)setVCardUI{
    float wRatio = [alertVCVCard getSizeWRatio];
    float hRatio = [alertVCVCard getSizeHRatio];
    float w = [alertVCVCard getSizeW];
    
    [self.view addSubview:[alertVCVCard setBGImageView:[UIImage imageNamed:@"bg_vCard"]]];
    
    [vCardScrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [vCardBackButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [nameTextField setTranslatesAutoresizingMaskIntoConstraints:YES];
    [lineImageview setTranslatesAutoresizingMaskIntoConstraints:YES];
    [vCardLoadButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        [vCardScrollView setFrame:CGRectMake(32*wRatio, 213*hRatio, w-64*wRatio, 631*hRatio-213*hRatio)];
        [vCardBackButton setFrame:CGRectMake(35*wRatio, 15*hRatio, vCardBackButton.imageView.image.size.width*wRatio, vCardBackButton.imageView.image.size.height*hRatio)];
        [nameTextField setFrame:CGRectMake(79*wRatio, 106*hRatio, 260*wRatio, 39*hRatio)];
        [lineImageview setFrame:CGRectMake(32*wRatio, 155*hRatio, 351*wRatio, 2*hRatio)];
        [vCardLoadButton setFrame:CGRectMake(113*wRatio, 651*hRatio, 193*wRatio, 44*hRatio)];
    }else{
        [vCardScrollView setFrame:CGRectMake(32*wRatio, 259*hRatio, w-64*wRatio, 896*hRatio-259*hRatio)];
        [vCardBackButton setFrame:CGRectMake(63*wRatio, 28*hRatio, vCardBackButton.imageView.image.size.width*wRatio, vCardBackButton.imageView.image.size.height*hRatio)];
        [nameTextField setFrame:CGRectMake(201*wRatio, 175*hRatio, 371*wRatio, 56*hRatio)];
        [lineImageview setFrame:CGRectMake(58*wRatio, 245*hRatio, 652*wRatio, 4*hRatio)];
        [vCardLoadButton setFrame:CGRectMake(246*wRatio, 896*hRatio, 287*wRatio, 65*hRatio)];
    }

    noteTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vcard_space"]];
    
    [self.view bringSubviewToFront:vCardScrollView];

    [vCardBackButton setImage:[UIImage imageNamed:@"back02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:vCardBackButton];

    nameTextField.delegate = self;
    [nameTextField setKeyboardType:UIKeyboardTypeDefault];
    nameTextField.text = [vCardInfo objectForKey:@"name"];
    [self.view bringSubviewToFront:nameTextField];

    [self.view bringSubviewToFront:lineImageview];
    
    companyTextField.delegate = self;
    [companyTextField setKeyboardType:UIKeyboardTypeDefault];
    companyTextField.text = [vCardInfo objectForKey:@"company"];
    
    
    titleTextField.delegate = self;
    [titleTextField setKeyboardType:UIKeyboardTypeDefault];
    titleTextField.text = [vCardInfo objectForKey:@"title"];
    
    companyPhoneTextField.delegate = self;
    [companyPhoneTextField setKeyboardType:UIKeyboardTypeNumberPad];
    companyPhoneTextField.text = [vCardInfo objectForKey:@"companyPhone"];
    
    addressTextField.delegate = self;
    [addressTextField setKeyboardType:UIKeyboardTypeDefault];
    addressTextField.text = [vCardInfo objectForKey:@"address"];
    
    phoneTextField.delegate = self;
    [phoneTextField setKeyboardType:UIKeyboardTypeNumberPad];
    phoneTextField.text = [vCardInfo objectForKey:@"phone1"];
    phoneTextField.returnKeyType = UIReturnKeyNext;
    
    phone2TextField.delegate = self;
    [phone2TextField setKeyboardType:UIKeyboardTypeNumberPad];
    phone2TextField.text = [vCardInfo objectForKey:@"phone2"];
    
    emailTextField.delegate = self;
    [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    emailTextField.text = [vCardInfo objectForKey:@"email1"];
    
    email2TextField.delegate = self;
    [email2TextField setKeyboardType:UIKeyboardTypeEmailAddress];
    email2TextField.text = [vCardInfo objectForKey:@"email2"];
    
    webTextField.delegate = self;
    [webTextField setKeyboardType:UIKeyboardTypeDefault];
    webTextField.text = [vCardInfo objectForKey:@"web"];
    
    skypeTextField.delegate = self;
    [skypeTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    skypeTextField.text = [vCardInfo objectForKey:@"skype"];
    
    QQTextField.delegate = self;
    [QQTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    QQTextField.text = [vCardInfo objectForKey:@"QQ"];
    
    noteTextView.delegate = self;
    [noteTextView setKeyboardType:UIKeyboardTypeDefault];
    noteTextView.text = [vCardInfo objectForKey:@"note"];
    
    [vCardLoadButton setImage:[UIImage imageNamed:@"upload02"] forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:vCardLoadButton];
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

- (void)setData{
    [vCardInfo setValue:nameTextField.text forKey:@"name"];
    [vCardInfo setValue:companyTextField.text forKey:@"company"];
    [vCardInfo setValue:titleTextField.text forKey:@"title"];
    [vCardInfo setValue:companyPhoneTextField.text forKey:@"companyPhone"];
    [vCardInfo setValue:addressTextField.text forKey:@"address"];
    [vCardInfo setValue:phoneTextField.text forKey:@"phone1"];
    [vCardInfo setValue:phone2TextField.text forKey:@"phone2"];
    [vCardInfo setValue:emailTextField.text forKey:@"email1"];
    [vCardInfo setValue:email2TextField.text forKey:@"email2"];
    [vCardInfo setValue:webTextField.text forKey:@"web"];
    [vCardInfo setValue:skypeTextField.text forKey:@"skype"];
    [vCardInfo setValue:QQTextField.text forKey:@"QQ"];
    [vCardInfo setValue:noteTextView.text forKey:@"note"];
    
    [userDefaults setObject:vCardInfo forKey:@"vCard"];
}


#pragma mark text field and text view delegate
//tap輸入框以外的地方就收起鍵盤
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nameTextField resignFirstResponder];
    [companyTextField resignFirstResponder];
    [titleTextField resignFirstResponder];
    [companyPhoneTextField resignFirstResponder];
    [addressTextField resignFirstResponder];
    [phoneTextField resignFirstResponder];
    [phone2TextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [email2TextField resignFirstResponder];
    [webTextField resignFirstResponder];
    [skypeTextField resignFirstResponder];
    [QQTextField resignFirstResponder];
    [noteTextView resignFirstResponder];
}

//輸入開始時配合鍵盤高度把view往上移
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
        animatedDistanceV = floor(216 * heightFraction);
    }
    else
    {
        animatedDistanceV = floor(162 * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistanceV;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

//輸入完畢後把view移回原位
- (void)textFieldDidEndEditing:(UITextField *)textfield{
    [self setData];
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistanceV;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

//因為有note是用textview所以移動view部分要分開寫
- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
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
        animatedDistanceV = floor(216 * heightFraction);
    }
    else
    {
        animatedDistanceV = floor(162 * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistanceV;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistanceV;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

//編輯完畢收起鍵盤
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//編輯完畢收起鍵盤
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark vCard button actions
- (IBAction)vCardBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadToBandVCard:(id)sender {
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"connect"] isEqualToString:@"y"]){
        NSLog(@"connect y send data");
        [self sendData];
    }else{
        NSLog(@"connect n");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(udfHandle)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
        [self showConnectStateAlert:2 info:nil];
    }
}

#pragma mark handle connect state
- (void) udfHandle{
    NSLog(@"udfHandle");
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
        
        [self showConnectStateAlert:2 info:nil];
        
    }else if([str isEqualToString:@"t"]){
        NSLog(@"connect state : timeout");
        
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
    }
}

- (void)uploadSuccess{
    NSLog(@"uploadSuccess");

    [self showConnectStateAlert:3 info:@"Upload success"];
}

- (void)connectErrorButtonPressed:(UIButton *)button{
    if(button.tag == 0){
        NSLog(@"try");
        ScanViewController *scanV = [[ScanViewController alloc] init];
        [scanV autoConnectTag];

        [self showConnectStateAlert:0 info:nil];
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
    if(alertViewVcard != nil){
        [alertViewVcard removeFromSuperview];
        alertViewVcard = nil;
    }
}

#pragma mark BTSmartSensorDelegate
- (void)sendData{
    NSLog(@"sendData");
    nfcindex = 4;
    count = 0;
    [StringArray removeAllObjects];
    
    
    NSString *Name = @"",*Company= @"", *Job= @"", *TelC= @"", *CompanyAddress= @"", *Tel1= @"", *Tel2= @"",*Email= @"", *Email2= @"", *Web= @"", *Skype= @"", *QQ= @"", *Note= @"";
    if([nameTextField text].length!=0){
        Name = [NSString stringWithFormat:@"FN:%@\n",[nameTextField text]];
    }
    if([companyTextField text].length!=0){
        Company = [NSString stringWithFormat:@"ORG:%@\n",[companyTextField text]];
    }
    if([titleTextField text].length!=0){
        Job = [NSString stringWithFormat:@"TITLE:%@\n",[titleTextField text]];
    }
    if([companyPhoneTextField text].length!=0){
        TelC = [NSString stringWithFormat:@"TEL;WORK:%@\n",[companyPhoneTextField text]];
    }
    if([addressTextField text].length!=0){
        CompanyAddress = [NSString stringWithFormat:@"ADR;WORK:%@\n",[addressTextField text]];
    }
    if([phoneTextField text].length!=0){
        Tel1 = [NSString stringWithFormat:@"TEL;CELL:%@\n",[phoneTextField text]];
    }
    if([phone2TextField text].length!=0){
        Tel2 = [NSString stringWithFormat:@"TEL;CELL:%@\n",[phone2TextField text]];
    }
    if([emailTextField text].length!=0){
        Email = [NSString stringWithFormat:@"EMAIL;WORK:%@\n",[emailTextField text]];
    }
    if([email2TextField text].length!=0){
        Email2 = [NSString stringWithFormat:@"EMAIL;HOME:%@\n",[email2TextField text]];
    }
    if([webTextField text].length!=0){
        Web = [NSString stringWithFormat:@"URL:%@\n",[webTextField text]];
    }
    
    if([skypeTextField text].length!=0){
        Skype = [NSString stringWithFormat:@"X-QQ:%@\n",[skypeTextField text]];
    }
    if([QQTextField text].length!=0){
        QQ = [NSString stringWithFormat:@"X-SKYPE-USERNAME:%@\n",[QQTextField text]];
    }
    if([noteTextView text].length!=0){
        Note = [NSString stringWithFormat:@"NOTE:%@\n",[noteTextView text]];
    }
    
    
    NSString *strMsgData = [NSString stringWithFormat:@"BEGIN:VCARD\nVERSION:2.1\n%@%@%@%@%@%@%@%@%@%@%@%@%@END:VCARD\r\n",
                            Name,Company,Job,TelC,CompanyAddress,Tel1,Tel2,Email,Email2,Web,Skype,QQ,Note];
    NSLog(@"VCard : %@", strMsgData);
    NSString *type = [self stringToHex:@"text/x-vCard"];
    NSLog(@"Vcard \n%@", [self stringToHex:strMsgData]);
    strMsgData = [self stringToHex:strMsgData];
    NSString *dec;
    NSString *hexlength1;
    NSString *hexlength2;
    
    int temp_cont = (int)strMsgData.length/2+15;
    
    if(temp_cont <256){
        hexlength1 = [self IntToHex:temp_cont];
        hexlength2 = [self IntToHex:temp_cont-15];
        strMsgData = [NSString stringWithFormat:@"03%@D20C%@%@%@FE",hexlength1, hexlength2, type, strMsgData];
    }else  if(temp_cont >=256 && temp_cont <273){
        hexlength1 = [self IntToHex:temp_cont];
        hexlength2 = [self IntToHex:temp_cont-15];
        strMsgData = [NSString stringWithFormat:@"03FF%@D20C%@%@%@FE",hexlength1, hexlength2, type, strMsgData];
    }else{
        hexlength1 = [self IntToHex:temp_cont+3];
        hexlength2 = [self IntToHex:temp_cont-15];
        strMsgData = [NSString stringWithFormat:@"03FF%@C20C0000%@%@%@FE",hexlength1, hexlength2, type, strMsgData];
    }
    
    dec = @"";
    
    for(int i=0; i<fmod(strMsgData.length, 32) ;i++){
        strMsgData=[NSString stringWithFormat:@"%@0",strMsgData];
    }
    
    count = 0;
    
    for (int i = 0; i < strMsgData.length; i = i + 32) {
        [StringArray addObject:[strMsgData substringWithRange:NSMakeRange(i,32)]];
    }
    
    NSString *index = [NSString stringWithFormat:@"%X",nfcindex];
    if(index.length == 1)
        index = [NSString stringWithFormat:@"0%@",index];
    NSString * text = [NSString stringWithFormat:@"0222%@%@",index, [StringArray objectAtIndex:count]];
    [sensor SendData:text];
}

//取得資料整理
-(void) serialGATTCharValueUpdated:(NSData *)data
{
    NSString *value = [self NSDataToHex:data];
    if([value isEqualToString:@"010d0c"]){
        count++;
        if (count < StringArray.count)
        {
            nfcindex = nfcindex+4;
            NSString *index = [NSString stringWithFormat:@"%X",nfcindex];
            if(index.length == 1) index = [NSString stringWithFormat:@"0%@",index];
            NSString * text = [NSString stringWithFormat:@"0222%@%@",index, [StringArray objectAtIndex:count]];
            sleep(0.1);
            [sensor SendData:text];
        } else if (count == StringArray.count)
        {
            NSLog(@"send 1");
            [sensor EndData];// 結束
            //[self showOkayCancelAlert:@"發送結束"];
            
            [self uploadSuccess];
            
            [StringArray removeAllObjects];
        } else if(StringArray.count==0 && count==1)
        {
            NSLog(@"send 2");
            [sensor EndData];// 結束
            //[self showOkayCancelAlert:@"發送結束"];
            
            [self uploadSuccess];
            
        }
    } if([value isEqualToString:@"010e0f"]){
        if (count < StringArray.count){
            NSString *index = [NSString stringWithFormat:@"%X",nfcindex];
            if(index.length == 1) index = [NSString stringWithFormat:@"0%@",index];
            NSString * text = [NSString stringWithFormat:@"0222%@%@",index, [StringArray objectAtIndex:count]];
            sleep(0.1);
            [sensor SendData:text];
        } else if (count == StringArray.count) {
            NSLog(@"send 3");
            [sensor EndData];// 結束
            //[self showOkayCancelAlert:@"發送結束"];
            
            [self uploadSuccess];
        }
    }
    NSLog(@"door     %@   %d",value, count);
}

//連線成功
-(void)setConnect
{
    NSLog(@"VCARD : OK+CONN");
    [[NSUserDefaults standardUserDefaults] setObject:@"y" forKey:@"connect"];
    //[self showOkayCancelAlert:@"iTag connected\niTag連線成功"];
}


//斷線
-(void)setDisconnect
{
    NSLog(@"VCARD : OK+LOST");
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

- (NSString *) hexDataToString:(UInt8 *)data
                        Length:(int)len
{
    NSString *tmp = @"";
    NSString *str = @"";
    for(int i = 0; i < len; ++i)
    {
        tmp = [NSString stringWithFormat:@"%02X",data[i]];
        str = [str stringByAppendingString:tmp];
    }
    
    return str;
}

- (NSString *) stringToHex:(NSString *)str
{
    NSString * hexStr = [NSString stringWithFormat:@"%@",
                         [NSData dataWithBytes:[str cStringUsingEncoding:NSUTF8StringEncoding]
                                        length:strlen([str cStringUsingEncoding:NSUTF8StringEncoding])]];
    
    for(NSString * toRemove in [NSArray arrayWithObjects:@"<", @">", @" ", nil])
        hexStr = [hexStr stringByReplacingOccurrencesOfString:toRemove withString:@""];
    return hexStr;
}


-(NSString *)IntToHex:(int)num {
    NSString *data = [NSString stringWithFormat:@"%X",num];
    NSLog(@"num  %@   %d",data,num);
    if(data.length==1 || data.length==3){
        data = [NSString stringWithFormat:@"0%@",data];
    }else{
        data = [data substringWithRange:NSMakeRange((data.length-2),2)];
    }
    return data;
}

#pragma mark - alert
- (void)showConnectStateAlert:(int)state info:(NSString *)info{
    [alertViewVcard removeFromSuperview];
    alertViewVcard = nil;
    switch (state) {
        case 0:
            //connecting
            alertViewVcard = [alertVCVCard alertConnecting];
            break;
        case 1:{
            //connect success
            alertViewVcard = [alertVCVCard alertConnectSuccess];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
            [alertViewVcard addGestureRecognizer:tap];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
        }
            break;
        case 2:{
            //connect failed
            alertViewVcard = [alertVCVCard alertConnectError];
            
            UIButton *tryButton = [alertVCVCard getTryBurtton];
            [tryButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *cancelButton = [alertVCVCard getCancelButton];
            [cancelButton addTarget:self action:@selector(connectErrorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [alertViewVcard addSubview:tryButton];
            [alertViewVcard addSubview:cancelButton];
        }
            break;
        case 3:{
            //custom alert
            alertViewVcard = [alertVCVCard alertCustom:info];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
            [alertViewVcard addGestureRecognizer:tap];
        }
            break;
        default:
            break;
    }
    [self.view addSubview:alertViewVcard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
