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

NSString * const kDekoSettingMixingTypeKey = @"mixingType";
NSString * const kDekoSettingPositionTypeKey = @"positionType";
NSString * const kDekoSettingTransformTypeKey = @"transformType";
NSString * const kDekoSettingSizeTypeKey = @"sizeType";
NSString * const kDekoSettingRotationTypeKey = @"rotationType";
NSString * const kDekoSettingShapeTypeKey = @"shapeType";
NSString * const kDekoSettingColorTypeKey = @"colorType";
NSString * const kDekoSettingColorBrightnessTypeKey = @"brightnessType";
NSString * const kDekoSettingColorSaturationTypeKey = @"saturationType";
NSString * const kDekoSettingHueKey = @"hue";
NSString * const kDekoSettingBaseSizeKey = @"baseSize";
NSString * const kDekoSettingBaseDistanceKey = @"baseDistance";
NSString * const kDekoSettingAngleKey = @"angle";
NSString * const kDekoSettingBackground1HueKey = @"background1Hue";
NSString * const kDekoSettingBackground1SaturationKey = @"background1Saturation";
NSString * const kDekoSettingBackground1BrightnessKey = @"background1Brightness";
NSString * const kDekoSettingBackground2HueKey = @"background2Hue";
NSString * const kDekoSettingBackground2SaturationKey = @"background2Saturation";
NSString * const kDekoSettingBackground2BrightnessKey = @"background2Brightness";

NSString * const kDekoSceneSettingKey = @"kDekoSceneSettingKey";
NSString * const kDekoSceneIDKey = @"kDekoSceneIDKey";

NSString * const kDekoSceneManagerIndexKey = @"kDekoSceneManagerIndexKey";

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

- (id)init
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
	kDekoSettingMixingTypeKey : [NSNumber numberWithInteger:settings.mixingType],
	kDekoSettingPositionTypeKey : [NSNumber numberWithInteger:settings.positionType],
	kDekoSettingTransformTypeKey : [NSNumber numberWithInteger:settings.transformType],
	kDekoSettingSizeTypeKey : [NSNumber numberWithInteger:settings.sizeType],
	kDekoSettingRotationTypeKey : [NSNumber numberWithInteger:settings.rotationType],
	kDekoSettingShapeTypeKey : [NSNumber numberWithInteger:settings.shapeType],
	kDekoSettingColorTypeKey : [NSNumber numberWithInteger:settings.colorType],
	kDekoSettingColorBrightnessTypeKey : [NSNumber numberWithInteger:settings.brightnessType],
	kDekoSettingColorSaturationTypeKey : [NSNumber numberWithInteger:settings.saturationType],
	kDekoSettingHueKey : [NSNumber numberWithDouble:settings.hue],
	kDekoSettingBaseSizeKey : [NSNumber numberWithDouble:settings.baseSize],
	kDekoSettingBaseDistanceKey : [NSNumber numberWithDouble:settings.baseDistance],
	kDekoSettingAngleKey : [NSNumber numberWithDouble:settings.angle],
	kDekoSettingBackground1HueKey : [NSNumber numberWithDouble:settings.background1Hue],
	kDekoSettingBackground1SaturationKey : [NSNumber numberWithDouble:settings.background1Saturation],
	kDekoSettingBackground1BrightnessKey : [NSNumber numberWithDouble:settings.background1Brightness],
	kDekoSettingBackground2HueKey : [NSNumber numberWithDouble:settings.background2Hue],
	kDekoSettingBackground2SaturationKey : [NSNumber numberWithDouble:settings.background2Saturation],
	kDekoSettingBackground2BrightnessKey : [NSNumber numberWithDouble:settings.background2Brightness],
	};
	
	NSDictionary *sceneDictionary = @{
	kDekoSceneIDKey : sceneID,
	kDekoSceneSettingKey : settingDictionary
	};
		
	NSString *path = [self _pathForSceneID:sceneID];
	
	if ([sceneDictionary writeToFile:path atomically:YES])
	{
		AELOG_DEBUG(@"Scene information saved successfully to '%@'.", path);
		
		NSString *thumbnailPath = [self _pathForThumbnailWithSceneID:sceneID];
		
		if ([thumbnailData writeToFile:thumbnailPath atomically:YES])
		{
			AELOG_DEBUG(@"Thumbnail saved successfully to '%@'.", thumbnailPath);

			NSMutableArray *sceneList = [[[NSUserDefaults standardUserDefaults] arrayForKey:kDekoSceneManagerIndexKey] mutableCopy];
			if (sceneList == nil)
			{
				AELOG_DEBUG(@"No saved scenes, creating index.");
				
				sceneList = [NSMutableArray array];
			}
			
			[sceneList addObject:sceneID];
			[[NSUserDefaults standardUserDefaults] setObject:sceneList forKey:kDekoSceneManagerIndexKey];
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
	
	NSMutableArray *sceneList = [[[NSUserDefaults standardUserDefaults] arrayForKey:kDekoSceneManagerIndexKey] mutableCopy];
	[sceneList removeObject:sceneID];
	[[NSUserDefaults standardUserDefaults] setObject:sceneList forKey:kDekoSceneManagerIndexKey];
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
		scene.id = sceneDictionary[kDekoSceneIDKey];
		
		NSDictionary *settingDictionary = sceneDictionary[kDekoSceneSettingKey];
		
		HarmonyCanvasSettings *settings = [[HarmonyCanvasSettings alloc] init];
		settings.mixingType = [settingDictionary[kDekoSettingMixingTypeKey] integerValue];
		settings.positionType = [settingDictionary[kDekoSettingPositionTypeKey] integerValue];
		settings.transformType = [settingDictionary[kDekoSettingTransformTypeKey] integerValue];
		settings.sizeType = [settingDictionary[kDekoSettingSizeTypeKey] integerValue];
		settings.rotationType = [settingDictionary[kDekoSettingRotationTypeKey] integerValue];
		settings.shapeType = [settingDictionary[kDekoSettingShapeTypeKey] integerValue];
		settings.colorType = [settingDictionary[kDekoSettingColorTypeKey] integerValue];
		settings.brightnessType = [settingDictionary[kDekoSettingColorBrightnessTypeKey] integerValue];
		settings.saturationType = [settingDictionary[kDekoSettingColorSaturationTypeKey] integerValue];
		settings.hue = [settingDictionary[kDekoSettingHueKey] doubleValue];
		settings.baseSize = [settingDictionary[kDekoSettingBaseSizeKey] doubleValue];
		settings.baseDistance = [settingDictionary[kDekoSettingBaseDistanceKey] doubleValue];
		settings.angle = [settingDictionary[kDekoSettingAngleKey] doubleValue];
		settings.background1Hue = [settingDictionary[kDekoSettingBackground1HueKey] doubleValue];
		settings.background1Saturation = [settingDictionary[kDekoSettingBackground1SaturationKey] doubleValue];
		settings.background1Brightness = [settingDictionary[kDekoSettingBackground1BrightnessKey] doubleValue];
		settings.background2Hue = [settingDictionary[kDekoSettingBackground2HueKey] doubleValue];
		settings.background2Saturation = [settingDictionary[kDekoSettingBackground2SaturationKey] doubleValue];
		settings.background2Brightness = [settingDictionary[kDekoSettingBackground2BrightnessKey] doubleValue];
		
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
	NSArray *sceneIDs = [[NSUserDefaults standardUserDefaults] objectForKey:kDekoSceneManagerIndexKey];
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
