//
//  NovaliaBLEPrivateManager.m
//  BLEInterface
//
//  Created by Adrian Lubik on 13/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import "NovaliaBLEPrivateManager.h"
#import "NovaliaBLEPrivateConstants.h"
#import "CBUUID+CBUUIDWithInteger.h"
#import "NovaliaBLEConstants.h"
#import "NovaliaBLEConnectTimeoutHelper.h"
#import "NovaliaBLEDevicePrivate.h"

#define CBUUID_MAX_DATA_BYTE_SIZE   (128 / 8) // CBUUID is either 16- or 128-bit long.

@interface NovaliaBLEPrivateManager() <NovaliaBLEConnectTimeoutHelperDelegate>

@property CBCentralManager *centralManager;
@property NSMutableArray *allDevices;
@property NSMutableArray *helpers;
@property CBUUID *novaliaServiceUUID;
@property CBUUID *novaliaButtonCharacteristicUUID;
@property CBUUID *appleBLEMIDICharacteristicUUID;
@property CBUUID *primaryServiceUUID;
@property CBUUID *primaryServiceSerialNumberCharacteristicUUID;
@property NSArray *targetDeviceName;

@property (strong,nonatomic) NSMutableArray *peripherals;

@end


@implementation NovaliaBLEPrivateManager

@synthesize delegate;
@synthesize diagnosticsMode;
@synthesize centralManager;
@synthesize novaliaServiceUUID;
@synthesize novaliaButtonCharacteristicUUID;
@synthesize appleBLEMIDICharacteristicUUID;
@synthesize primaryServiceUUID;
@synthesize primaryServiceSerialNumberCharacteristicUUID;
@synthesize allDevices;
@synthesize helpers;
@synthesize targetDeviceName;

-(NovaliaBLEDevicePrivate *)findDevice:(NovaliaBLEDevice *)device {
    NSUInteger index = [allDevices indexOfObject:device];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    return [allDevices objectAtIndex:index];
}

-(NovaliaBLEDevicePrivate *)findDeviceForPeripheral:(CBPeripheral *)peripheral {
    id device = [[NovaliaBLEDevice alloc] initWithUUID:[peripheral identifier] andName:peripheral.name];
    return [self findDevice:device];
}

-(NovaliaBLEDevicePrivate *)findDeviceOrInserIfNotFoundForPeripheral:(CBPeripheral *)peripheral {
    id found = [self findDeviceForPeripheral:peripheral];
    
    if (found != nil) {
        return found;
    }
    
    found = [[NovaliaBLEDevicePrivate alloc] initWithPeripheral:peripheral];
    [allDevices addObject:found];
    
    // todo: notify?
    
    return found;
}

- (NovaliaBLEPrivateManager *)init {
    self = [super init];
    
    if (self) {
        //novaliaServiceUUID = [CBUUID UUIDWithInteger:NOVALIA_SERVICE_UUID];
        novaliaServiceUUID = [CBUUID UUIDWithString:NOVALIA_STANDARD_SERVICE_UUID];
        NSLog(@"novaliaServiceUUID = %@", novaliaServiceUUID.UUIDString);
        novaliaButtonCharacteristicUUID = [CBUUID UUIDWithInteger:NOVALIA_BUTTON_CHARACTERISTIC_UUID];
        appleBLEMIDICharacteristicUUID = [CBUUID UUIDWithString:NOVALIA_STANDARD_BUTTON_CHARACTERISTIC_UUID];
        primaryServiceUUID = [CBUUID UUIDWithInteger:PRIMARY_SERVICE_DEVICE_INFORMATION_UUID];
        primaryServiceSerialNumberCharacteristicUUID = [CBUUID UUIDWithInteger:PRIMARY_SERIAL_NUMBER_CHARACTERISTIC_UUID];
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        allDevices = [[NSMutableArray alloc] init];
        helpers = [[NSMutableArray alloc] init];
        self.peripherals=[NSMutableArray new];
    }
    
    return self;
}


/*!
 * @method isConnectedToDevice:
 *
 * @param device NovaliaBLEDevice The device object.
 *
 * @return BOOL YES if this instance is connected to the device, NO otherwise.
 */
- (BOOL)isConnectedToDevice:(NovaliaBLEDevice *)device {
    @synchronized(self) {
        id holder = [self findDevice:device];
        
        if (holder == nil) {
            return NO;
        }
        
        return [holder isConnected];
    }
}

