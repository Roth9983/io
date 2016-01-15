

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SmcGATT.h"

@class CBPeripheral;
@class SmcGATT;

@interface BleController : NSObject
{
//    CBCentralManager *CM;
    SmcGATT *sensor;
}

+ (BleController *)sharedController;
- (void)setupControllerForManager:(CBCentralManager *)manager withPeripheral:(CBPeripheral *)peripheral;
- (void)setupControllerForSmcGATT:(SmcGATT *)gatt;

-(void) init_iTag;
-(void) SendLED:(int)rr G:(int)gg B:(int)bb ontime:(int) ontime offtime:(int) offtime count:(int) count LED:(BOOL *) on;
-(void) Send_NFC_Data:(NSString *)text;
-(void) NFC_End_Data;
-(void) SendBuzzer:(BOOL *) on ontime:(int) ontime offtime:(int) offtime count:(int) count;

@property (nonatomic, readonly) CBCentralManager *CM;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) SmcGATT *sensor;
@property (strong, nonatomic) NSNumber *rssi;

@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (strong, nonatomic) CBService *service;


@end


