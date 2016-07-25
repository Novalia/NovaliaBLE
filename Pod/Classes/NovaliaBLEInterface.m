//
//  BLEInterface.m
//  BLEInterface
//
//  Created by Adrian Lubik on 13/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import "NovaliaBLEInterface.h"
#import "NovaliaBLEPrivateManager.h"
#import "NovaliaBLEPrivateManager.h"

@interface NovaliaBLEInterface()

@property NovaliaBLEPrivateManager *manager;

@end



@implementation NovaliaBLEInterface

@synthesize delegate = _delegate;
@synthesize manager;
@synthesize diagnosticsMode = _diagnosticsMode;

- (NovaliaBLEInterface *) init {
    self = [super init];
    
    if (self) {
        manager = [[NovaliaBLEPrivateManager alloc] init];
    }
    
    return self;
}

- (NovaliaBLEInterface *) initWithDelegate:(id<NovaliaBLEInterfaceDelegate>)d {
    self = [self init];
   
    if (self) {
        [self setDelegate:d];
    }
    
    return self;
}

- (void)setDelegate:(id<NovaliaBLEInterfaceDelegate>)d {
    _delegate = d;
    [manager setDelegate:d];
}

- (void)setDiagnosticsMode:(BOOL)diagnosticsMode {
    _diagnosticsMode = diagnosticsMode;
    [manager setDiagnosticsMode:diagnosticsMode];
}

- (BOOL) startDeviceDiscovery:(NSString*)targetName {
    return [manager startDiscovery:targetName];
}

- (void) stopDeviceDiscovery {
    [manager stopDiscovery];
}

- (BOOL) isConnectedToDevice:(NovaliaBLEDevice *)device {
    return [manager isConnectedToDevice:device];
}

-(NSArray *)devices {
    return [manager getDevicesCopy];
}

- (void) connectToDevices:(NSArray *)devices {
    [manager connectToDevices:devices];
}

-(void)connectToDevice:(NovaliaBLEDevice *)device {
    [self connectToDevices:[[NSArray alloc] initWithObjects:device, nil]];
}

-(void)disconnectFromDevice:(NovaliaBLEDevice *)device {
    [manager disconnectFromDevice:device];
}

-(NSArray*)retrieveDevicesWithIdentifiers:(NSArray *)identifiers {
    return [manager retrieveDevicesWithIdentifiers:identifiers];
}

-(NovaliaBLEState)bluetoothState {
    return [manager bluetoothState];
}

-(void)writeData:(NSData *)data toDevice:(NovaliaBLEDevice *)device {
    
    NSLog(@"NovaliaBLEInterface writeData %@ toDevice %@", data, device);
    [manager writeData:data toDevice:device];
}

@end
