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
	
	CGRect screenBounds = [[UIScreen mainScreen] nativeBounds];
	CGFloat width = MIN(screenBounds.size.width, screenBounds.size.height);
	CGFloat height = MAX(screenBounds.size.width, screenBounds.size.height);
	
	if (width > 639.0 && width < 743.0)
	{
		if (height < 1135.0)
		{
			return DekoDeviceTypeiPhone;
		}
		else
		{
			return DekoDeviceTypeiPhone5;
		}
	}
	else if (width > 743.0 && width < 1079.0)
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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
	
	return (DekoGetCurrentDeviceType() == DekoDeviceTypeiPhone6Plus);
}
