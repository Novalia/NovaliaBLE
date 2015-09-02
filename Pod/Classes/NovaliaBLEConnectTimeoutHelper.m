//
//  NovaliaBLEConnectTimeoutHelper.m
//  BLEInterface
//
//  Created by Adrian Lubik on 06/03/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#import "NovaliaBLEConnectTimeoutHelper.h"

@interface NovaliaBLEConnectTimeoutHelper()

@property CBPeripheral *peripheral;
@property NSTimer *timer;

@end



@implementation NovaliaBLEConnectTimeoutHelper

@synthesize peripheral;
@synthesize timer;
@synthesize delegate;

-(NovaliaBLEConnectTimeoutHelper*)initWithPeripheral:(CBPeripheral*)p andTimeout:(NSTimeInterval)t {
    self = [super init];
    
    if (self) {
        peripheral = p;
        timer = [NSTimer timerWithTimeInterval:t target:self selector:@selector(onTimeout) userInfo:nil repeats:NO];
    }
    
    return self;
}

-(void)cancel {
    if ([timer isValid]) {
        [timer invalidate];
    }
}

-(void)start {
    NSLog(@"\n\nTIMER START");
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

-(void)onTimeout {
    NSLog(@"did timeout");
    [delegate didTimeOut:self];
}

@end
