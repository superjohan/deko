//
//  HarmonyColorGenerator.m
//  harmonyvisualengine
//
//  Created by Johan Halin on 9.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "HarmonyColorGenerator.h"

@implementation HarmonyColorGenerator

- (UIColor *)colorWithStartingHue:(CGFloat)hue
						colorType:(HarmonyColorType)colorType
				   brightnessType:(HarmonyColorBrightnessType)brightnessType
				   saturationType:(HarmonyColorSaturationType)saturationType
					   mixingType:(HarmonyMixingType)mixingType
					   background:(BOOL)background
{
	CGFloat offset = (arc4random() % 100000) / 100000.0;
	CGFloat brightness = background ? offset : offset + 0.55; // "normal" value
	CGFloat saturation = 0.5; // "normal" value

	if (colorType == HarmonyColorTypeComplement)
	{
		CGFloat complementHue = hue + 0.5;
		complementHue = complementHue <= 1.0 ? complementHue: complementHue - 1.0;
		
		NSInteger selection = arc4random() % 2;
		if (selection == 1)
			hue = complementHue;
	}
	else if (colorType == HarmonyColorTypeTriad)
	{
		CGFloat color1 = hue + (1.0 / 3.0);
		color1 = color1 <= 1.0 ? color1 : color1 - 1.0;
		CGFloat color2 = hue + (2.0 / 3.0);
		color2 = color2 <= 1.0 ? color1 : color2 - 1.0;
		NSInteger selection = arc4random() % 3;
		if (selection == 1)
			hue = color1;
		else if (selection == 2)
			hue = color2;
	}
	else if (colorType == HarmonyColorTypeTetrad)
	{
		CGFloat color1 = hue + (1.0 / 4.0);
		color1 = color1 <= 1.0 ? color1 : color1 - 1.0;
		CGFloat color2 = hue + (2.0 / 4.0);
		color2 = color2 <= 1.0 ? color2 : color2 - 1.0;
		CGFloat color3 = hue + (3.0 / 4.0);
		color3 = color3 <= 1.0 ? color3 : color3 - 1.0;
		NSInteger selection = arc4random() % 4;
		if (selection == 1)
			hue = color1;
		else if (selection == 2)
			hue = color2;
		else if (selection == 3)
			hue = color3;
	}
	else if (colorType == HarmonyColorTypeAnalogic)
	{
		CGFloat color1 = hue - (1.0 / 12.0);
		color1 = color1 >= 0.0 ? color1 : color1 + 1.0;
		CGFloat color2 = hue + (1.0 / 12.0);
		color2 = color2 <= 1.0 ? color2 : color2 - 1.0;
		NSInteger selection = arc4random() % 3;
		if (selection == 1)
			hue = color1;
		else if (selection == 2)
			hue = color2;
	}
	else if (colorType == HarmonyColorTypeAccentedAnalogic)
	{
		CGFloat color1 = hue - (1.0 / 12.0);
		color1 = color1 >= 0.0 ? color1 : color1 + 1.0;
		CGFloat color2 = hue + (1.0 / 12.0);
		color2 = color2 <= 1.0 ? color2 : color2 - 1.0;
		CGFloat color3 = hue + 0.5;
		color3 = color3 <= 1.0 ? color3 : color3 - 1.0;
		NSInteger selection = arc4random() % 4;
		if (selection == 1)
			hue = color1;
		else if (selection == 2)
			hue = color2;
		else if (selection == 3)
			hue = color3;
	}
	else if (colorType == HarmonyColorTypeCMYK)
	{
		NSInteger selection = arc4random() % 4;
		if (selection == 0) // cyan
		{
			hue = 0.5;
		}
		else if (selection == 1) // magenta
		{
			hue = (15.0 / 18.0);
		}
		else if (selection == 2) // yellow
		{
			hue = (3.0 / 18.0);
		}
		else // black
		{
			hue = 0;
		}
	}
	else if (colorType == HarmonyColorTypeMondrian)
	{
		NSInteger selection = arc4random() % 5;
		if (selection == 0 || selection == 3 || selection == 4) // red, white, black
		{
			hue = 0;
		}
		else if (selection == 1) // blue
		{
			hue = (2.0 / 3.0);
		}
		else if (selection == 2) // yellow
		{
			hue = (3.0 / 18.0);
		}
	}
	else if (colorType == HarmonyColorTypePrintCMYK)
	{
		NSInteger selection = arc4random() % 4;
		if (selection == 0) // cyan
		{
			hue = (197.0 / 360.0);
			saturation = 1.0;
			brightness = (89.0 / 100.0);
		}
		else if (selection == 1) // magenta
		{
			hue = (327.0 / 360.0);
			saturation = (84.0 / 100.0);
			brightness = (84.0 / 100.0);
		}
		else if (selection == 2) // yellow
		{
			hue = (57.0 / 360.0);
			saturation = 1.0;
			brightness = 1.0;
		}
		else
		{
			hue = (345.0 / 360.0);
			saturation = (11.0 / 100.0);
			brightness = (13.0 / 100.0);
		}
	}
	
	if (colorType == HarmonyColorTypeCMYK)
	{
		brightness = 1.0;
		saturation = 1.0;
		
		if (hue < 0.0001)
		{
			brightness = 0.1;
			saturation = 0;
		}
	}
	else if (colorType == HarmonyColorTypeMondrian)
	{
		if (hue < 0.0001)
		{
			NSInteger selection = arc4random() % 3;
			if (selection == 0) // red
			{
				brightness = 1.0;
				saturation = 1.0;
			}
			else if (selection == 1) // white
			{
				brightness = 1.0;
				saturation = 0;
			}
			else if (selection == 2) // black
			{
				brightness = 0.1;
				saturation = 0;
			}
		}
		else
		{
			brightness = 1.0;
			saturation = 1.0;
		}
	}
	else if (colorType != HarmonyColorTypePrintCMYK)
	{
		if (brightnessType == HarmonyColorBrightnessType1)
		{
			CGFloat hueOffset = (1.0 - ((arc4random() % 200000) / 100000.0)) / 50.0;
			brightness = hue + hueOffset;
			if (brightness < 0.5)
			{
				brightness += 0.5;
			}
		}
		else if (brightnessType == HarmonyColorBrightnessType2)
		{
			NSInteger value = arc4random() % 3;
			brightness = background ? (CGFloat)value / 4.0 : ((CGFloat)value + 2.0) / 4.0;
		}
		else if (brightnessType == HarmonyColorBrightnessType3)
		{
			NSInteger value = arc4random() % 3;
			brightness = value == 0 ? 0.1 : (CGFloat)value / 2.0;
		}
		
		if (saturationType == HarmonyColorSaturationType1)
		{
			saturation = hue;
		}
		else if (saturationType == HarmonyColorSaturationType2)
		{
			saturation = 0;
		}
		else if (saturationType == HarmonyColorSaturationType3)
		{
			saturation = 0.5 + ((arc4random() % 100000) / 100000.0);
		}
		
		if (background && brightness < 0.05)
		{
			brightness += 0.1;
		}
	}
	
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
}

@end
