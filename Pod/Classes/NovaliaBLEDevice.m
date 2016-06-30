//
//  NovaliaBLEDevice.m
//  BLEInterface
//
//  Created by Adrian Lubik on 14/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import "NovaliaBLEDevice.h"


@interface NovaliaBLEDevice ()

@property (readwrite) int deviceType;
@property (readwrite) NSUUID *uuid;
@property (readwrite) NSString *deviceName;
@property (readwrite) NSString *macAddress;
@property (readwrite) int status;
@property (readwrite) BOOL isRecognised;

@end


@implementation NovaliaBLEDevice

@synthesize deviceType;
@synthesize status;
@synthesize uuid;
@synthesize rssi;
@synthesize deviceName;
@synthesize macAddress;
@synthesize delegate;
@synthesize isRecognised;

- (NovaliaBLEDevice *) initWithUUID:(NSUUID *)theUUID {
    self = [self init];
    
    if (self) {
        status = 0;
        uuid = theUUID;
        isRecognised = NO;
        deviceType = NovaliaBLEDeviceTypeOther;
        macAddress = @"";
    }
    
    return self;
}

- (NovaliaBLEDevice *) initWithUUID:(NSUUID *)theUUID andRSSI:(NSNumber*)theRSSI {
    self = [self initWithUUID:theUUID];
    
    if (self) {
        rssi = theRSSI;
    }
    
    return self;
}

- (NovaliaBLEDevice *) initWithUUID:(NSUUID *)theUUID andName:(NSString *)theName {
    self = [self initWithUUID:theUUID];
    
    if (self) {
        deviceName = theName;
    }
    
    return self;
}


-(BOOL)isDiscovered {
    return ((status & NovaliaBLEDeviceDiscovered) == NovaliaBLEDeviceDiscovered);
}

-(BOOL)isConnected {
    return ((status & NovaliaBLEDeviceConnected) == NovaliaBLEDeviceConnected);
}

-(BOOL)isConnecting {
    return ((status & NovaliaBLEDeviceConnecting) == NovaliaBLEDeviceConnecting);
}

-(BOOL)isDisconnected {
    return ([self isConnecting] == NO && [self isConnected] == NO);
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NovaliaBLEDevice class]]) {
        return [uuid isEqual:[(NovaliaBLEDevice *) object uuid]];
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash {
    return [uuid hash];
}

@end
