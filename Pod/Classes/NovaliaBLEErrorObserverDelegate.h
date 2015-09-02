//
//  NovaliaBLEErrorObserverDelegate.h
//  BLEInterface
//
//  Created by Adrian Lubik on 05/03/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol NovaliaBLEErrorObserverDelegate <NSObject>

-(void)shouldAbortUsingPeripheral:(CBPeripheral *)peripheral;

@end
