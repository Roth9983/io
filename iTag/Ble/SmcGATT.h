//
//  SerialGATT.h
//  HMSoft
//
//  Created by HMSofts on 7/13/12.
//  Copyright (c) 2012 jnhuamao.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleController.h"

@protocol BTSmartSensorDelegate

@optional
- (void) peripheralFound:(CBPeripheral *)peripheral rssi:(NSNumber *)rssi;
- (void) serialGATTCharValueUpdated: (NSData *)data;
- (void) setConnect;
- (void) setDisconnect;
@end

@class BleController;
@interface SmcGATT : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate> {
    BleController *shareBERController;
}

@property (nonatomic, assign) id <BTSmartSensorDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBService *cService;

#pragma mark - Methods for controlling the HMSoft Sensor
-(void) setup; //controller setup
-(void) stopScan;

-(int) findHMSoftPeripherals:(int)timeout;
-(void) scanTimer: (NSTimer *)timer;

-(void) connect: (CBPeripheral *)peripheral;
- (void)myConnect:(NSString *)identifier;
-(void) disconnect: (CBPeripheral *)peripheral;

-(void) SendLED:(NSString *)text;
-(void) SendData:(NSString *)text;
-(void) EndData;
-(void) SendBuzzer:(BOOL *) on ontime:(int)a offtime:(int)b count:(int)c;

-(NSString *)DoCheckSum:(NSString *)string;

@end
