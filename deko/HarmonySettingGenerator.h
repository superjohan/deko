//
//  HarmonySettingGenerator.h
//  deko
//
//  Created by Johan Halin on 30.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger kMaximumSettingSteps = 6;

@class HarmonyCanvasSettings;
@class HarmonyColorGenerator;

@interface HarmonySettingGenerator : NSObject

@property (nonatomic) HarmonyColorGenerator *colorGenerator;

- (HarmonyCanvasSettings *)generateNewSettings;
- (HarmonyCanvasSettings *)generateNewSettingsBasedOnSettings:(HarmonyCanvasSettings *)settings step:(NSInteger)step;

@end
