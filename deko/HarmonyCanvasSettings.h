//
//  HarmonyCanvasSettings.h
//  deko
//
//  Created by Johan Halin on 30.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HarmonyShape.h"

typedef NS_ENUM(NSInteger, HarmonyMixingType)
{
	HarmonyMixingTypeSeparate,
	HarmonyMixingTypeOverlap,
	HarmonyMixingTypeOverlay,
	HarmonyMixingTypeEvenOdd,
	HarmonyMixingTypeMask,
	HarmonyMixingTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonyPositionType)
{
	HarmonyPositionTypeFree,
	HarmonyPositionTypeGrid,
	HarmonyPositionTypeStripe,
	HarmonyPositionTypeCluster,
	HarmonyPositionTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonyShapeTransformType)
{
	HarmonyShapeTransformTypeStraight,
	HarmonyShapeTransformTypeStretch,
	HarmonyShapeTransformTypeSkew,
	HarmonyShapeTransformTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonySizeType)
{
	HarmonySizeTypeUniform,
	HarmonySizeTypeVariable,
	HarmonySizeTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonyRotationType)
{
	HarmonyRotationTypeNone,
	HarmonyRotationTypeStraight,
	HarmonyRotationTypeDiagonal,
	HarmonyRotationTypeFree,
	HarmonyRotationTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonyColorType)
{
	HarmonyColorTypeMono,
	HarmonyColorTypeComplement,
	HarmonyColorTypeTriad,
	HarmonyColorTypeTetrad,
	HarmonyColorTypeAnalogic,
	HarmonyColorTypeAccentedAnalogic,
	HarmonyColorTypeCMYK,
	HarmonyColorTypeMondrian,
	HarmonyColorTypePrintCMYK,
	HarmonyColorTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonyColorBrightnessType)
{
	HarmonyColorBrightnessTypeNormal = 0,
	HarmonyColorBrightnessType1,
	HarmonyColorBrightnessType2,
	HarmonyColorBrightnessType3,
	HarmonyColorBrightnessTypeMax,
};

typedef NS_ENUM(NSInteger, HarmonyColorSaturationType)
{
	HarmonyColorSaturationTypeNormal = 0,
	HarmonyColorSaturationType1,
	HarmonyColorSaturationType2,
	HarmonyColorSaturationType3,
	HarmonyColorSaturationTypeMax,
};

static const CGFloat kMinimumShapeSize = 25.0;
static const NSInteger kMaximumDistance = 20;

@interface HarmonyCanvasSettings : NSObject <NSCopying>
@property (nonatomic, assign) HarmonyMixingType mixingType;
@property (nonatomic, assign) HarmonyPositionType positionType;
@property (nonatomic, assign) HarmonyShapeTransformType transformType;
@property (nonatomic, assign) HarmonySizeType sizeType;
@property (nonatomic, assign) HarmonyRotationType rotationType;
@property (nonatomic, assign) HarmonyShapeType shapeType;
@property (nonatomic, assign) HarmonyColorType colorType;
@property (nonatomic, assign) HarmonyColorBrightnessType brightnessType;
@property (nonatomic, assign) HarmonyColorSaturationType saturationType;
@property (nonatomic, assign) CGFloat hue;
@property (nonatomic, assign) CGFloat baseSize;
@property (nonatomic, assign) CGFloat baseDistance;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat background1Hue;
@property (nonatomic, assign) CGFloat background1Saturation;
@property (nonatomic, assign) CGFloat background1Brightness;
@property (nonatomic, assign) CGFloat background2Hue;
@property (nonatomic, assign) CGFloat background2Saturation;
@property (nonatomic, assign) CGFloat background2Brightness;
@end
