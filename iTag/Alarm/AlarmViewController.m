//
//  AlarmViewController.m
//  SmartBand
//
//  Created by Jason Tsai on 2015/9/3.
//  Copyright (c) 2015年 朱若慈. All rights reserved.
//
// output action :
// - (IBAction)loadAlarm:(id)sender;
//
// output data :
// an array with dictionary save in
// [[NSUserDefaults standardUserDefaults] objectForKeys:alarms];
//    keys :
//      select : the alarm is select or not
//      title : alarm's title
//      time : alarm's time
//      dura : 貪睡 or 提早
//      mon, tue, wed, thr, fri, sat, sun : show week days is select or not
//
// a dictionary save in
// [[NSUserDefaults standardUserDefaults] objectForKeys:counter];
//    keys :
//      counterSelect : counter is select or not
//      countdown : count down duration

#import "AlarmViewController.h"

@interface AlarmViewController ()

@end

@implementation AlarmViewController
@synthesize alarmTableView;
@synthesize heightOfTableView;
@synthesize alarmInfo;
@synthesize arrayOfAlarms;
@synthesize addCounterButton;
@synthesize counterTextField;
@synthesize counterInfo;

NSUserDefaults *userDftAlarm;

UIView *backgroundView;
UIView *view;
UITextField *titleTextField;
UIDatePicker *datePicker;
UITextField *timeTextField;
UIButton *mon, *tue, *wed, *thr, *fri, *sat, *sun;
UIButton *beforeSelect, *delaySelect;
UILabel *before;
UILabel *delay;

UIView *bgView;
UIView *lpView;

UIButton *loadToBandAlarm;
NSString *trueString = @"t";
NSString *falseString = @"f";
NSString *beforeStr, *delayStr;
UIImage *selectYes, *selectNo;

UITapGestureRecognizer *tapToDismiss, *tapToModify;
UILongPressGestureRecognizer *longPress;

UIDatePicker *counterPicker;

bool isMon, isTue, isWed, isThr, isFri, isSat, isSun;
float w, h;
bool isDelete = false;
bool isEdit = false;
int editIndex;
bool isCounter;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    userDftAlarm = [NSUserDefaults standardUserDefaults];
    
    w = [[UIScreen mainScreen] bounds].size.width;
    h = [[UIScreen mainScreen] bounds].size.height;
    
    [self loadData];
    
    selectNo = [UIImage imageNamed:@"select_no.png"];
    selectYes = [UIImage imageNamed:@"select_yes.png"];
    
    alarmTableView.delegate = self;
    alarmTableView.dataSource = self;
    
    if(w<=320){
        beforeStr = @"提早";
        delayStr = @"貪睡";
    }else{
        beforeStr = @"提早喚醒";
        delayStr = @"貪睡時間";
    }
    
    tapToModify = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToModifyAlarm)];
    tapToModify.delegate = self;
    
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    
    [alarmTableView addGestureRecognizer:tapToModify];
    [alarmTableView addGestureRecognizer:longPress];
    
    [self setCounter];
    
}

- (IBAction)loadAlarm:(id)sender {
    NSArray *alarms = [userDftAlarm arrayForKey:@"alarms"];
    NSDictionary *counter = [userDftAlarm dictionaryForKey:@"counter"];
}

- (void)setCounter{
    counterPicker = [[UIDatePicker alloc] init];
    counterPicker.datePickerMode = UIDatePickerModeCountDownTimer;
    
    if([userDftAlarm objectForKey:@"counter"]){
        counterInfo = [[NSMutableDictionary alloc] initWithDictionary:[userDftAlarm objectForKey:@"counter"]];
        counterTextField.text = [counterInfo valueForKey:@"countdown"];
        if([[counterInfo valueForKey:@"counterSelect"] isEqualToString:falseString]){
            [addCounterButton setImage:selectNo forState:UIControlStateNormal];
        }else{
            [addCounterButton setImage:selectYes forState:UIControlStateNormal];
        }
    }else{
        counterTextField.text = @"00:00:00";
        counterInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        [counterInfo setValue:counterTextField.text forKey:@"countdown"];
        [counterInfo setValue:falseString forKey:@"counterSelect"];
        [userDftAlarm setObject:counterInfo forKey:@"counter"];
    }
    counterTextField.delegate = self;
    counterTextField.inputView = counterPicker;
    
    UIToolbar *counterToolBar = [[UIToolbar alloc] init];
    [counterToolBar sizeToFit];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(counterDone)];
    counterToolBar.items = [NSArray arrayWithObjects:right, nil];
    counterToolBar.backgroundColor = [UIColor blackColor];
    counterTextField.inputAccessoryView = counterToolBar;
}

