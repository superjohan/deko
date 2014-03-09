//
//  DekoIAPManager.h
//  deko
//
//  Created by Johan Halin on 29.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const DekoIAPManagerProPriceUpdatedNotification;
extern NSString * const DekoIAPManagerProVersionPurchasedNotification;

@interface DekoIAPManager : NSObject

@property (nonatomic, assign, readonly) BOOL proPurchased;

- (void)startManager;
- (void)purchaseProVersion:(void (^)(NSError *error))completionBlock;
- (NSString *)priceForProVersion;
- (void)restorePurchases;

@end
