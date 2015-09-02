//
//  NovaliaBLEConstants.h
//  BLEInterface
//
//  Created by Adrian Lubik on 13/02/2014.
//  Copyright (c) 2014 Novalia. All rights reserved.
//

#define NovaliaBLEButtonUnknown -1
#define NovaliaBLEButtonFirst   1
#define NovaliaBLEButtonLast    28

typedef enum {
    BLEStateOff = 1,
    BLEStateOn,
    BLEStateUnsupported,
    BLEStateNotReady
} NovaliaBLEState;

/*
typedef enum {
    BTN_UNKNOWN = -1,
    BTN_1 = 1,
    BTN_2,
    BTN_3,
    BTN_4,
    BTN_5,
    BTN_6,
    BTN_7,
    BTN_8,
    BTN_9,
    BTN_10,
    BTN_11,
    BTN_12,
    BTN_13,
    BTN_14,
    BTN_15,
    BTN_16,
    BTN_17,
    BTN_18,
    BTN_19,
    BTN_20
} Button;
*/
