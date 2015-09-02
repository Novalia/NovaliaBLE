//
//  CBUUID+CBUUIDWithInteger.m
//  BLEInterface
//
//  Created by Adrian Lubik on 14/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import "CBUUID+CBUUIDWithInteger.h"

@implementation CBUUID (CBUUIDWithInteger)

+ (CBUUID *) UUIDWithInteger: (UInt16)integer {
    UInt16 temp = integer << 8;
    temp |= (integer >> 8);
    integer = temp;
    
    NSData *data = [[NSData alloc] initWithBytes:(const void *)&integer length:sizeof(integer)];
    CBUUID *uuid = [CBUUID UUIDWithData:data];
    
    return uuid;
}

@end
