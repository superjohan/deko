//
//  DekoIAPViewController.m
//  deko
//
//  Created by Johan Halin on 7.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DekoIAPViewController.h"
#import "DekoConstants.h"
#import "DekoIAPManager.h"
#import "DekoIAPPreviewView.h"
#import "DekoLocalizationManager.h"
#import "DekoFunctions.h"

@interface DekoIAPViewController ()
@property (nonatomic) UIButton *backButton;
@property (nonatomic) DekoIAPPreviewView *topContainer;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *iapCopyLabel;
@property (nonatomic) UIButton *purchaseButton;
@property (nonatomic) UIButton *restoreButton;
@property (nonatomic) UIView *busyView;
@end

@implementation DekoIAPViewController

#pragma mark - Private

- (void)_dismiss
{
	[self dismissViewControllerAnimated:YES completion:^
	{
		AELOG_DEBUG(@"IAP view dismissed.");
	}];
}

- (void)_purchaseProVersion
{
	AELOG_DEBUG(@"");

	self.busyView.hidden = NO;
	
	[self.purchaseManager purchaseProVersion:^(NSError *error)
	{
        self.busyView.hidden = YES;
        
		// I know this is wrong but the headers explicitly say that the error is only set if the transaction has failed...
		if (error != nil)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase failed", @"Purchase failed alert, title") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Alert, dismiss button") otherButtonTitles:nil];
			[alert show];
		}
	}];
}

- (void)_proPurchased:(NSNotification *)notification
{
	self.busyView.hidden = YES;
	
	[self.delegate iapViewController:self completedPurchaseWithError:nil];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Thank you.", @"IAP purchased alert, message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Alert, dismiss button") otherButtonTitles:nil];
	[alert show];
	
	[self _dismiss];
}

- (void)_configurePurchaseButtonSizeAnimated:(BOOL)animated
{
	CGSize size = [self.purchaseButton.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.purchaseButton.titleLabel.font }];
	CGFloat minimumSize = 60.0;
	CGFloat padding = 20.0;
	
	if (size.width > minimumSize - padding)
	{
		size.width = size.width + padding;
	}
	else
	{
		size.width = minimumSize;
	}

	void (^animationBlock)() = ^
	{
		CGFloat offset = DekoGetCurrentDeviceType() == DekoDeviceTypeiPad ? 10.0 : 0;
		self.purchaseButton.frame = CGRectMake(self.titleLabel.frame.origin.x - 5.0,
											   self.iapCopyLabel.frame.origin.y + self.iapCopyLabel.bounds.size.height + 15.0 + offset,
											   size.width,
											   minimumSize);
		self.restoreButton.frame = CGRectMake(self.purchaseButton.frame.origin.x + CGRectGetWidth(self.purchaseButton.bounds) + 12.0,
											  self.purchaseButton.frame.origin.y,
											  minimumSize,
											  minimumSize);
	};
	
	if (animated)
	{
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:animationBlock];
	}
	else
	{
		animationBlock();
	}
	
	self.purchaseButton.layer.cornerRadius = CGRectGetMidY(self.purchaseButton.bounds);
	self.restoreButton.layer.cornerRadius = CGRectGetMidY(self.restoreButton.bounds);
}

- (void)_configureViewFrames
{
	CGFloat topOffset = (CGRectGetHeight(self.view.bounds) < 500.0) ? 20.0 : 0;
	CGFloat height = CGRectGetMidY(self.view.bounds) - topOffset;
	if (height > self.topContainer.previewHeight)
	{
		height = self.topContainer.previewHeight;
	}
	
	self.topContainer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), height);
	
	CGFloat offset = DekoGetCurrentDeviceType() == DekoDeviceTypeiPad ? 10.0 : 0;
	CGFloat textWidth = floor(self.view.bounds.size.width * 0.7);
	CGRect titleRect = CGRectMake(floor(CGRectGetMidX(self.view.bounds) - (textWidth / 2.0)),
								  floor(CGRectGetHeight(self.topContainer.bounds) + 20.0 + offset),
								  textWidth,
								  25.0);
	self.titleLabel.frame = titleRect;
	[self.titleLabel sizeToFit];
	
	CGRect iapCopyRect = CGRectMake(titleRect.origin.x,
									titleRect.origin.y + titleRect.size.height + 10.0,
									textWidth,
									100.0);
	self.iapCopyLabel.frame = iapCopyRect;
	[self.iapCopyLabel sizeToFit];
	
	[self _configurePurchaseButtonSizeAnimated:NO];
	
	self.backButton.frame = CGRectMake(10.0, 10.0, 44.0, 44.0);
}

