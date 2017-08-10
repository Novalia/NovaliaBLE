//
//  BLEInterface.h
//  BLEInterface
//
//  Created by Adrian Lubik on 13/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NovaliaBLEInterfaceDelegate.h"
#import "NovaliaBLEDevice.h"

@interface NovaliaBLEInterface : NSObject

@property (nonatomic, strong) id<NovaliaBLEInterfaceDelegate> delegate;
@property BOOL diagnosticsMode;

-(NovaliaBLEInterface *)init;
-(NovaliaBLEInterface *)initWithDelegate:(id <NovaliaBLEInterfaceDelegate>)delegate;
-(BOOL)startDeviceDiscovery:(NSString*)targetName;
-(BOOL)startDeviceDiscovery:(NSString*)targetName allowDuplicates:(BOOL)allowDuplicates;
-(void)stopDeviceDiscovery;
-(BOOL)isConnectedToDevice:(NovaliaBLEDevice *)device;
-(NSArray*)devices;
-(void)forgetAllDevices;
-(void)connectToDevices:(NSArray *)devices;
-(void)connectToDevice:(NovaliaBLEDevice *)device;
-(void)disconnectFromDevice:(NovaliaBLEDevice *)device;
-(NSArray*)retrieveDevicesWithIdentifiers:(NSArray *)identifiers;
-(NovaliaBLEState)bluetoothState;

-(void)writeData:(NSData*)data toDevice:(NovaliaBLEDevice *)device;
-(void)writeDISSerialNumber:(NSString*)serialNumber toDevice:(NovaliaBLEDevice *)device;


@end
