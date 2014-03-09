//
//  DekoShareHelper.h
//  deko
//
//  Created by Johan Halin on 4.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DekoMenuView.h"

@class DekoShareHelper;
@class DekoLocalizationManager;

@protocol DekoShareHelperDelegate <NSObject>

@required
- (void)shareHelper:(DekoShareHelper *)shareHelper wantsToShowViewController:(UIViewController *)viewController;
- (void)shareHelper:(DekoShareHelper *)shareHelper savedImageWithError:(NSError *)error;

@end

@interface DekoShareHelper : NSObject

@property (nonatomic, weak) NSObject<DekoShareHelperDelegate> *delegate;
@property (nonatomic) DekoLocalizationManager *localizationManager;

- (void)shareImage:(UIImage *)image shareType:(DekoShareType)shareType proPurchased:(BOOL)proPurchased;

@end
