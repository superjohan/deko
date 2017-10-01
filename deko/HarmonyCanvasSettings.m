//
//  HarmonyCanvasSettings.m
//  deko
//
//  Created by Johan Halin on 30.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "HarmonyCanvasSettings.h"

@implementation HarmonyCanvasSettings

- (instancetype)init
{
	if ((self = [super init]))
	{
		_mixingType = HarmonyMixingTypeMax;
		_positionType = HarmonyPositionTypeMax;
		_transformType = HarmonyShapeTransformTypeMax;
		_sizeType = HarmonySizeTypeMax;
		_rotationType = HarmonyRotationTypeMax;
		_shapeType = HarmonyShapeTypeMax;
		_colorType = HarmonyColorTypeMax;
		_brightnessType = HarmonyColorBrightnessTypeMax;
		_saturationType = HarmonyColorSaturationTypeMax;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	id copy = [[[self class] alloc] init];
	
	if (copy != nil)
	{
		[copy setMixingType:self.mixingType];
		[copy setPositionType:self.positionType];
		[copy setTransformType:self.transformType];
		[copy setSizeType:self.sizeType];
		[copy setRotationType:self.rotationType];
		[copy setShapeType:self.shapeType];
		[copy setColorType:self.colorType];
		[copy setBrightnessType:self.brightnessType];
		[copy setSaturationType:self.saturationType];
		[copy setHue:self.hue];
		[copy setBaseSize:self.baseSize];
		[copy setBaseDistance:self.baseDistance];
		[copy setAngle:self.angle];
		[copy setBackground1Hue:self.background1Hue];
		[copy setBackground1Saturation:self.background1Saturation];
		[copy setBackground1Brightness:self.background1Brightness];
		[copy setBackground2Hue:self.background2Hue];
		[copy setBackground2Saturation:self.background2Saturation];
		[copy setBackground2Brightness:self.background2Brightness];
	}
	
	return copy;
}

@end
