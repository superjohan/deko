//
//  DekoFunctions.m
//  deko
//
//  Created by Johan Halin on 19.10.2014.
//  Copyright (c) 2014 Aero Deko. All rights reserved.
//

#import "DekoFunctions.h"

DekoDeviceType DekoGetCurrentDeviceType()
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		return DekoDeviceTypeiPad;
	}
	
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat height = MAX(screenBounds.size.width, screenBounds.size.height);
	
	if (height < 481.0)
	{
		return DekoDeviceTypeiPhone;
	}
	else if (height < 569.0)
	{
		return DekoDeviceTypeiPhone5;
	}
	else if (height < 668.0)
	{
		return DekoDeviceTypeiPhone6;
	}
	else
	{
		return DekoDeviceTypeiPhone6Plus;
	}
}

BOOL DekoShouldAutorotate()
{
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

BOOL DekoFloatsAreEqual(float float1, float float2)
{
	float epsilon = 0.00001;
	
	return (float1 < (float2 + epsilon) && float1 > (float2 - epsilon));
}

CGFloat DekoGetSquareOffset()
{
	DekoDeviceType deviceType = DekoGetCurrentDeviceType();
	
	switch (deviceType)
	{
		case DekoDeviceTypeiPad:
			return DekoiPadOffset;
		case DekoDeviceTypeiPhone6Plus:
			return DekoiPhone6PlusOffset;
		case DekoDeviceTypeiPhone6:
			return DekoiPhone6HeightOffset;
		case DekoDeviceTypeiPhone5:
			return DekoiPhoneHeightOffset;
		case DekoDeviceTypeiPhone:
			return DekoiPhone4HeightOffset;
		default:
			AELOG_ERROR(@"Unknown device type: %ld", (long)deviceType);
			return DekoDeviceTypeInvalid;
	}
}