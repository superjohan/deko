//
//  DekoAppDelegate.h
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DekoViewController;

@interface DekoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DekoViewController *viewController;

@end
