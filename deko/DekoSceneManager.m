//
//  DekoSceneManager.m
//  deko
//
//  Created by Johan Halin on 4.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoSceneManager.h"
#import "DekoScene.h"
#import "HarmonyCanvasSettings.h"

NSString * const DekoSettingMixingTypeKey = @"mixingType";
NSString * const DekoSettingPositionTypeKey = @"positionType";
NSString * const DekoSettingTransformTypeKey = @"transformType";
NSString * const DekoSettingSizeTypeKey = @"sizeType";
NSString * const DekoSettingRotationTypeKey = @"rotationType";
NSString * const DekoSettingShapeTypeKey = @"shapeType";
NSString * const DekoSettingColorTypeKey = @"colorType";
NSString * const DekoSettingColorBrightnessTypeKey = @"brightnessType";
NSString * const DekoSettingColorSaturationTypeKey = @"saturationType";
NSString * const DekoSettingHueKey = @"hue";
NSString * const DekoSettingBaseSizeKey = @"baseSize";
NSString * const DekoSettingBaseDistanceKey = @"baseDistance";
NSString * const DekoSettingAngleKey = @"angle";
NSString * const DekoSettingBackground1HueKey = @"background1Hue";
NSString * const DekoSettingBackground1SaturationKey = @"background1Saturation";
NSString * const DekoSettingBackground1BrightnessKey = @"background1Brightness";
NSString * const DekoSettingBackground2HueKey = @"background2Hue";
NSString * const DekoSettingBackground2SaturationKey = @"background2Saturation";
NSString * const DekoSettingBackground2BrightnessKey = @"background2Brightness";

NSString * const DekoSceneSettingKey = @"kDekoSceneSettingKey";
NSString * const DekoSceneIDKey = @"kDekoSceneIDKey";

NSString * const DekoSceneManagerIndexKey = @"kDekoSceneManagerIndexKey";

@interface DekoSceneManager ()
@property (nonatomic) NSString *documentPath;
@property (nonatomic) dispatch_queue_t fileQueue;
@end

@implementation DekoSceneManager

#pragma mark - Private

