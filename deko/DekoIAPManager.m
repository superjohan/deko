//
//  DekoIAPManager.m
//  deko
//
//  Created by Johan Halin on 29.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoIAPManager.h"

NSString * const DekoProVersionIdentifier = @"com.aerodeko.deko.pro";
NSString * const DekoProVersionPurchasedKey = @"DekoProVersionPurchasedKey";
NSString * const DekoIAPManagerProPriceUpdatedNotification = @"DekoIAPManagerProPriceUpdatedNotification";
NSString * const DekoIAPManagerProVersionPurchasedNotification = @"DekoIAPManagerProVersionPurchasedNotification";

/*
@interface DekoIAPManager () <SKProductsRequestDelegate>
@property (nonatomic) SKProduct *product;
@end
*/

@implementation DekoIAPManager

#pragma mark - Private

- (void)_proPurchased
{
	AELOG_DEBUG(@"");
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DekoProVersionPurchasedKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DekoIAPManagerProVersionPurchasedNotification object:self];
}

#pragma mark - Public

- (void)startManager
{
	/*
	[PFPurchase addObserverForProduct:DekoProVersionIdentifier block:^(SKPaymentTransaction *transaction)
	{
		AELOG_DEBUG(@"%@", transaction);
		
		[self _proPurchased];
	}];
	
	SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:DekoProVersionIdentifier]];
	productRequest.delegate = self;
	[productRequest start];
	 */
}

- (void)purchaseProVersion:(void (^)(NSError *error))completionBlock
{
	/*
	[PFPurchase buyProduct:DekoProVersionIdentifier block:^(NSError *error)
	{
		BOOL success = (error == nil);
		
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"IAP purchase completed" attributes:@{@"success" : [NSNumber numberWithBool:success]}];
		
		completionBlock(error);
	}];
	 */
}

- (NSString *)priceForProVersion
{
	return @"FREE LOL";
	
	/*
	if (self.product == nil)
	{
		AELOG_DEBUG(@"Product not received yet.");
		
		return nil;
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:self.product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:self.product.price];
	
	return formattedString;
	 */
}

- (void)restorePurchases
{
	/*
	[PFPurchase restore];
	 */
}

#pragma mark - Properties

- (BOOL)proPurchased
{
	return YES;

	/* protip for all you jailbreak hackers out there
	 
	BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:DekoProVersionPurchasedKey];
	
	return purchased;
	 */
}

#pragma mark - SKProductsRequestDelegate

/*
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if ([response.invalidProductIdentifiers count])
	{
		AELOG_ERROR(@"Invalid product identifiers: %@", response.invalidProductIdentifiers);
	}
	
	SKProduct *product = [response.products lastObject];
	self.product = product;
	
	AELOG_DEBUG(@"Local pro version price: %@", [self priceForProVersion]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DekoIAPManagerProPriceUpdatedNotification object:self];
}
*/

@end
