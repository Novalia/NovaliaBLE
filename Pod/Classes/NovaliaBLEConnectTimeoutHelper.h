//
//  NovaliaBLEConnectTimeoutHelper.h
//  BLEInterface
//
//  Created by Adrian Lubik on 06/03/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol NovaliaBLEConnectTimeoutHelperDelegate <NSObject>

-(void)didTimeOut:(id)helper;

@end



@interface NovaliaBLEConnectTimeoutHelper : NSObject

@property (readonly) CBPeripheral *peripheral;
@property id<NovaliaBLEConnectTimeoutHelperDelegate> delegate;

-(NovaliaBLEConnectTimeoutHelper*)initWithPeripheral:(CBPeripheral*)peripheral andTimeout:(NSTimeInterval)timeout;
-(void)start;
-(void)cancel;

@end