- (BOOL)isConnectingToDevice:(NovaliaBLEDevice *)device {
    @synchronized(self) {
        id holder = [self findDevice:device];
        
        if (holder == nil) {
            return NO;
        }
        
        return [holder isConnecting];
    }
}

- (BOOL)startDiscovery:(NSArray*)targetName allowDuplicates:(BOOL)allowDuplicates {
    if(diagnosticsMode) {
        NSLog(@"NovaliaBLEPrivateManager startDiscovery: called.");
    }
    
    self.targetDeviceName = targetName;
    
    if (centralManager.state < CBCentralManagerStatePoweredOff) {
        NSLog(@"NovaliaBLEPrivateManager startDiscovery: Cannot start - current state = %ld.", (long)centralManager.state);
        return NO;
    }
    
    if (centralManager.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"NovaliaBLEPrivateManager startDiscovery: Cannot start - Bluetooth is off.");
        return NO;
    }
    
//#define SEARCH_ALL_DEVICES
#ifdef SEARCH_ALL_DEVICES
    // Set services array to nil if we want to scan for all devices
    NSArray *services = [[NSArray alloc] initWithObjects:nil];
#else
    // Set services array to list of service UUIDs if we want specific devices
    NSArray *services = [[NSArray alloc] initWithObjects:novaliaServiceUUID, primaryServiceUUID, nil];
