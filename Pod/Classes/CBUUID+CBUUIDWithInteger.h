//
//  CBUUID+CBUUIDWithInteger.h
//  BLEInterface
//
//  Created by Adrian Lubik on 14/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

// Don't forget to add the -all_load to you application target in the other linker flags!
// In order for the Categories in the static library to work properly.

@interface CBUUID (CBUUIDWithInteger)

+ (CBUUID *) UUIDWithInteger: (UInt16)integer;

@end
