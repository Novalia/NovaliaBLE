#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CBUUID+CBUUIDWithInteger.h"
#import "NovaliaBLEConnectTimeoutHelper.h"
#import "NovaliaBLEConstants.h"
#import "NovaliaBLEDevice.h"
#import "NovaliaBLEDevicePrivate.h"
#import "NovaliaBLEErrorObserver.h"
#import "NovaliaBLEErrorObserverDelegate.h"
#import "NovaliaBLEInterface.h"
#import "NovaliaBLEInterfaceDelegate.h"
#import "NovaliaBLEPrivateConstants.h"
#import "NovaliaBLEPrivateManager.h"

FOUNDATION_EXPORT double NovaliaBLEVersionNumber;
FOUNDATION_EXPORT const unsigned char NovaliaBLEVersionString[];