- (void)counterDone{
    if ([self.view endEditing:NO]) {
        int tmp;
        int sec = fmod(counterPicker.countDownDuration, 60);
        tmp = counterPicker.countDownDuration/60;
        int min = fmod(tmp, 60);
        tmp = tmp/60;
        int hr = tmp;
        
        counterTextField.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hr, min, sec];
        [counterInfo setValue:counterTextField.text forKey:@"countdown"];
        [userDftAlarm setObject:counterInfo forKey:@"counter"];
    }
}

- (void)handleTapToModifyAlarm{
    isEdit = true;
    editIndex = (int)[self getRecognizerPosition:tapToModify].row;
    alarmInfo = [[NSMutableDictionary alloc] initWithDictionary:[arrayOfAlarms objectAtIndex:editIndex]];
    [self detailOfAlarm];
}

- (void)handleLongPress{
    if(!isDelete){
        isDelete = true;
        
        UITapGestureRecognizer *lpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLPTap)];
        lpTap.delegate = self;
        
        bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.4;
        [bgView addGestureRecognizer:lpTap];
        [self.view addSubview:bgView];
    
        lpView = [[UIView alloc] initWithFrame:CGRectMake(w/2-150, h/2-50, 300, 100)];
        lpView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:lpView];
    
        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        [editButton setTitle:@"編輯震動鬧鈴" forState:UIControlStateNormal];
        [editButton setTintColor:[UIColor whiteColor]];
        [editButton addTarget:self
                       action:@selector(editAlarm)
             forControlEvents:UIControlEventTouchUpInside];
        [lpView addSubview:editButton];
    
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 300, 50)];
        [deleteButton setTitle:@"刪除震動鬧鈴" forState:UIControlStateNormal];
        [deleteButton setTintColor:[UIColor whiteColor]];
        [deleteButton addTarget:self
                         action:@selector(deleteAlarm)
               forControlEvents:UIControlEventTouchUpInside];
        [lpView addSubview:deleteButton];
    }
}

- (void)handleLPTap{
    [lpView removeFromSuperview];
    [bgView removeFromSuperview];
}

- (void)editAlarm{
    isEdit = true;
    editIndex = (int)[self getRecognizerPosition:longPress].row;
    alarmInfo = [[NSMutableDictionary alloc] initWithDictionary:[arrayOfAlarms objectAtIndex:editIndex]];
    [self detailOfAlarm];
}

- (void)deleteAlarm{
    isDelete = false;
    [lpView removeFromSuperview];
    [bgView removeFromSuperview];
    alarmInfo = [[NSMutableDictionary alloc] initWithDictionary:[arrayOfAlarms objectAtIndex:[self getRecognizerPosition:longPress].row]];
    [arrayOfAlarms removeObjectAtIndex:[self getRecognizerPosition:longPress].row];
    [userDftAlarm setObject:arrayOfAlarms forKey:@"alarms"];
    [self loadData];
    [alarmTableView reloadData];
    
}

- (NSIndexPath *)getRecognizerPosition:(UIGestureRecognizer *)recognizer{
    CGPoint p = [recognizer locationInView:alarmTableView];
    
    NSIndexPath *indexPath = [alarmTableView indexPathForRowAtPoint:p];
    
    return indexPath;
}