#endif
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithCapacity:1];
    if(allowDuplicates) {
        [options setObject:[[NSNumber alloc] initWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    }

    // Look only for devices that match our service
    [centralManager scanForPeripheralsWithServices:services options:options];
    
    if(diagnosticsMode) {
        NSLog(@"NovaliaBLEPrivateManager startDiscovery: Discovery should have started.");
    }
    
    if ([delegate respondsToSelector:@selector(onDiscoveryStarted)]) {
        [delegate onDiscoveryStarted];
    }
    
    return YES;
}

// identifiers = NSUUID
-(NSArray*)retrieveDevicesWithIdentifiers:(NSArray *)identifiers {
    if ([identifiers count] == 0) {
        return nil;
    }
    
    id peripherals = [centralManager retrievePeripheralsWithIdentifiers:identifiers];
    id devices = [[NSMutableArray alloc] initWithCapacity:[identifiers count]];
    
    @synchronized(self) {
        for (id peripheral in peripherals) {
            id device = [self findDeviceForPeripheral:peripheral];
            
            if (device == nil) {
                device = [[NovaliaBLEDevicePrivate alloc] initWithPeripheral:peripheral];
                [allDevices addObject:device];
            }
            
            [devices addObject:device];
        }
    }
    
    if ([devices count] == [identifiers count]) {
        return devices; // All recognised.
    }
    
    for (id identifier in identifiers) {
        id device = [[NovaliaBLEDevice alloc] initWithUUID:identifier];
        
        if ([devices containsObject:device]) {
            continue;
        }
        
        [devices addObject:device];
    }
    
    return devices;
}

- (void) connectToDevices:(NSArray *)devicesToConnect {
    if(diagnosticsMode) {
        NSLog(@"NovaliaBLEPrivateManager connectToDevices");
    }
    
    NSMutableArray *identifiers = [[NSMutableArray alloc] initWithCapacity:[devicesToConnect count]];
    
    @synchronized(self) {
        for (NovaliaBLEDevice *device in devicesToConnect) {
            NSLog(@"Connecting to device: %@", device.uuid.UUIDString);
            if ([self isConnectedToDevice:device] || [self isConnectingToDevice:device]) {
                NSLog(@"already connected");
                continue;
            }
            
            [identifiers addObject:[device uuid]];
        }
        
        if ([identifiers count] > 0) {
            NSSet *peripherals = [NSSet setWithArray:[centralManager retrievePeripheralsWithIdentifiers:identifiers]];
            
            for (CBPeripheral *peripheral in peripherals) {
                //[centralManager cancelPeripheralConnection:peripheral]; // todo: make sure it can stay here
                id device = [self findDeviceForPeripheral:peripheral];
                
                if (device == nil) {
                    device = [[NovaliaBLEDevicePrivate alloc] initWithPeripheral:peripheral];
                    [device updateStatus:NovaliaBLEDeviceDiscovered];
                    [allDevices addObject:device];
                }
                // todo: notify?
                [device updateStatus:([device status]|NovaliaBLEDeviceConnecting)];
                
                /*
                id helper = [[NovaliaBLEConnectTimeoutHelper alloc] initWithPeripheral:peripheral andTimeout:30.0];
                [helpers addObject:helper];
                [helper setDelegate:self];
                [helper start];
                 */
                [centralManager connectPeripheral:peripheral options:nil];
            }
        }
    }
}

- (void)stopDiscovery {
    if(diagnosticsMode) {
        NSLog(@"NovaliaBLEPrivateManager stopDiscovery: called.");
    }
    
    // We're not returning because we still want to call onDiscoveryStopped
    // in case the user interface needs to be updated.xw
    if ([centralManager state] < CBCentralManagerStatePoweredOn) {
        NSLog(@"NovaliaBLEPrivateManager stopDiscovery: Bluetooth is not on. No action needed.");
    } else {
        [centralManager stopScan];
    }
    
    if ([delegate respondsToSelector:@selector(onDiscoveryStopped)]) {
        [delegate onDiscoveryStopped];
    }
}

// CBCentralManagerDelegate Protocol Implementation:

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(diagnosticsMode) {
        NSLog(@"NovaliaBLEPrivateManager centralManagerDidUpdateState: called.");
    }
    
    if (central != centralManager) {
        NSLog(@"NovaliaBLEPrivateManager centralManagerDidUpdateState: Unknown Manager");
        return;
    }
    
    static CBCentralManagerState previousState = -1;
    
    CBCentralManagerState state = central.state;
    NovaliaBLEState bleState = [self bluetoothStatusForCentralState:state];
    
    if(diagnosticsMode) {
        NSLog(@"NovaliaBLEPrivateManager centralManagerDidUpdateState: Current State = %ld %@", (long)state, [NovaliaBLEPrivateManager getCBCentralStateName:state]);
    }
    
    if ([delegate respondsToSelector:@selector(onBLEStateChanged:)]) {
        [delegate onBLEStateChanged:bleState];
    }
    
    if (state <= CBCentralManagerStatePoweredOff) {
        for (NovaliaBLEConnectTimeoutHelper *helper in helpers) {
            [helper cancel];
        }
        
        [helpers removeAllObjects];
        [allDevices removeAllObjects];
        
        if ([delegate respondsToSelector:@selector(onDeviceListChanged:)]) {
            [delegate onDeviceListChanged:[self getDevicesCopy]];
        }
    }
    
    previousState = state;
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // TODO: handle errors
    NSLog(@"NovaliaBLEPrivateManager peripheral didDiscoverServices: called");
    NSLog(@"  Services: %@\n  Error: %@", peripheral.services, error);
    
    if (error != nil) {
        //todo: handle
        return;
    }
    
    //CBService *service = [self findServiceFromUUID:novaliaServiceUUID onPeripheral:peripheral];
    //[peripheral discoverCharacteristics:nil forService:service];
    
    for(CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // todo: handle errors
    NSArray *characteristics = (service == nil) ? nil : service.characteristics;
    NSLog(@"  Characteristics: %@\n  Error: %@", characteristics, error);
    
    
    if ([self isCBUUID:service.UUID equalTo:primaryServiceUUID]) {
        for(CBCharacteristic *characteristic in characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:appleBLEMIDICharacteristicUUID
                                                         onService:service];
    
    //CBCharacteristic *characteristic = [self findCharacteristicFromUUID:novaliaButtonCharacteristicUUID onService:service];
    
    if (characteristic == nil) {
        NSLog(@"Characteristic we are looking for is not found");
        return; // todo: print message?
    }
    
    // fixme: what if the device disconnected and reconnected? will it work without duplicates?
    NovaliaBLEDevicePrivate *device;
    
    @synchronized(self) {
        device = [self findDeviceForPeripheral:peripheral];
        
        if (device == nil) {
            // todo: ooops, should never happen
            return;
        }
        
        [self cancelHelperForPeripheral:peripheral cancelConnection:NO andUpdateDeviceStatus:NO];
        [device updateStatus:(NovaliaBLEDeviceDiscovered|NovaliaBLEDeviceConnected)];
    
        if ([delegate respondsToSelector:@selector(onDeviceListChanged:)]) {
            [delegate onDeviceListChanged:[self allDevices]];
        }
    }

    if ([delegate respondsToSelector:@selector(onDeviceConnected:)]) {
        [delegate onDeviceConnected:device];
    }
    
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"NovaliaBLEPrivateManager centralManager:didDiscoverPeripheral: %@ (RSSI: %@)", peripheral.name, RSSI);
    
    BOOL isRecognised = NO;
    NSArray *advertisedUUIDs = [advertisementData valueForKey:CBAdvertisementDataServiceUUIDsKey];
    
    for (CBUUID *uuid in advertisedUUIDs) {
        if ([uuid isEqual:novaliaServiceUUID]) {
            isRecognised = YES;
            NSLog(@"YES Recognized as Novalia service: %@", advertisementData);
            break;
        }
    }
    
    if (isRecognised == NO) {
        //NSLog(@"NO Recognized: %@", advertisementData);
        return;
    }
    
    
    
    if([self.targetDeviceName containsObject:peripheral.name] || [[self.targetDeviceName objectAtIndex: 0] isEqualToString:@"*"]) {
        
        [self.peripherals addObject:peripheral];

        @synchronized(self) {
            id device = [self findDeviceForPeripheral:peripheral];
            
            if (device == nil) {
                device = [[NovaliaBLEDevicePrivate alloc] initWithPeripheral:peripheral andRSSI:RSSI];
                [device updateStatus:NovaliaBLEDeviceDiscovered];
                [allDevices addObject:device];
                
                // The following line triggers an auto connect if not already connected
                [centralManager cancelPeripheralConnection:peripheral];
                [centralManager connectPeripheral:peripheral options:nil];
            
                if ([delegate respondsToSelector:@selector(onDeviceListChanged:)]) {
                    [delegate onDeviceListChanged: (NSArray *)allDevices];
                }
            } else {
                [device updateStatus:([device status] | NovaliaBLEDeviceDiscovered)];
                [device updateRSSI:RSSI];
            }
            
            if ([delegate respondsToSelector:@selector(onDeviceListChanged:)]) {
                [delegate onDeviceListChanged:[self getDevicesCopy]];
            }
            
            if ([device isDisconnected] && [delegate respondsToSelector:@selector(onDeviceDiscovered:)]) {
                [delegate onDeviceDiscovered:device];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"NovaliaBLEPrivateManager centralManager:didConnectPeripheral: %@", peripheral.name);

    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

-(void)cancelHelperForPeripheral:(CBPeripheral *)peripheral cancelConnection:(BOOL)cancelConnection andUpdateDeviceStatus:(BOOL)update {
    if (peripheral == nil) {
        return;
    }
    
    if (cancelConnection) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
    
    @synchronized(self) {
        NovaliaBLEConnectTimeoutHelper *helper = nil;
        
        for (helper in helpers) {
            if ([[helper peripheral] isEqual:peripheral]) {
                [helper cancel];
                break;
            }
        }
        
        [helpers removeObjectIdenticalTo:helper];
        
        if (update) {
            id device = [self findDeviceForPeripheral:peripheral];
            [device updateStatus:NovaliaBLEDeviceDiscovered];
        }
        // todo: notify?
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"NovaliaBLEPrivateManager centralManager:didFailToConnectPeripheral: %@", error.localizedDescription);
    
    // todo: handle errors and so on
    [self cancelHelperForPeripheral:peripheral cancelConnection:NO andUpdateDeviceStatus:YES];
    
    if ([delegate respondsToSelector:@selector(didFailToConnect:)]) {
        id device = [self findDeviceForPeripheral:peripheral];
        [delegate didFailToConnect:device];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral with uuid %@", [[peripheral identifier] UUIDString]);
    NSLog(@"error: %@", error);
    // todo: send notification to the delegate and allow auto reconnect
    
    [self cancelHelperForPeripheral:peripheral cancelConnection:NO andUpdateDeviceStatus:NO];
    
    id device = [self findDeviceForPeripheral:peripheral];
    
    if (error != nil) {
        [device updateStatus:0];
    }
    
    if (device != nil && [delegate respondsToSelector:@selector(onDeviceDisconnected:)]) {
        NSLog(@"Notifying delegate as well");
        [delegate onDeviceDisconnected:device];
    }
    
    if ([delegate respondsToSelector:@selector(onDeviceListChanged:)]) {
        [delegate onDeviceListChanged:[self allDevices]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    /*
    if ([[characteristic UUID] isEqual:novaliaButtonCharacteristicUUID] == NO) {
        return;
    }
     */
    
    NovaliaBLEDevicePrivate* device = [self findDeviceForPeripheral:peripheral];
    
    if (device == nil) {
        return;
    }
    
    if ([[characteristic UUID] isEqual:appleBLEMIDICharacteristicUUID] == NO) {
        
        NSData *data = characteristic.value;
        NSLog(@"Characteristic %@ value %@", characteristic, characteristic.value);
        if([characteristic.UUID.description isEqualToString:@"Model Number String"]) {
            NSString *macAddressString = @"Firmware does not provide MAC address";
            uint8_t *bytes = (uint8_t*)data.bytes;
            if(bytes) {
               macAddressString = [NSString stringWithFormat: @"%02x:%02x:%02x:%02x:%02x:%02x",
                                          bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
            }
            NSLog(@"MAC address %@", macAddressString);
            [device updateMACAddress:macAddressString];
            NSLog(@"MAC address on device: %@", device.macAddress);
        } else if([characteristic.UUID.description isEqualToString:@"Hardware Revision String"]) {
            [device updateHardwareVersion:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } else if([characteristic.UUID.description isEqualToString:@"Firmware Revision String"]) {
            [device updateFirmwareVersion:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } else if([[characteristic UUID] isEqual:primaryServiceSerialNumberCharacteristicUUID]) {
            NSLog(@"Serial number: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [device updateDeviceName:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            
        } else {
            NSLog(@"UUID: [%@]", characteristic.UUID);
            NSLog(@"Data: %@",  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
        
        return;
    }

    
    if ([delegate respondsToSelector:@selector(onDeviceUpdatedValue:)]) {
        [delegate onDeviceUpdatedValue:characteristic.value];
    } else {
        if(diagnosticsMode) {
            NSLog(@"NovaliaBLEPrivateManager peripheral:didUpdateValueForCharacteristic: %@", characteristic);
            NSLog(@"Value: %@", characteristic.value);
        }
    }
    
    // Find which button was pressed
    char byte[5];
    [[characteristic value] getBytes:&byte length:5];
    int note = byte[3];
    int velocity = byte[4];

    [device onButtonPressed:note
                   velocity:velocity];
}


//
- (CBService *) findServiceFromUUID:(CBUUID *)UUID onPeripheral:(CBPeripheral *)peripheral {
    NSArray *services = [peripheral services];
    
    for(int i = 0; i < services.count; i++) {
        CBService *s = [services objectAtIndex:i];
        if ([self isCBUUID:s.UUID equalTo:UUID]) {
            return s;
        }
    }
    
    return nil;
}

- (BOOL) isCBUUID:(CBUUID *) first equalTo:(CBUUID *)second {
    char b1[CBUUID_MAX_DATA_BYTE_SIZE];
    char b2[CBUUID_MAX_DATA_BYTE_SIZE];
    
    [first.data getBytes:b1 length:CBUUID_MAX_DATA_BYTE_SIZE];
    [second.data getBytes:b2 length:CBUUID_MAX_DATA_BYTE_SIZE];

    if (memcmp(b1, b2, first.data.length) == 0) {
        return YES;
    } else {
        return NO;
    }
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)uuid onService:(CBService*)service {
    NSArray *characteristics = [service characteristics];
    
    NSLog(@"NovaliaBLEPrivateManager findCharacteristicFromUUID for service %@", service.UUID.UUIDString);
    for(int i=0; i < characteristics.count; i++) {
        CBCharacteristic *c = [characteristics objectAtIndex:i];
        NSLog(@"Checking %@ == %@", c.UUID, uuid);
        if ([self isCBUUID:c.UUID equalTo:uuid]) {
            return c;
        }
    }
    
    return nil;
}

- (CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)characteristicUUID andServiceUUID:(CBUUID*)serviceUUID onPeripheral:(CBPeripheral *)peripheral {
    for (CBService *service in [peripheral services]) {
        if ([[service UUID] isEqual:serviceUUID]) {
            return [self findCharacteristicFromUUID:characteristicUUID onService:service];
        }
    }
    
    return nil;
}
//

-(void)didTimeOut:(NovaliaBLEConnectTimeoutHelper*)helper {
    [centralManager cancelPeripheralConnection:[helper peripheral]];
    
    @synchronized(self) {
        [helpers removeObjectIdenticalTo:helper];
    }
    
    id peripheral = [helper peripheral];
    id device = [self findDeviceForPeripheral:peripheral];
    
    int status = [device status];
    status = status ^ NovaliaBLEDeviceConnecting;
    
    [device updateStatus:status];
    
    if ([delegate respondsToSelector:@selector(didTimeout:)]) {
        [delegate didTimeout:device];
    }
    if ([delegate respondsToSelector:@selector(onDeviceListChanged:)]) {
        [delegate onDeviceListChanged:[self getDevicesCopy]];
    }
}

-(void)disconnectFromDevice:(NovaliaBLEDevice *)d {
    @synchronized(self) {
        id device = [self findDevice:d];
        
        if (device == nil) {
            return;
        }
        
        [centralManager cancelPeripheralConnection:[device peripheral]];
        [device updateStatus:([device status] & NovaliaBLEDeviceDiscovered)];
        
        if ([delegate respondsToSelector:@selector(onDeviceDisconnected:)]) {
            [delegate onDeviceDisconnected:device];
        }
    }
}

-(NSArray *)getDevicesCopy {
    return (NSArray *)allDevices.copy;
}

- (void)forgetAllDevices {
    [allDevices removeAllObjects];
}

-(NovaliaBLEState)bluetoothState {
    return [self bluetoothStatusForCentralState:[centralManager state]];
}

-(NovaliaBLEState)bluetoothStatusForCentralState:(CBCentralManagerState) centralState {
    switch (centralState) {
        case CBCentralManagerStatePoweredOff:
            return BLEStateOff;
            
        case CBCentralManagerStatePoweredOn:
            return BLEStateOn;
            
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
            return BLEStateNotReady;
            
        case CBCentralManagerStateUnsupported:
            return BLEStateUnsupported;
    }
    
    return BLEStateUnsupported;
}

// Writing to device added by Andrew Sage
-(void)writeData:(NSData *)data toDevice:(NovaliaBLEDevice *)device {
    
    NSLog(@"NovaliaBLEPrivateManager writeData %@ toDevice %@", data, device);
    
    for(NovaliaBLEDevicePrivate *privateDevice in allDevices) {
        if(privateDevice.uuid == device.uuid) {
            NSLog(@"We need to write to peripheral %@", privateDevice.peripheral);
            CBService *service = [self findServiceFromUUID:novaliaServiceUUID onPeripheral:privateDevice.peripheral];
            CBCharacteristic *characteristic = [self findCharacteristicFromUUID:appleBLEMIDICharacteristicUUID
                                                                      onService:service];
            NSLog(@"We need to write for characteristic %@", characteristic);
            
            if(characteristic != nil) {
                [privateDevice.peripheral writeValue:data
                                   forCharacteristic:characteristic
                                                type:CBCharacteristicWriteWithoutResponse];
            }
        }
    }
}


-(void)writeDISSerialNumber:(NSString*)serialNumber toDevice:(NovaliaBLEDevice *)device {
    
    NSLog(@"NovaliaBLEPrivateManager writeDISSerialNumberData %@ toDevice %@", serialNumber, device);
    
    for(NovaliaBLEDevicePrivate *privateDevice in allDevices) {
        if(privateDevice.uuid == device.uuid) {
            NSLog(@"We need to write to peripheral %@", privateDevice.peripheral);
            CBService *service = [self findServiceFromUUID:primaryServiceUUID onPeripheral:privateDevice.peripheral];
            CBCharacteristic *characteristic = [self findCharacteristicFromUUID:primaryServiceSerialNumberCharacteristicUUID
                                                                      onService:service];
            NSLog(@"We need to write for characteristic %@", characteristic);
            
            if(characteristic != nil) {
                
                NSString *correctLengthSerialNumber = [serialNumber stringByPaddingToLength:8 withString:@" " startingAtIndex:0];
                
                NSData *data = [correctLengthSerialNumber dataUsingEncoding:NSUTF8StringEncoding];
                
                [privateDevice.peripheral writeValue:data
                                   forCharacteristic:characteristic
                                                type:CBCharacteristicWriteWithResponse];
                
                [privateDevice.peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
}


// Helper methods added by Andrew Sage

// Converts CBCentralManagerState to a string
+(NSString *)getCBCentralStateName:(CBCentralManagerState) state {
    NSString *stateName;
    
    switch (state) {
        case CBCentralManagerStatePoweredOn:
            stateName = @"Bluetooth Powered On - Ready";
            break;
        case CBCentralManagerStateResetting:
            stateName = @"Resetting";
            break;
            
        case CBCentralManagerStateUnsupported:
            stateName = @"Unsupported";
            break;
            
        case CBCentralManagerStateUnauthorized:
            stateName = @"Unauthorized";
            break;
            
        case CBCentralManagerStatePoweredOff:
            stateName = @"Bluetooth Powered Off";
            break;
            
        default:
            stateName = @"Unknown";
            break;
    }
    return stateName;
}

@end
