//
//  DekoViewController.h
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class DekoIAPManager;
@class DekoShareHelper;
@class DekoSceneManager;
@class HarmonySettingGenerator;
@class DekoGalleryViewController;
@class DekoIAPViewController;
@class HarmonyColorGenerator;

@interface DekoViewController : UIViewController

@property (nonatomic) DekoIAPManager *purchaseManager;
@property (nonatomic) DekoShareHelper *shareHelper;
@property (nonatomic) DekoSceneManager *sceneManager;
@property (nonatomic) DekoGalleryViewController *galleryViewController;
@property (nonatomic) HarmonySettingGenerator *settingGenerator;
@property (nonatomic) DekoIAPViewController *iapViewController;
@property (nonatomic) HarmonyColorGenerator *colorGenerator;

@end
