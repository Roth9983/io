//
//  SerialGATT.m
//  HMSoft
//
//  Created by HMSofts on 7/13/12.
//  Copyright (c) 2012 jnhuamao.cn. All rights reserved.
//

#import "SmcGATT.h"

#define uuid_jble_Service @"edfec62e-9910-0bac-5241-d8bda6932a2f"
#define uuid_jble_ControlService @"2d86686a-53dc-25b3-0c4a-f0e10c8dee20"
#define uuid_jble_ControlNotification @"00002901-0000-1000-8000-00805f9b34fb"
#define uuid_jble_ButtonService @"6c290d2e-1c03-aca1-ab48-a9b908bae79e"
#define uuid_jble_LedService @"5a87b4ef-3bfa-76a8-e642-92933c31434f"
#define uuid_jble_AdcService @"15005991-b131-3396-014c-664c9867b917"
#define uuid_jble_PacketService @"772ae377-b3d2-4f8e-4042-5481d1e0098c"

@implementation SmcGATT

@synthesize delegate;
@synthesize peripherals;
@synthesize manager;
@synthesize activePeripheral;
@synthesize cService;


/*
 * (void) setup
 * enable CoreBluetooth CentralManager and set the delegate for SerialGATT
 *
 */

-(void) setup
{
    NSLog(@"setup");
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

/*
 * -(int) findHMSoftPeripherals:(int)timeout
 *
 */
-(int) findHMSoftPeripherals:(int)timeout
{
    NSLog(@"findHMSoftPeripherals");
    if ([manager state] != CBCentralManagerStatePoweredOn) {
        printf("CoreBluetooth is not correctly initialized !\n");
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    [manager scanForPeripheralsWithServices:nil options:0];
    return 0;
}

/*
 * scanTimer
 * when findHMSoftPeripherals is timeout, this function will be called
 *
 */
-(void) scanTimer:(NSTimer *)timer
{
    [manager stopScan];
}

/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of 
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral 
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef )peripheral.identifier);
    printf("------------------------------------\r\n");
    printf("Peripheral Info :\r\n");
    printf("UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
    printf("RSSI : %d\r\n",[peripheral.RSSI intValue]);
    printf("Name : %s\r\n",[peripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    printf("isConnected : %d\r\n",peripheral.state == CBPeripheralStateConnected);
    printf("-------------------------------------\r\n");
    
}
//C50363DA-3F23-6FFC-0000-000000000000
/*
 * connect
 * connect to a given peripheral
 *
 */
-(void) connect:(CBPeripheral *)peripheral
{
    NSLog(@"smcgatt connect");
    if (!(peripheral.state == CBPeripheralStateConnected)) {
        NSLog(@"smcgatt connecting %@", peripheral);
        [manager connectPeripheral:peripheral options:nil];
    }
}

- (void)myConnect:(NSString *)identifier{
    NSLog(@"myConnect");
    NSUUID *uuid2 = [[NSUUID UUID] initWithUUIDString:identifier];
    NSLog(@"%@", uuid2);
    NSArray *array = [manager retrievePeripheralsWithIdentifiers:@[uuid2]];
    NSLog(@"myConnect :%d", (int)array.count);
//    CBPeripheral *peripheral = (CBPeripheral *)[array objectAtIndex:0];
//    if (!(peripheral.state == CBPeripheralStateConnected)) {
//        NSLog(@"myConnect connecting %@", peripheral);
//        [manager connectPeripheral:peripheral options:nil];
//    }
}

-(void) stopScan
{
    NSLog(@"smcgatt stopscan");
    [[NSUserDefaults standardUserDefaults] setObject:@"s" forKey:@"connect"];
    [manager stopScan];
}



/*
 * disconnect
 * disconnect to a given peripheral
 *
 */
-(void) disconnect:(CBPeripheral *)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManager Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //TODO: to handle the state updates
    if(central.state == CBCentralManagerStateUnknown){
        NSLog(@"CBCentralManagerStateUnknown");
    }
    else if(central.state == CBCentralManagerStateResetting){
        NSLog(@"CBCentralManagerStateResetting");
    }
    else if(central.state == CBCentralManagerStateUnsupported){
        NSLog(@"CBCentralManagerStateUnsupported");
    }
    else if(central.state == CBCentralManagerStateUnauthorized){
        NSLog(@"CBCentralManagerStateUnauthorized");
    }
    else if(central.state == CBCentralManagerStatePoweredOff){
        [[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"connect"];
        NSLog(@"CBCentralManagerStatePoweredOff");
    }
    else if(central.state == CBCentralManagerStatePoweredOn){
        NSLog(@"CBCentralManagerStatePoweredOn");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    printf("Now we found device\n");
    if (!peripherals) {
        peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
        for (int i = 0; i < [peripherals count]; i++) {
            [delegate peripheralFound: peripheral rssi:RSSI];
        }
    }
    
    {
        if((__bridge CFUUIDRef )peripheral.identifier == NULL) return;
        //if(peripheral.name == NULL) return;
        //if(peripheral.name == nil) return;
        if(peripheral.name.length < 1) return;
        // Add the new peripheral to the peripherals array
        for (int i = 0; i < [peripherals count]; i++) {
            CBPeripheral *p = [peripherals objectAtIndex:i];
            if((__bridge CFUUIDRef )p.identifier == NULL) continue;
            CFUUIDBytes b1 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )p.identifier);
            CFUUIDBytes b2 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )peripheral.identifier);
            if (memcmp(&b1, &b2, 16) == 0) {
                // these are the same, and replace the old peripheral information
                [peripherals replaceObjectAtIndex:i withObject:peripheral];
                printf("Duplicated peripheral is found...\n");
                //[delegate peripheralFound: peripheral];
                return;
            }
        }
        printf("New peripheral is found...\n");
        [peripherals addObject:peripheral];
        [delegate peripheralFound: peripheral rssi:RSSI];
        return;
    }
    printf("%s\n", __FUNCTION__);
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    printf("connected to the active peripheral\n");
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    [activePeripheral discoverServices:nil];
    [self printPeripheralInfo:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    printf("disconnected to the active peripheral\n");
    if(activePeripheral != nil)
        activePeripheral = nil;

     [delegate setDisconnect];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed to connect to peripheral %@: %@\n", [peripheral name], [error localizedDescription]);
}

