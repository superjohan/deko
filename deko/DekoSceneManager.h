//
//  DekoSceneManager.h
//  deko
//
//  Created by Johan Halin on 4.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HarmonyCanvasSettings;
@class DekoScene;

@interface DekoSceneManager : NSObject

@property (nonatomic, readonly, copy) NSArray *allScenes;

- (NSString *)sceneIDBySavingSceneWithCanvasSettings:(HarmonyCanvasSettings *)settings thumbnail:(UIImage *)image;
- (void)deleteSceneWithID:(NSString *)sceneID;
- (DekoScene *)sceneWithID:(NSString *)sceneID;
- (void)loadThumbnailForSceneID:(NSString *)sceneID completion:(void (^)(UIImage *thumbnail))completion;

@end
