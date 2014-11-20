//
//  DekoIAPManager.m
//  deko
//
//  Created by Johan Halin on 29.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoIAPManager.h"

NSString * const DekoIAPManagerProPriceUpdatedNotification = @"DekoIAPManagerProPriceUpdatedNotification";
NSString * const DekoIAPManagerProVersionPurchasedNotification = @"DekoIAPManagerProVersionPurchasedNotification";

@implementation DekoIAPManager

#pragma mark - Public

- (void)startManager
{
	// Implementation removed
}

- (void)purchaseProVersion:(void (^)(NSError *error))completionBlock
{
	// Implementation removed
}

- (NSString *)priceForProVersion
{
	// Implementation removed

	return @"FREE LOL";
}

- (void)restorePurchases
{
	// Implementation removed
}

#pragma mark - Properties

- (BOOL)proPurchased
{
	// Implementation removed

	return YES;
}

@end