#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  //  printf("in updateValueForCharacteristic function\n");
    
    if (error) {
        printf("updateValueForCharacteristic failed\n");
        return;
    }
    [delegate serialGATTCharValueUpdated:characteristic.value];
}

//////////////////////////////////////////////////////////////////////////////////////////////

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}


//
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices:\n");
    if( peripheral.identifier == NULL  ) return; // zach ios6 added
    if (!error) {
        for (CBService *p in peripheral.services){
            NSLog(@"Service found with UUID: %@\n", p.UUID);
            [peripheral discoverCharacteristics:nil forService:p];
        }
    }
    else {
        NSLog(@"Service discovery was unsuccessfull !\n");
    }
}


/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered 
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
   
    if (!error) {
        shareBERController = [BleController sharedController];
        shareBERController.service = service;
        shareBERController.connectedPeripheral = peripheral;
         cService = service;
        NSLog(@"=========== %ld Characteristics of %@ service ",(long)service.characteristics.count,service.UUID);
        for(CBCharacteristic *c in service.characteristics){
            NSLog(@" %@ \n",c.UUID);
            
            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_Service]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
            
            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_ControlService]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }

            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_ControlNotification]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }

            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_ButtonService]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }

            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_LedService]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }

            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_AdcService]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }

            if ([c.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_PacketService]]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
            
        }
        NSLog(@"=== Finished set notification ===\n");
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !\n");
        
    }
}



- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
         if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uuid_jble_ControlService]]) {
        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);

             [shareBERController init_iTag];

            [delegate setConnect];
              printf("Connected\n");
         }
    }
    else {
        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);
        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}



-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);		
    
}

-(void) SendLED:(int)rr G:(int)gg B:(int)bb ontime:(int) ontime offtime:(int) offtime count:(int) count LED:(BOOL *) on{
    [shareBERController SendLED:rr G:gg B:bb ontime:ontime offtime:offtime count:count LED:on];
}
-(void) SendData:(NSString *)text{
    [shareBERController Send_NFC_Data:text];
}
-(void) EndData{
    [shareBERController NFC_End_Data];
}

-(void) SendBuzzer:(BOOL *) on ontime:(int)a offtime:(int)b count:(int)c{
    [shareBERController SendBuzzer:on ontime: a offtime:b count:c];
}



@end
