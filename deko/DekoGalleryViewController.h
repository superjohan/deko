//
//  DekoGalleryViewController.h
//  deko
//
//  Created by Johan Halin on 5.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DekoSceneManager;
@class DekoGalleryViewController;
@class DekoScene;
@class DekoLocalizationManager;

@protocol DekoGalleryViewControllerDelegate <NSObject>

@required
- (void)galleryViewController:(DekoGalleryViewController *)galleryViewController selectedScene:(DekoScene *)scene;

@end

@interface DekoGalleryViewController : UIViewController

@property (nonatomic, weak) NSObject<DekoGalleryViewControllerDelegate> *delegate;
@property (nonatomic) DekoSceneManager *sceneManager;
@property (nonatomic) DekoLocalizationManager *localizationManager;

@end
