//
//  DekoFunctions.h
//  deko
//
//  Created by Johan Halin on 19.10.2014.
//  Copyright (c) 2014 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DekoConstants.h"

extern DekoDeviceType DekoGetCurrentDeviceType(void);
extern BOOL DekoShouldAutorotate(void);
extern BOOL DekoFloatsAreEqual(float float1, float float2);
extern CGFloat DekoGetSquareOffset(void);
