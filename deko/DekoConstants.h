//
//  DekoConstants.h
//  deko
//
//  Created by Johan Halin on 7.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

static const CGFloat DekoBackgroundColor = 0.93;
static const CGFloat DekoThumbnailSize = 100.0;
static const CGFloat DekoLaunchBackgroundColor = 0.1568627451;
static const CGFloat DekoiPadOffset = 238.0;
static const CGFloat DekoiPhone6PlusOffset = ((2662.0 - 2208.0) / 3.0); // whee
static const CGFloat DekoiPhone6WidthOffset = 51.0;
static const CGFloat DekoiPhone6HeightOffset = 137.0;
static const CGFloat DekoiPhoneWidthOffset = 52.0;
static const CGFloat DekoiPhoneHeightOffset = 128.0;
static const CGFloat DekoiPhone4WidthOffset = 50.0;
static const CGFloat DekoiPhone4HeightOffset = 118.0;
static const NSTimeInterval DekoLogoAnimationDuration = 2.0;

typedef NS_ENUM(NSInteger, DekoDeviceType)
{
	DekoDeviceTypeInvalid,
	DekoDeviceTypeiPad,
	DekoDeviceTypeiPhone6Plus,
	DekoDeviceTypeiPhone6,
	DekoDeviceTypeiPhone5,
	DekoDeviceTypeiPhone,
};
