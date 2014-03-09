//
//  HarmonyStaticView.h
//  harmonyvisualengine
//
//  Created by Johan Halin on 8.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HarmonyColorGenerator;
@class HarmonyCanvasSettings;

@interface HarmonyStaticView : UIView

@property (nonatomic) HarmonyColorGenerator *colorGenerator;

- (void)updateCanvasWithSettings:(HarmonyCanvasSettings *)settings;

@end
