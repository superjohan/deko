//
//  DekoParallaxUpdateViewController.m
//  deko
//
//  Created by Johan Halin on 10.9.2013.
//  Copyright (c) 2013 Aero Deko. All rights reserved.
//

#import "DekoParallaxUpdateViewController.h"
#import "DekoConstants.h"
#import "DekoLocalizationManager.h"
#import "AECGHelpers.h"
#import "DekoFunctions.h"

@interface DekoParallaxUpdateViewController ()
@property (nonatomic) UIImageView *parallaxImage;
@property (nonatomic) UIImageView *devicesImage;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *updateCopyLabel;
@property (nonatomic) UIButton *dismissButton;
@end

@implementation DekoParallaxUpdateViewController

#pragma mark - Private

- (void)_dismiss
{
	[self dismissViewControllerAnimated:YES completion:^
	{
		AELOG_DEBUG(@"Update info dismissed");
	}];
}

- (void)_configureViewFrames
{
	CGFloat y = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 0 : 20.0;
	self.devicesImage.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - (self.devicesImage.bounds.size.width / 2.0),
										 y,
										 self.devicesImage.image.size.width,
										 self.devicesImage.image.size.height);

	self.parallaxImage.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - ((self.parallaxImage.image.size.width / 2.0) / 2.0) - 10.0,
										  CGRectGetMidY(self.devicesImage.frame) - ((self.parallaxImage.image.size.height / 2.0) / 2.0),
										  self.parallaxImage.image.size.width / 2.0,
										  self.parallaxImage.image.size.height / 2.0);

	CGFloat textWidth = floor(self.devicesImage.bounds.size.width * 0.7);
	self.titleLabel.frame = CGRectMake(floor(CGRectGetMidX(self.view.bounds) - (textWidth / 2.0)) + 1.0,
									   floor(self.devicesImage.frame.origin.y + CGRectGetHeight(self.devicesImage.bounds) + 40.0),
									   textWidth,
									   25.0);
	[self.titleLabel sizeToFit];
	
	self.updateCopyLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
											self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10.0,
											textWidth,
											100.0);
	[self.updateCopyLabel sizeToFit];
	
	CGFloat size = 60.0;
	self.dismissButton.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - (size / 2.0),
										  self.view.bounds.size.height - (size * 2.0),
										  size,
										  size);
	self.dismissButton.layer.cornerRadius = CGRectGetMidY(self.dismissButton.bounds);
}

- (void)_startAnimating
{
	[UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
		self.parallaxImage.frame = AECGRectPlaceX(self.parallaxImage.frame, self.parallaxImage.frame.origin.x + 20.0);
	} completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	
	self.parallaxImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax"]];
	[self.view addSubview:self.parallaxImage];

	self.devicesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iOS7-splash"]];
	[self.view addSubview:self.devicesImage];
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.text = NSLocalizedString(@"iOS 7 Parallax Wallpapers", @"iOS 7 update view, title");
	self.titleLabel.font = [self.localizationManager localizedFontWithSize:20.0];
	[self.view addSubview:self.titleLabel];
	
	self.updateCopyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.updateCopyLabel.backgroundColor = [UIColor clearColor];
	self.updateCopyLabel.text = NSLocalizedString(@"Deko now makes pixel-perfect parallax wallpapers for iOS 7. Just use 'Save to photos' and your wallpapers will automatically be the right size.", @"iOS 7 update view, copy");
	self.updateCopyLabel.font = [self.localizationManager localizedFontWithSize:15.0];
	self.updateCopyLabel.numberOfLines = 0;
	[self.view addSubview:self.updateCopyLabel];
	
	self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.dismissButton.backgroundColor = [UIColor blueColor];
	self.dismissButton.titleLabel.font = [self.localizationManager localizedFontWithSize:15.0];
	[self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.dismissButton addTarget:self action:@selector(_dismiss) forControlEvents:UIControlEventTouchUpInside];
	[self.dismissButton setTitle:NSLocalizedString(@"OK", @"iOS 7 update view, dismiss button") forState:UIControlStateNormal];
	[self.view addSubview:self.dismissButton];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.view.layer.cornerRadius = 0;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self _configureViewFrames];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _startAnimating];
}

- (BOOL)shouldAutorotate
{
	return DekoShouldAutorotate();
}

@end
