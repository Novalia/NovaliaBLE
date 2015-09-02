//
//  NovaliaBLEDevicePrivate.m
//  BLEInterface
//
//  Created by Adrian Lubik on 06/03/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import "NovaliaBLEDevicePrivate.h"

@interface NovaliaBLEDevicePrivate()

@property int status;
@property BOOL isRecognised;
@property int deviceType;

@end



@implementation NovaliaBLEDevicePrivate

@synthesize status;
@synthesize isRecognised;
@synthesize deviceType;
@synthesize peripheral;

-(NovaliaBLEDevicePrivate *)initWithPeripheral:(CBPeripheral*)p {
    self = [self initWithUUID:[p identifier]];
    
    if (self) {
        self.peripheral = p;
        self.isRecognised = YES;
        
        [self readDeviceInfoFromPeripheral:p];
    }
    
    return self;
}

-(NovaliaBLEDevicePrivate *)initWithPeripheral:(CBPeripheral*)p andRSSI:(NSNumber*)RSSI {
    self = [self initWithPeripheral:p];
    
    if (self) {
        self.rssi = RSSI;
    }
    
    return self;
}

-(void)updateStatus:(int)s {
    [self setStatus:s];
    
    if ([self.delegate respondsToSelector:@selector(onStatusUpdated:onDevice:)]) {
        [self.delegate onStatusUpdated:s onDevice:self];
    }
}

-(void)updateRSSI:(NSNumber *)RSSI {
    [self setRssi:RSSI];
    
    if ([self.delegate respondsToSelector:@selector(onRSSIUpdated:onDevice:)]) {
        [self.delegate onRSSIUpdated:RSSI onDevice:self];
    }
}

-(void)onButtonPressed:(int)button {
    if ([self.delegate respondsToSelector:@selector(onButtonPressed:onDevice:)]) {
        [self.delegate onButtonPressed:button onDevice:self];
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NovaliaBLEDevicePrivate class]]) {
        return [self.uuid isEqual:[(NovaliaBLEDevicePrivate *) object uuid]];
    }
    
    return [super isEqual:object];
}

-(void)readDeviceInfoFromPeripheral:(CBPeripheral *)p {
    NSString *name = [[p name] lowercaseString];
    NSRegularExpression *rx = [NSRegularExpression regularExpressionWithPattern:@"^nov(p|d|c)(\\S{3})(\\S+)$" options:0 error:nil];
    
    NSTextCheckingResult *match = [rx firstMatchInString:name options:0 range:NSMakeRange(0, [name length])];
    if (match == nil) {
        return;
    }
    
    id mode = [name substringWithRange:[match rangeAtIndex:1]];
    id type = [name substringWithRange:[match rangeAtIndex:2]];
    id version = [name substringWithRange:[match rangeAtIndex:3]];
    
    NSLog(@"mode=%@, type=%@, version=%@", mode, type, version);
    
    if ([@"dru" isEqualToString:type]) {
        [self setDeviceType:NovaliaBLEDeviceTypeDrums];
    } else if ([@"glt" isEqualToString:type]) {
        [self setDeviceType:NovaliaBLEDeviceSoundOfTaste];
    } else if ([@"pia" isEqualToString:type]) {
        [self setDeviceType:NovaliaBLEDeviceTypePiano];
    } else if ([@"vid" isEqualToString:type]) {
        [self setDeviceType:NovaliaBLEDeviceTypeVideo];
    } else if ([@"aud" isEqualToString:type]) {
        [self setDeviceType:NovaliaBLEDeviceTypeAudi];
//    } else if ([@"dru" isEqualToString:type]) {
//        [self setDeviceType:NovaliaBLEDeviceTypeDrums];
    }
}

@end
