//
//  DekoScene.h
//  deko
//
//  Created by Johan Halin on 4.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HarmonyCanvasSettings;

@interface DekoScene : NSObject

@property (nonatomic) HarmonyCanvasSettings *settings;
@property (nonatomic) NSString *id;

@end
