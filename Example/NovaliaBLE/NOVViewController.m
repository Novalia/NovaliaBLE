//
//  NOVViewController.m
//  NovaliaBLE
//
//  Created by Andrew Sage on 09/02/2015.
//  Copyright (c) 2015 Andrew Sage. All rights reserved.
//

#import "NOVViewController.h"
#import "NovaliaBLEInterface.h"

@interface NOVViewController () <NovaliaBLEInterfaceDelegate, NovaliaBLEDeviceEventDelegate>

@property NovaliaBLEInterface *interface;
@property NSTimer *launchDiscoveryTimer;
@property NovaliaBLEState previousBLEState;


@end

@implementation NOVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initInterfaceIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)initInterfaceIfNeeded {
    if (self.interface == nil) {
        self.interface = [[NovaliaBLEInterface alloc] initWithDelegate:self];
        self.previousBLEState = -1;
        self.launchDiscoveryTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startDiscovery) userInfo:nil repeats:NO];
    }
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView startAnimating];
}

-(void)startDiscovery {
    self.launchDiscoveryTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(stopDiscovery) userInfo:nil repeats:NO];
    [self.interface startDeviceDiscovery];
}

-(void)stopDiscovery {
    self.launchDiscoveryTimer = nil;
    if (self.interface.delegate == self) {
        [self.interface stopDeviceDiscovery];
    }
}

@end
