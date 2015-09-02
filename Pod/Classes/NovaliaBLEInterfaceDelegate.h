//
//  NovaliaBLEInterfaceDelegate.h
//  BLEInterface
//
//  Created by Adrian Lubik on 13/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NovaliaBLEConstants.h"
#import "NovaliaBLEDevice.h"

@protocol NovaliaBLEInterfaceDelegate <NSObject>

@optional

-(void)onDiscoveryStarted;
-(void)onDiscoveryStopped;
-(void)onDeviceDisconnected:(NovaliaBLEDevice *)device;
-(void)onDeviceDiscovered:(NovaliaBLEDevice *)device;
-(void)onBLEStateChanged:(NovaliaBLEState)state;
-(void)onDeviceListChanged:(NSArray *)newList;
-(void)onDeviceConnected:(NovaliaBLEDevice *)device;
-(void)didFailToConnect:(NovaliaBLEDevice *)device;
-(void)didTimeout:(NovaliaBLEDevice *)device;
-(void)onDeviceUpdatedValue:(NSData *)value;

@end
