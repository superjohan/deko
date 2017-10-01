//
//  DekoCreditsViewController.m
//  deko
//
//  Created by Johan Halin on 7.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DekoCreditsViewController.h"
#import "DekoConstants.h"
#import "AECGHelpers.h"
#import "DekoLocalizationManager.h"
#import "DekoFunctions.h"

@interface DekoCreditsViewController ()
@property (nonatomic) UIImageView *layer1;
@property (nonatomic) UIImageView *layer2;
@end

@implementation DekoCreditsViewController

#pragma mark - Private

- (void)_dismiss
{
	[self dismissViewControllerAnimated:YES completion:^{
		AELOG_DEBUG(@"Credits dismissed");
	}];
}

- (void)_animateLayers
{
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:5.0 options:0 animations:^{
		self.layer1.alpha = 0;
		self.layer2.alpha = 1;
	} completion:^(BOOL finished1) {
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:5.0 options:0 animations:^{
			self.layer1.alpha = 1;
			self.layer2.alpha = 0;
		} completion:^(BOOL finished2) {
			[self _animateLayers];
		}];
	}];
}

- (void)_webButtonTouched
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dekoapp.com/"]];
}

- (void)_twitterButtonTouched
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/dekoapp"]];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];

	UIImage *backButtonImage = [UIImage imageNamed:@"credits-backarrow"];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(10.0, 10.0, 44.0, 44.0);
	[backButton setImage:backButtonImage forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_dismiss) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credits-background"]];
	background.frame = CGRectMake(0, 0, background.image.size.width, background.image.size.height);
	CGRect containerFrame = CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(background.bounds),
									   CGRectGetMidY(self.view.bounds) - CGRectGetMidY(background.bounds),
									   CGRectGetWidth(background.bounds),
									   CGRectGetHeight(background.bounds));
	UIView *container = [[UIView alloc] initWithFrame:containerFrame];
	container.backgroundColor = [UIColor clearColor];
	container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[container addSubview:background];
	[self.view addSubview:container];
	
	self.layer1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credits-1"]];
	self.layer1.frame = background.frame;
	self.layer2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credits-2"]];
	self.layer2.frame = self.layer1.frame;
	self.layer2.alpha = 0;
	[container addSubview:self.layer1];
	[container addSubview:self.layer2];
	
	UIButton *webButton = [UIButton buttonWithType:UIButtonTypeCustom];
	webButton.frame = CGRectMake(55.0, 258.0, 130.0, 44.0);
	[webButton addTarget:self action:@selector(_webButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	[container addSubview:webButton];
	
	UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	twitterButton.frame = CGRectMake(190.0, webButton.frame.origin.y, 80.0, webButton.frame.size.height);
	[twitterButton addTarget:self action:@selector(_twitterButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	[container addSubview:twitterButton];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *versionString = infoDictionary[@"CFBundleShortVersionString"];
	UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	versionLabel.font = [self.localizationManager localizedFontWithSize:14.0];
	versionLabel.textColor = [UIColor darkGrayColor];
	versionLabel.backgroundColor = [UIColor clearColor];
	versionLabel.text = versionString;
	versionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	[versionLabel sizeToFit];
	versionLabel.frame = AECGRectPlace(versionLabel.frame,
									   CGRectGetMaxX(self.view.bounds) - CGRectGetWidth(versionLabel.bounds) - 20.0,
									   CGRectGetMaxY(self.view.bounds) - CGRectGetHeight(versionLabel.bounds) - 20.0);
	[self.view addSubview:versionLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.view.layer.cornerRadius = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _animateLayers];
}

- (BOOL)shouldAutorotate
{
	return DekoShouldAutorotate();
}

@end
