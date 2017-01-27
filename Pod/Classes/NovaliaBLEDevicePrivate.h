//
//  NovaliaBLEDevicePrivate.h
//  BLEInterface
//
//  Created by Adrian Lubik on 06/03/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "NovaliaBLEDevice.h"

@interface NovaliaBLEDevicePrivate : NovaliaBLEDevice

@property CBPeripheral *peripheral;

-(NovaliaBLEDevicePrivate *)initWithPeripheral:(CBPeripheral*)peripheral;
-(NovaliaBLEDevicePrivate *)initWithPeripheral:(CBPeripheral*)peripheral andRSSI:(NSNumber*)RSSI;

-(void)updateMACAddress:(NSString *)macAddress;
-(void)updateFirmwareVersion:(NSString *)firmwareVersion;
-(void)updateHardwareVersion:(NSString *)hardwareVersion;
-(void)updateStatus:(int)status;
-(void)updateRSSI:(NSNumber *)RSSI;
-(void)onButtonPressed:(int)button velocity:(int)velocity;

@end
