//
//  DekoIAPViewController.h
//  deko
//
//  Created by Johan Halin on 7.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DekoIAPManager;
@class DekoIAPViewController;
@class DekoLocalizationManager;

@protocol DekoIAPViewControllerDelegate <NSObject>

@required
- (void)iapViewController:(DekoIAPViewController *)iapViewController completedPurchaseWithError:(NSError *)error;

@end

@interface DekoIAPViewController : UIViewController

@property (nonatomic, weak) NSObject<DekoIAPViewControllerDelegate> *delegate;
@property (nonatomic) DekoIAPManager *purchaseManager;
@property (nonatomic) DekoLocalizationManager *localizationManager;

@end
