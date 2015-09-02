//
//  NovaliaBLEPrivateManager.h
//  BLEInterface
//
//  Created by Adrian Lubik on 13/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "NovaliaBLEInterfaceDelegate.h"
#import "NovaliaBLEDevice.h"

@interface NovaliaBLEPrivateManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, assign) id <NovaliaBLEInterfaceDelegate> delegate;
@property (readonly) NSMutableArray *connectedDevices;

-(BOOL)startDiscovery;
-(void)stopDiscovery;
-(BOOL)isConnectedToDevice:(NovaliaBLEDevice *)device;
-(void)connectToDevices:(NSArray *)devices;
-(void)disconnectFromDevice:(NovaliaBLEDevice *)device;
-(NSArray *)getDevicesCopy;
-(NSArray*)retrieveDevicesWithIdentifiers:(NSArray *)identifiers;
-(NovaliaBLEState)bluetoothState;
-(void)writeData:(NSData*)data toDevice:(NovaliaBLEDevice *)device;

@end