- (NSString *)_documentDirectoryPath
{
	if (self.documentPath != nil)
	{
		return self.documentPath;
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	AEAssertV(paths != nil && [paths count] > 0, nil);
	NSString *path = paths[0];
	
	self.documentPath = path;
	
	return path;
}

- (NSString *)_pathForSceneID:(NSString *)sceneID
{
	AEAssertV(sceneID != nil, nil);
	
	NSString *path = [self _documentDirectoryPath];
	NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.deko", sceneID]];
	
	return fullPath;
}

- (NSString *)_pathForThumbnailWithSceneID:(NSString *)sceneID
{
	AEAssertV(sceneID != nil, nil);
	
	NSString *path = [self _documentDirectoryPath];
	NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", sceneID]];
	
	return fullPath;
}

#pragma mark - NSObject

- (instancetype)init
{
	if ((self = [super init]))
	{
		_fileQueue = dispatch_queue_create("com.aerodeko.deko.filequeue", NULL);
	}
	
	return self;
}

#pragma mark - Public

- (NSString *)sceneIDBySavingSceneWithCanvasSettings:(HarmonyCanvasSettings *)settings thumbnail:(UIImage *)image
{
	AEAssertV(settings != nil, nil);
	AEAssertV(image != nil, nil);
	
	NSData *thumbnailData = UIImagePNGRepresentation(image);
	NSString *sceneID = [[NSProcessInfo processInfo] globallyUniqueString];
	NSDictionary *settingDictionary = @{
	DekoSettingMixingTypeKey : @(settings.mixingType),
	DekoSettingPositionTypeKey : @(settings.positionType),
	DekoSettingTransformTypeKey : @(settings.transformType),
	DekoSettingSizeTypeKey : @(settings.sizeType),
	DekoSettingRotationTypeKey : @(settings.rotationType),
	DekoSettingShapeTypeKey : @(settings.shapeType),
	DekoSettingColorTypeKey : @(settings.colorType),
	DekoSettingColorBrightnessTypeKey : @(settings.brightnessType),
	DekoSettingColorSaturationTypeKey : @(settings.saturationType),
	DekoSettingHueKey : [NSNumber numberWithDouble:settings.hue],
	DekoSettingBaseSizeKey : [NSNumber numberWithDouble:settings.baseSize],
	DekoSettingBaseDistanceKey : [NSNumber numberWithDouble:settings.baseDistance],
	DekoSettingAngleKey : [NSNumber numberWithDouble:settings.angle],
	DekoSettingBackground1HueKey : [NSNumber numberWithDouble:settings.background1Hue],
	DekoSettingBackground1SaturationKey : [NSNumber numberWithDouble:settings.background1Saturation],
	DekoSettingBackground1BrightnessKey : [NSNumber numberWithDouble:settings.background1Brightness],
	DekoSettingBackground2HueKey : [NSNumber numberWithDouble:settings.background2Hue],
	DekoSettingBackground2SaturationKey : [NSNumber numberWithDouble:settings.background2Saturation],
	DekoSettingBackground2BrightnessKey : [NSNumber numberWithDouble:settings.background2Brightness],
	};
	
	NSDictionary *sceneDictionary = @{
	DekoSceneIDKey : sceneID,
	DekoSceneSettingKey : settingDictionary
	};
		
	NSString *path = [self _pathForSceneID:sceneID];
	
	if ([sceneDictionary writeToFile:path atomically:YES])
	{
		AELOG_DEBUG(@"Scene information saved successfully to '%@'.", path);
		
		NSString *thumbnailPath = [self _pathForThumbnailWithSceneID:sceneID];
		
		if ([thumbnailData writeToFile:thumbnailPath atomically:YES])
		{
			AELOG_DEBUG(@"Thumbnail saved successfully to '%@'.", thumbnailPath);

			NSMutableArray *sceneList = [[[NSUserDefaults standardUserDefaults] arrayForKey:DekoSceneManagerIndexKey] mutableCopy];
			if (sceneList == nil)
			{
				AELOG_DEBUG(@"No saved scenes, creating index.");
				
				sceneList = [NSMutableArray array];
			}
			
			[sceneList addObject:sceneID];
			[[NSUserDefaults standardUserDefaults] setObject:sceneList forKey:DekoSceneManagerIndexKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		else
		{
			AELOG_ERROR(@"Writing thumbnail information to '%@' failed.", thumbnailPath);
		}
		
	}
	else
	{
		AELOG_ERROR(@"Writing scene information to '%@' failed.", path);
	}
	
	return sceneID;
}

- (void)deleteSceneWithID:(NSString *)sceneID
{
	AEAssert(sceneID != nil);
	
	NSString *scenePath = [self _pathForSceneID:sceneID];
	NSString *thumbnailPath = [self _pathForThumbnailWithSceneID:sceneID];
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] removeItemAtPath:scenePath error:&error])
	{
		AELOG_DEBUG(@"Scene at path '%@' removed successfully.", scenePath);
	}
	else
	{
		AELOG_ERROR(@"Removing scene at path '%@' failed with error: %@", scenePath, [error localizedDescription]);
	}
	
	if ([[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:&error])
	{
		AELOG_DEBUG(@"Thumbnail at path '%@' removed successfully.", thumbnailPath);
	}
	else
	{
		AELOG_ERROR(@"Removing thumbnail at path '%@' failed with error: %@", thumbnailPath, [error localizedDescription]);
	}
	
	NSMutableArray *sceneList = [[[NSUserDefaults standardUserDefaults] arrayForKey:DekoSceneManagerIndexKey] mutableCopy];
	[sceneList removeObject:sceneID];
	[[NSUserDefaults standardUserDefaults] setObject:sceneList forKey:DekoSceneManagerIndexKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (DekoScene *)sceneWithID:(NSString *)sceneID
{
	AEAssertV(sceneID != nil && [sceneID length] > 0, nil);

	NSString *path = [self _pathForSceneID:sceneID];
	NSDictionary *sceneDictionary = [NSDictionary dictionaryWithContentsOfFile:[self _pathForSceneID:sceneID]];
	DekoScene *scene = nil;
	
	if (sceneDictionary != nil)
	{
		scene = [[DekoScene alloc] init];
		scene.id = sceneDictionary[DekoSceneIDKey];
		
		NSDictionary *settingDictionary = sceneDictionary[DekoSceneSettingKey];
		
		HarmonyCanvasSettings *settings = [[HarmonyCanvasSettings alloc] init];
		settings.mixingType = [settingDictionary[DekoSettingMixingTypeKey] integerValue];
		settings.positionType = [settingDictionary[DekoSettingPositionTypeKey] integerValue];
		settings.transformType = [settingDictionary[DekoSettingTransformTypeKey] integerValue];
		settings.sizeType = [settingDictionary[DekoSettingSizeTypeKey] integerValue];
		settings.rotationType = [settingDictionary[DekoSettingRotationTypeKey] integerValue];
		settings.shapeType = [settingDictionary[DekoSettingShapeTypeKey] integerValue];
		settings.colorType = [settingDictionary[DekoSettingColorTypeKey] integerValue];
		settings.brightnessType = [settingDictionary[DekoSettingColorBrightnessTypeKey] integerValue];
		settings.saturationType = [settingDictionary[DekoSettingColorSaturationTypeKey] integerValue];
		settings.hue = [settingDictionary[DekoSettingHueKey] doubleValue];
		settings.baseSize = [settingDictionary[DekoSettingBaseSizeKey] doubleValue];
		settings.baseDistance = [settingDictionary[DekoSettingBaseDistanceKey] doubleValue];
		settings.angle = [settingDictionary[DekoSettingAngleKey] doubleValue];
		settings.background1Hue = [settingDictionary[DekoSettingBackground1HueKey] doubleValue];
		settings.background1Saturation = [settingDictionary[DekoSettingBackground1SaturationKey] doubleValue];
		settings.background1Brightness = [settingDictionary[DekoSettingBackground1BrightnessKey] doubleValue];
		settings.background2Hue = [settingDictionary[DekoSettingBackground2HueKey] doubleValue];
		settings.background2Saturation = [settingDictionary[DekoSettingBackground2SaturationKey] doubleValue];
		settings.background2Brightness = [settingDictionary[DekoSettingBackground2BrightnessKey] doubleValue];
		
		scene.settings = settings;
	}
	else
	{
		AELOG_ERROR(@"Scene file '%@' not found.", path);
	}
	
	return scene;
}

- (NSArray *)allScenes
{
	NSArray *sceneIDs = [[NSUserDefaults standardUserDefaults] objectForKey:DekoSceneManagerIndexKey];
	NSMutableArray *scenes = [NSMutableArray array];
	
	for (NSString *sceneID in sceneIDs)
	{
		DekoScene *scene = [self sceneWithID:sceneID];
		if (scene != nil)
		{
			[scenes addObject:scene];
		}
	}
	
	return scenes;
}

- (void)loadThumbnailForSceneID:(NSString *)sceneID completion:(void (^)(UIImage *thumbnail))completion
{
	AEAssert(sceneID != nil);
	
	dispatch_async(self.fileQueue, ^
	{
		NSString *path = [self _pathForThumbnailWithSceneID:sceneID];
		NSError *error = nil;
		NSData *imageData = [NSData dataWithContentsOfFile:path options:0 error:&error];
		
		if (imageData != nil)
		{
			UIImage *image = [UIImage imageWithData:imageData scale:[[UIScreen mainScreen] scale]];
			
			dispatch_async(dispatch_get_main_queue(), ^
			{
				completion(image);
			});
		}
		else
		{
			AELOG_ERROR(@"Unable to read file at '%@' with error: %@", path, [error localizedDescription]);
			
			dispatch_async(dispatch_get_main_queue(), ^
			{
				completion(nil);
			});
		}
	});
}

@end
