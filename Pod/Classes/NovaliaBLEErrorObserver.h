//
//  NovaliaBLEErrorObserver.h
//  BLEInterface
//
//  Created by Adrian Lubik on 05/03/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface NovaliaBLEErrorObserver : NSObject

-(void)logErrorOnPeripheral:(CBPeripheral*)peripheral;

@end