- (void)loadData{
    //[userDftAlarm removeObjectForKey:@"alarms"];
    if([userDftAlarm objectForKey:@"alarms"]){
        arrayOfAlarms = [[NSMutableArray alloc] initWithArray:[userDftAlarm arrayForKey:@"alarms"]];
    }else{
        arrayOfAlarms = [[NSMutableArray alloc] init];
    }
    
    [self adjustHeightOfTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayOfAlarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmTableViewCell *cell = (AlarmTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ACell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AlarmTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *dic = [arrayOfAlarms objectAtIndex:indexPath.row];

    cell.titleLabel.text = [dic valueForKey:@"title"];
    
    if([[dic valueForKey:@"select"] isEqualToString:trueString]){
        [cell.checkboxButton setImage:selectYes forState:UIControlStateNormal];
    }else{
        [cell.checkboxButton setImage:selectNo forState:UIControlStateNormal];
    }
    cell.checkboxButton.tag = indexPath.row;
    
    cell.timeLabel.text = [dic valueForKey:@"time"];
    
    cell.durationLabel.text = [dic valueForKey:@"dura"];
    
    if([[dic valueForKey:@"mon"] isEqualToString:trueString]){
        cell.monLabel.textColor = [UIColor blackColor];
    }else{
        cell.monLabel.textColor = [UIColor grayColor];
    }
    if([[dic valueForKey:@"tue"] isEqualToString:trueString]){
        cell.tueLabel.textColor = [UIColor blackColor];
    }else{
        cell.tueLabel.textColor = [UIColor grayColor];
    }
    if([[dic valueForKey:@"wed"] isEqualToString:trueString]){
        cell.wedLabel.textColor = [UIColor blackColor];
    }else{
        cell.wedLabel.textColor = [UIColor grayColor];
    }
    if([[dic valueForKey:@"thr"] isEqualToString:trueString]){
        cell.thrLabel.textColor = [UIColor blackColor];
    }else{
        cell.thrLabel.textColor = [UIColor grayColor];
    }
    if([[dic valueForKey:@"fri"] isEqualToString:trueString]){
        cell.friLabel.textColor = [UIColor blackColor];
    }else{
        cell.friLabel.textColor = [UIColor grayColor];
    }
    if([[dic valueForKey:@"sat"] isEqualToString:trueString]){
        cell.satLabel.textColor = [UIColor blackColor];
    }else{
        cell.satLabel.textColor = [UIColor grayColor];
    }
    if([[dic valueForKey:@"sun"] isEqualToString:trueString]){
        cell.sunLabel.textColor = [UIColor blackColor];
    }else{
        cell.sunLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

- (void)adjustHeightOfTableView{
    [UIView animateWithDuration:0.25 animations:^{
        self.heightOfTableView.constant = 80 * (arrayOfAlarms.count);
        [self.view setNeedsUpdateConstraints];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)alarmBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addAlarm:(id)sender {
    if(arrayOfAlarms.count <=3){
        alarmInfo = [[NSMutableDictionary alloc] initWithCapacity:11];
        [self detailOfAlarm];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"最多四個鬧鈴"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)addCounter:(id)sender {
    if([[counterInfo valueForKey:@"counterSelect"] isEqualToString:falseString]){
        [counterInfo setValue:trueString forKey:@"counterSelect"];
        [addCounterButton setImage:selectYes forState:UIControlStateNormal];
    }else{
        [counterInfo setValue:falseString forKey:@"counterSelect"];
        [addCounterButton setImage:selectNo forState:UIControlStateNormal];
    }
    [userDftAlarm setObject:counterInfo forKey:@"counter"];
}

- (void)detailOfAlarm{
    
    tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeDetailOfAlarmView)];
    tapToDismiss.delegate = self;
    
    backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.6;
    [backgroundView addGestureRecognizer:tapToDismiss];
    [self.view addSubview:backgroundView];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(w/2 - 150, h/2 - 150, 300, 300)];
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 1;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview:view];
    
    titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(w/2-140, h/2-150+8, 280, 40)];
    if([alarmInfo valueForKey:@"title"] == nil){
        titleTextField.placeholder = @"請輸入文字";
    }else{
        titleTextField.text = [alarmInfo valueForKey:@"title"];
    }
    titleTextField.textAlignment = NSTextAlignmentCenter;
    titleTextField.backgroundColor = [UIColor grayColor];
    titleTextField.delegate = self;
    [self.view addSubview:titleTextField];
    
    datePicker = [[UIDatePicker alloc] init];
    CGRect frame = CGRectMake(0, 48, 300, 216);
    [datePicker setFrame:frame];
    datePicker.datePickerMode = UIDatePickerModeTime;
    
    timeTextField = [[UITextField alloc] initWithFrame:CGRectMake(w/2-140, h/2-150+56, 280, 40)];
    timeTextField.tag = 1;
    if([alarmInfo valueForKey:@"time"] == nil){
        timeTextField.text = @"上午  00:00";
    }else{
        timeTextField.text = [alarmInfo valueForKey:@"time"];
    }
    timeTextField.backgroundColor = [UIColor whiteColor];
    timeTextField.textAlignment = NSTextAlignmentCenter;
    timeTextField.delegate = self;
    timeTextField.inputView = datePicker;
    [self.view addSubview:timeTextField];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputTime:)];
    toolBar.items = [NSArray arrayWithObjects:right, nil];
    timeTextField.inputAccessoryView = toolBar;
    
    mon = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120, h/2-150+104, 30, 30)];
    [mon setTitle:@"一" forState:UIControlStateNormal];
    [mon addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mon];
    
    tue = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120+35, h/2-150+104, 30, 30)];
    [tue setTitle:@"二" forState:UIControlStateNormal];
    [tue addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tue];
    
    wed = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120+70, h/2-150+104, 30, 30)];
    [wed setTitle:@"三" forState:UIControlStateNormal];
    [wed addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wed];
    
    thr = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120+105, h/2-150+104, 30, 30)];
    [thr setTitle:@"四" forState:UIControlStateNormal];
    [thr setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [thr addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:thr];
    
    fri = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120+140, h/2-150+104, 30, 30)];
    [fri setTitle:@"五" forState:UIControlStateNormal];
    [fri addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fri];
    
    sat = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120+175, h/2-150+104, 30, 30)];
    [sat setTitle:@"六" forState:UIControlStateNormal];
    [sat addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sat];
    
    sun = [[UIButton alloc] initWithFrame:CGRectMake(w/2-120+210, h/2-150+104, 30, 30)];
    [sun setTitle:@"日" forState:UIControlStateNormal];
    [sun setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sun addTarget:self action:@selector(setAlarmDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sun];
    
    if([alarmInfo valueForKey:@"mon"] == nil){
        isMon = false;
        [mon setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"mon"] isEqualToString:trueString]){
            isMon = true;
            [mon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isMon = false;
            [mon setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if([alarmInfo valueForKey:@"tue"] == nil){
        isTue = false;
        [tue setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"tue"] isEqualToString:trueString]){
            isTue = true;
            [tue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isTue = false;
            [tue setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if([alarmInfo valueForKey:@"wed"] == nil){
        isWed = false;
        [wed setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"wed"] isEqualToString:trueString]){
            isWed = true;
            [wed setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isWed = false;
            [wed setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if([alarmInfo valueForKey:@"thr"] == nil){
        isThr = false;
        [thr setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"thr"] isEqualToString:trueString]){
            isThr = true;
            [thr setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isThr = false;
            [thr setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if([alarmInfo valueForKey:@"fri"] == nil){
        isFri = false;
        [fri setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"fri"] isEqualToString:trueString]){
            isFri = true;
            [fri setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isFri = false;
            [fri setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if([alarmInfo valueForKey:@"sat"] == nil){
        isSat = false;
        [sat setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"sat"] isEqualToString:trueString]){
            isSat = true;
            [sat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isSat = false;
            [sat setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if([alarmInfo valueForKey:@"sun"] == nil){
        isSun = false;
        [sun setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        if([[alarmInfo valueForKey:@"sun"] isEqualToString:trueString]){
            isSun = true;
            [sun setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            isSun = false;
            [sun setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    
    before = [[UILabel alloc] initWithFrame:CGRectMake(w/2-100, h/2-150+142, 160, 40)];
    before.text = @"提早喚醒 10 分鐘";
    before.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:before];
    
    beforeSelect = [[UIButton alloc] initWithFrame:CGRectMake(w/2-100+160, h/2-150+142, 40, 40)];
    if([alarmInfo valueForKey:@"dura"] == nil || [[alarmInfo valueForKey:@"dura"] isEqualToString:beforeStr]){
        [beforeSelect setImage:[UIImage imageNamed:@"select_yes.png"] forState:UIControlStateNormal];
    }else{
        [beforeSelect setImage:[UIImage imageNamed:@"select_no.png"] forState:UIControlStateNormal];
    }
    [beforeSelect addTarget:self action:@selector(timeDuration:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beforeSelect];
    
    delay = [[UILabel alloc] initWithFrame:CGRectMake(w/2-100, h/2-150+190, 160, 40)];
    delay.text = @"貪睡時間   5 分鐘";
    delay.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:delay];
    
    delaySelect = [[UIButton alloc] initWithFrame:CGRectMake(w/2-100+160, h/2-150+190, 40, 40)];
    if([alarmInfo valueForKey:@"dura"] == nil || [[alarmInfo valueForKey:@"dura"] isEqualToString:beforeStr]){
        [delaySelect setImage:[UIImage imageNamed:@"select_no.png"] forState:UIControlStateNormal];
    }else{
        [delaySelect setImage:[UIImage imageNamed:@"select_yes.png"] forState:UIControlStateNormal];
    }
    [delaySelect addTarget:self action:@selector(timeDuration:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delaySelect];
    
    loadToBandAlarm = [[UIButton alloc] initWithFrame:CGRectMake(w/2-140, h/2-150+238, 280, 40)];
    [loadToBandAlarm setBackgroundImage:[UIImage imageNamed:@"button_1_1.png"] forState:UIControlStateNormal];
    [loadToBandAlarm setTitle:@"完成" forState:UIControlStateNormal];
    [loadToBandAlarm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loadToBandAlarm addTarget:self action:@selector(finishAlarm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadToBandAlarm];
    
}

- (void)removeDetailOfAlarmView{
    [backgroundView removeFromSuperview];
    [view removeFromSuperview];
    [titleTextField removeFromSuperview];
    [timeTextField removeFromSuperview];
    [mon removeFromSuperview];
    [tue removeFromSuperview];
    [wed removeFromSuperview];
    [thr removeFromSuperview];
    [fri removeFromSuperview];
    [sat removeFromSuperview];
    [sun removeFromSuperview];
    [before removeFromSuperview];
    [beforeSelect removeFromSuperview];
    [delay removeFromSuperview];
    [delaySelect removeFromSuperview];
    [loadToBandAlarm removeFromSuperview];
}

- (void)finishAlarm:(UIButton *)button{
    if(isEdit){
        //NSLog(@"isedit");
        isEdit = false;
        [alarmInfo setValue:titleTextField.text forKey:@"title"];
        [arrayOfAlarms replaceObjectAtIndex:editIndex withObject:alarmInfo];
    }else{
        //NSLog(@"! isedit");
        [alarmInfo setValue:titleTextField.text forKey:@"title"];
        if([alarmInfo valueForKey:@"time"] == NULL){
            [alarmInfo setValue:@"上午  00:00" forKey:@"time"];
        }
        if([alarmInfo valueForKey:@"dura"] == NULL){
            [alarmInfo setValue:beforeStr forKey:@"dura"];
        }
        [alarmInfo setValue:falseString forKey:@"select"];
    
        [arrayOfAlarms addObject:alarmInfo];
    }
    
    [userDftAlarm setObject:arrayOfAlarms forKey:@"alarms"];
    
    [self removeDetailOfAlarmView];
    
    [self loadData];
    [alarmTableView reloadData];
}

- (void)timeDuration:(UIButton *)button{
    if(button == beforeSelect){
        [beforeSelect setImage:[UIImage imageNamed:@"select_yes.png"] forState:UIControlStateNormal];
        [delaySelect setImage:[UIImage imageNamed:@"select_no.png"] forState:UIControlStateNormal];
        [alarmInfo setValue:beforeStr forKey:@"dura"];
    }else if(button == delaySelect){
        [beforeSelect setImage:[UIImage imageNamed:@"select_no.png"] forState:UIControlStateNormal];
        [delaySelect setImage:[UIImage imageNamed:@"select_yes.png"] forState:UIControlStateNormal];
        [alarmInfo setValue:delayStr forKey:@"dura"];
    }
}

- (void)setAlarmDay:(UIButton *)button{
    if(button == mon){
        if(!isMon){
            isMon = true;
            [mon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"mon"];
        }else{
            isMon = false;
            [mon setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"mon"];
        }
    }
    else if(button == tue){
        if(!isTue){
            isTue = true;
            [tue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"tue"];
        }else{
            isTue = false;
            [tue setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"tue"];
        }
    }
    else if(button == wed){
        if(!isWed){
            isWed = true;
            [wed setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"wed"];
        }else{
            isWed = false;
            [wed setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"wed"];
        }
    }
    else if(button == thr){
        if(!isThr){
            isThr = true;
            [thr setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"thr"];
        }else{
            isThr = false;
            [thr setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"thr"];
        }
    }
    else if(button == fri){
        if(!isFri){
            isFri = true;
            [fri setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"fri"];
        }else{
            isFri = false;
            [fri setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"fri"];
        }
    }
    else if(button == sat){
        if(!isSat){
            isSat = true;
            [sat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"sat"];
        }else{
            isSat = false;
            [sat setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"sat"];
        }
    }
    else if(button == sun){
        if(!isSun){
            isSun = true;
            [sun setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alarmInfo setValue:trueString forKey:@"sun"];
        }else{
            isSun = false;
            [sun setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [alarmInfo setValue:falseString forKey:@"sun"];
        }
    }
}

- (void)inputTime:(UITextField *)textField{
    if ([self.view endEditing:NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"aa  hh:mm"];
        timeTextField.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
        [alarmInfo setValue:timeTextField.text forKey:@"time"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
