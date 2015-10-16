//
//  NovaliaBLEDevice.h
//  BLEInterface
//
//  Created by Adrian Lubik on 14/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NovaliaBLEConstants.h"

#define NovaliaBLEDeviceDiscovered 0x001
#define NovaliaBLEDeviceConnecting 0x002
#define NovaliaBLEDeviceConnected  0x004

#define NovaliaBLEDeviceTypeOther       0x001
#define NovaliaBLEDeviceTypeDrums       0x002
#define NovaliaBLEDeviceType16KeyPoster 0x003
#define NovaliaBLEDeviceSoundOfTaste    0x004
#define NovaliaBLEDeviceTypePiano       0x005
#define NovaliaBLEDeviceTypeSwitchBoard 0x006
#define NovaliaBLEDeviceTypeVideo       0x007
#define NovaliaBLEDeviceTypeAudi        0x008
// #define NovaliaBLEDeviceTypeThePerformer2 0x009
// #define NovaliaBLEDeviceTypeThePerformer4 0x010

@protocol NovaliaBLEDeviceEventDelegate <NSObject>

@optional

-(void)onButtonPressed:(int)button velocity:(int)velocity onDevice:(id)device;
-(void)onRSSIUpdated:(NSNumber*)RSSI onDevice:(id)device;
-(void)onStatusUpdated:(int)status onDevice:(id)device;

@end



@interface NovaliaBLEDevice : NSObject

@property (readonly) int deviceType;
@property (readonly) int status;
@property (readonly) BOOL isRecognised;
@property NSNumber *rssi;
@property (readonly) NSUUID *uuid;
@property (readonly) NSString *name;
@property id<NovaliaBLEDeviceEventDelegate> delegate;

- (NovaliaBLEDevice *) initWithUUID:(NSUUID *)uuid;
- (NovaliaBLEDevice *) initWithUUID:(NSUUID *)uuid andName:(NSString*)theName;
- (NovaliaBLEDevice *) initWithUUID:(NSUUID *)theUUID andRSSI:(NSNumber*)theRSSI;

-(BOOL)isDiscovered;
-(BOOL)isConnected;
-(BOOL)isConnecting;
-(BOOL)isDisconnected;

@end