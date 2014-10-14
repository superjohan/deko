//
//  HarmonySettingGenerator.m
//  deko
//
//  Created by Johan Halin on 30.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "HarmonySettingGenerator.h"
#import "HarmonyCanvasSettings.h"
#import "HarmonyColorGenerator.h"

@implementation HarmonySettingGenerator

#pragma mark - Private

- (HarmonyCanvasSettings *)_generateNewSettingsBasedOnSettings:(HarmonyCanvasSettings *)oldSettings
													mixingType:(BOOL)mixingType
												  positionType:(BOOL)positionType
												 transformType:(BOOL)transformType
													  sizeType:(BOOL)sizeType
												  rotationType:(BOOL)rotationType
													 shapeType:(BOOL)shapeType
													 colorType:(BOOL)colorType
												brightnessType:(BOOL)brightnessType
												saturationType:(BOOL)saturationType
														   hue:(BOOL)hue
													  baseSize:(BOOL)baseSize
												  baseDistance:(BOOL)baseDistance
														 angle:(BOOL)angle
											   backgroundColor:(BOOL)backgroundColor
												  allowStripes:(BOOL)allowStripes
{
	AEAssertV(oldSettings != nil, nil);
	
	HarmonyCanvasSettings *settings = [oldSettings copy];
	
	if (mixingType)
	{
		do
		{
			settings.mixingType = arc4random() % HarmonyMixingTypeMax;
		}
		while (settings.mixingType == oldSettings.mixingType);
	}
	
	if (positionType)
	{
		if (allowStripes)
		{
			do
			{
				settings.positionType = arc4random() % HarmonyPositionTypeMax;
			}
			while (settings.positionType == oldSettings.positionType);
		}
		else
		{
			do
			{
				settings.positionType = arc4random() % HarmonyPositionTypeMax;
			}
			while (settings.positionType == oldSettings.positionType || settings.positionType == HarmonyPositionTypeStripe);
		}
	}
	
	if (transformType)
	{
		do
		{
			settings.transformType = arc4random() % HarmonyShapeTransformTypeMax;
		}
		while (settings.transformType == oldSettings.transformType);
	}
	
	if (sizeType)
	{
		do
		{
			settings.sizeType = arc4random() % HarmonySizeTypeMax;
		}
		while (settings.sizeType == oldSettings.sizeType);
	}
	
	if (rotationType)
	{
		do
		{
			settings.rotationType = arc4random() % HarmonyRotationTypeMax;
		}
		while (settings.rotationType == oldSettings.rotationType);
	}
	
	if (shapeType)
	{
		do
		{
			settings.shapeType = arc4random() % HarmonyShapeTypeMax;
		}
		while (settings.shapeType == oldSettings.shapeType);
	}
	
	if (colorType)
	{
		do
		{
			settings.colorType = arc4random() % HarmonyColorTypeMax;
		}
		while (settings.colorType == oldSettings.colorType);
	}
	
	if (brightnessType)
	{
		do
		{
			settings.brightnessType = arc4random() % HarmonyColorBrightnessTypeMax;
		}
		while (settings.brightnessType == oldSettings.brightnessType);
	}
	
	if (saturationType)
	{
		do
		{
			settings.saturationType = arc4random() % HarmonyColorSaturationTypeMax;
		}
		while (settings.saturationType == oldSettings.saturationType);
	}
	
	if (hue)
	{
		settings.hue = (arc4random() % 1000000) / 1000000.0;		
	}
	
	if (backgroundColor)
	{
		UIColor *backgroundColor1 = [self.colorGenerator colorWithStartingHue:settings.hue colorType:settings.colorType brightnessType:settings.brightnessType saturationType:settings.saturationType mixingType:settings.mixingType background:YES];
		UIColor *backgroundColor2 = [self.colorGenerator colorWithStartingHue:settings.hue colorType:settings.colorType brightnessType:settings.brightnessType saturationType:settings.saturationType mixingType:settings.mixingType background:YES];
		CGFloat hue1 = 0;
		CGFloat saturation1 = 0;
		CGFloat brightness1 = 0;
		CGFloat hue2 = 0;
		CGFloat saturation2 = 0;
		CGFloat brightness2 = 0;
		[backgroundColor1 getHue:&hue1 saturation:&saturation1 brightness:&brightness1 alpha:NULL];
		[backgroundColor2 getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:NULL];
		
		settings.background1Hue = hue1;
		settings.background1Saturation = saturation1;
		settings.background1Brightness = brightness1;
		settings.background2Hue = hue2;
		settings.background2Saturation = saturation2;
		settings.background2Brightness = brightness2;
	}
	
	if (baseSize)
	{
		CGSize screenSize = [[UIScreen mainScreen] bounds].size;
		CGFloat maximumShapeSizeOffset = MIN(screenSize.width, screenSize.height);
		
		settings.baseSize = (CGFloat)(kMinimumShapeSize + (arc4random() % (NSInteger)maximumShapeSizeOffset));
		
		if (settings.positionType == HarmonyPositionTypeCluster && settings.baseSize < maximumShapeSizeOffset * .5)
		{
			settings.baseSize = maximumShapeSizeOffset * .5;
		}
	}
	
	if (baseDistance)
	{
		settings.baseDistance = (CGFloat)(arc4random() % kMaximumDistance);

		if (settings.shapeType == HarmonyShapeTypeCircle)
		{
			settings.baseDistance -= (kMaximumDistance / 2);
		}
	}
	
	if (angle)
	{
		NSInteger maximumRotation = (NSInteger)((M_PI * 2.0) * 1000000);
		CGFloat angleValue = (arc4random() % maximumRotation) / 1000000.0;
		
		settings.angle = angleValue;
	}
	
	return settings;
}

