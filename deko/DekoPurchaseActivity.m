//
//  DekoPurchaseActivity.m
//  deko
//
//  Created by Johan Halin on 29.9.2021.
//  Copyright © 2021 Aero Deko. All rights reserved.
//

#import "DekoPurchaseActivity.h"
#import "DekoIAPViewController.h"

@implementation DekoPurchaseActivity

+ (UIActivityCategory)activityCategory
{
	return UIActivityCategoryAction;
}

- (NSString *)activityTitle
{
	return NSLocalizedString(@"High quality export", @"Unlock high quality export button title");
}

- (UIImage *)activityImage
{
	// FIXME
	return [UIImage imageNamed:@"button-galle-iphone"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return YES;
}

- (UIViewController *)activityViewController
{
	return [[DekoIAPViewController alloc] init];
}

@end