- (void)_updatePurchaseButton
{
	NSString *price = [self.purchaseManager priceForProVersion];
	
	if (price != nil)
	{
		[self.purchaseButton setTitle:price forState:UIControlStateNormal];
		self.purchaseButton.enabled = YES;
	}
	else
	{
		[self.purchaseButton setTitle:NSLocalizedString(@"Fetching price...", @"Purchase button, waiting for price") forState:UIControlStateNormal];
		self.purchaseButton.enabled = NO;
	}

	[self _configurePurchaseButtonSizeAnimated:YES];
}

- (void)_priceUpdated:(NSNotification *)notification
{
	AELOG_DEBUG(@"");
	
	[self _updatePurchaseButton];
}

- (void)_restoreButtonTouched
{
	[self.purchaseManager restorePurchases];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
	
	DekoIAPPreviewView *topContainer = [[DekoIAPPreviewView alloc] initWithFrame:CGRectZero];
	topContainer.backgroundColor = [UIColor greenColor];
	topContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:topContainer];
	self.topContainer = topContainer;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = NSLocalizedString(@"High quality export", @"IAP view, title");
	titleLabel.font = [self.localizationManager localizedFontWithSize:20.0];
	[self.view addSubview:titleLabel];
	self.titleLabel = titleLabel;
	
	UILabel *iapCopyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	iapCopyLabel.backgroundColor = [UIColor clearColor];
	NSString *iapCopyString = nil;
	if (DekoGetCurrentDeviceType() == DekoDeviceTypeiPad)
	{
		iapCopyString = NSLocalizedString(@"Unlock high quality export to get your creations in full fidelity. Use the pixel-perfect patterns as wallpapers or tweak them further in other apps.\n\nSlide the bar on the image to see the difference.", @"IAP view copy, iPad");
	}
	else
	{
		iapCopyString = NSLocalizedString(@"Unlock high quality export to get your creations in full fidelity.\nUse the pixel-perfect patterns as wallpapers or tweak them further in other apps. Slide the bar on the image to see the difference.", @"IAP view copy, iPhone");
	}
	
	iapCopyLabel.text = iapCopyString;
	iapCopyLabel.numberOfLines = 0;
	iapCopyLabel.font = [self.localizationManager localizedFontWithSize:15.0];
	[self.view addSubview:iapCopyLabel];
	self.iapCopyLabel = iapCopyLabel;
	
	UIButton *purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	purchaseButton.backgroundColor = [UIColor redColor];
	purchaseButton.titleLabel.font = [self.localizationManager localizedFontWithSize:15.0];
	purchaseButton.titleLabel.textColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
	[purchaseButton setTitleColor:[UIColor colorWithWhite:DekoBackgroundColor alpha:1.0] forState:UIControlStateNormal];
	[purchaseButton addTarget:self action:@selector(_purchaseProVersion) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:purchaseButton];
	self.purchaseButton = purchaseButton;
	
	UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	restoreButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
	restoreButton.titleLabel.font = [self.localizationManager localizedFontWithSize:13.0];
	restoreButton.titleLabel.numberOfLines = 0;
	restoreButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	restoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[restoreButton setTitleColor:iapCopyLabel.textColor forState:UIControlStateNormal];
	[restoreButton addTarget:self action:@selector(_restoreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	[restoreButton setTitle:NSLocalizedString(@"Restore", @"IAP view, restore button") forState:UIControlStateNormal];
	[self.view addSubview:restoreButton];
	self.restoreButton = restoreButton;
	
	UIImage *backButtonImage = [UIImage imageNamed:@"credits-backarrow"];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:backButtonImage forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_dismiss) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	self.backButton = backButton;
	
	self.busyView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.busyView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
	self.busyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.busyView.hidden = YES;
	[self.view addSubview:self.busyView];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = CGRectMake(CGRectGetMidX(self.busyView.bounds) - CGRectGetMidX(spinner.bounds),
							   CGRectGetMidY(self.busyView.bounds) - CGRectGetMidY(spinner.bounds),
							   CGRectGetWidth(spinner.bounds),
							   CGRectGetHeight(spinner.bounds));
	spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[spinner startAnimating];
	[self.busyView addSubview:spinner];
	
	[self _updatePurchaseButton];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.view.layer.cornerRadius = 0;
	
	[self _configureViewFrames];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_priceUpdated:) name:DekoIAPManagerProPriceUpdatedNotification object:self.purchaseManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_proPurchased:) name:DekoIAPManagerProVersionPurchasedNotification object:self.purchaseManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DekoIAPManagerProPriceUpdatedNotification object:self.purchaseManager];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DekoIAPManagerProVersionPurchasedNotification object:self.purchaseManager];
}

- (BOOL)shouldAutorotate
{
	return DekoShouldAutorotate();
}

@end