- (HarmonyCanvasSettings *)_generateNewSettingsBasedOnSettings:(HarmonyCanvasSettings *)settings
{
	AEAssertV(settings != nil, nil);
		
	return [self _generateNewSettingsBasedOnSettings:settings
										  mixingType:YES
										positionType:YES
									   transformType:YES
											sizeType:YES
										rotationType:YES
										   shapeType:YES
										   colorType:YES
									  brightnessType:YES
									  saturationType:YES
												 hue:YES
											baseSize:YES
										baseDistance:YES
											   angle:YES
									 backgroundColor:YES
										allowStripes:YES];
}

#pragma mark - Public

- (HarmonyCanvasSettings *)generateNewSettings
{
	HarmonyCanvasSettings *settings = [[HarmonyCanvasSettings alloc] init];
	
	return [self _generateNewSettingsBasedOnSettings:settings];
}

- (HarmonyCanvasSettings *)generateNewSettingsBasedOnSettings:(HarmonyCanvasSettings *)settings step:(NSInteger)step
{
	AEAssertV(settings != nil, nil);
	AEAssertV(step >= 0 && step <= kMaximumSettingSteps, nil);
	
	AELOG_DEBUG(@"step: %ld", (long)step);
	
	BOOL mixingType = NO;
	BOOL positionType = NO;
	BOOL transformType = NO;
	BOOL sizeType = NO;
	BOOL rotationType = NO;
	BOOL shapeType = NO;
	BOOL colorType = NO;
	BOOL brightnessType = NO;
	BOOL saturationType = NO;
	BOOL hue = NO;
	BOOL baseSize = NO;
	BOOL baseDistance = NO;
	BOOL angle = NO;
	BOOL backgroundColor = NO;
	BOOL allowStripes = NO;
	
	if (step > 0)
	{
		backgroundColor = YES;
	}
	
	if (step > 1)
	{
		hue = YES;
		colorType = YES;
		brightnessType = YES;
		saturationType = YES;
	}
	
	if (step > 2)
	{
		sizeType = YES;
		baseSize = YES;
		baseDistance = YES;
		angle = YES;
	}
	
	if (step > 3)
	{
		rotationType = YES;
		transformType = YES;

		if (settings.positionType != HarmonyPositionTypeStripe)
		{
			positionType = YES;
		}
	}
	
	if (step > 4)
	{
		mixingType = YES;
	}
	
	if (step > 5)
	{
		return [self _generateNewSettingsBasedOnSettings:settings];
	}
	
	return [self _generateNewSettingsBasedOnSettings:settings
										  mixingType:mixingType
										positionType:positionType
									   transformType:transformType
											sizeType:sizeType
										rotationType:rotationType
										   shapeType:shapeType
										   colorType:colorType
									  brightnessType:brightnessType
									  saturationType:saturationType
												 hue:hue
											baseSize:baseSize
										baseDistance:baseDistance
											   angle:angle
									 backgroundColor:backgroundColor
										allowStripes:allowStripes];
}

@end
