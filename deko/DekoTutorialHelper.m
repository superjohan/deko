//
//  DekoTutorialHelper.m
//  deko
//
//  Created by Johan Halin on 9.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoTutorialHelper.h"
#import "HarmonyCanvasSettings.h"

@interface DekoTutorialHelper ()
@property (nonatomic) UIView *view;
@property (nonatomic) UIImageView *tutorialLeftArrow;
@property (nonatomic) UIImageView *tutorialRightArrow;
@property (nonatomic) UIView *tutorialCircleView;
@property (nonatomic) UIImageView *tutorialCircle1;
@property (nonatomic) UIImageView *tutorialCircle2;
@property (nonatomic) UIImageView *tutorialCircle3;
@end

NSString * const kDekoTutorialShownKey = @"kDekoTutorialShownKey";

const CGFloat kArrowLength = 200.0;

@implementation DekoTutorialHelper

#pragma mark - Private

- (void)_performLeftArrowAnimation
{
	CGRect arrowRect = CGRectMake(CGRectGetWidth(self.view.bounds) - self.tutorialLeftArrow.image.size.width - 10.0,
								  floor(CGRectGetMidY(self.view.bounds) - (self.tutorialLeftArrow.image.size.height / 2.0)),
								  self.tutorialLeftArrow.image.size.width,
								  self.tutorialLeftArrow.image.size.height);
	self.tutorialLeftArrow.frame = arrowRect;

	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:UINavigationControllerHideShowBarDuration options:0 animations:^
	{
		self.tutorialLeftArrow.alpha = 1.0;
	}
	completion:^(BOOL finished)
	{
		[UIView animateWithDuration:1.0 animations:^
		{
			self.tutorialLeftArrow.frame = CGRectMake(arrowRect.origin.x - kArrowLength,
													  self.tutorialLeftArrow.frame.origin.y,
													  self.tutorialLeftArrow.image.size.width + kArrowLength,
													  self.tutorialLeftArrow.bounds.size.height);
		}
		completion:^(BOOL finished1)
		{
			[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
			{
				self.tutorialLeftArrow.alpha = 0;
			}
			completion:^(BOOL finished2)
			{
				[self _performLeftArrowAnimation];
			}];
		}];
	}];
}

- (void)_performRightArrowAnimation
{
	CGRect arrowRect = CGRectMake(10.0,
								  floor(CGRectGetMidY(self.view.bounds) - (self.tutorialRightArrow.image.size.height / 2.0)),
								  self.tutorialRightArrow.image.size.width,
								  self.tutorialRightArrow.image.size.height);
	self.tutorialRightArrow.frame = arrowRect;
	
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:UINavigationControllerHideShowBarDuration options:0 animations:^
	{
		 self.tutorialRightArrow.alpha = 1.0;
	}
	completion:^(BOOL finished)
	{
		[UIView animateWithDuration:1.0 animations:^
		{
			self.tutorialRightArrow.frame = CGRectMake(self.tutorialRightArrow.frame.origin.x,
													   self.tutorialRightArrow.frame.origin.y,
													   self.tutorialRightArrow.image.size.width + kArrowLength,
													   self.tutorialRightArrow.bounds.size.height);
		}
		completion:^(BOOL finished1)
		{
			[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
			{
				self.tutorialRightArrow.alpha = 0;
			}
			completion:^(BOOL finished2)
			{
				[self _performRightArrowAnimation];
			}];
		}];
	}];
}

- (void)_performTapCircleAnimation
{
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:0 options:0 animations:^
	{
		self.tutorialCircle1.alpha = 1.0;
	}
	completion:^(BOOL finished)
	{
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration * 4.0 delay:0 options:0 animations:^
		{
			self.tutorialCircle1.alpha = 0;
		}
		completion:nil];
	}];

	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:UINavigationControllerHideShowBarDuration * 2.0 options:0 animations:^
	{
		 self.tutorialCircle2.alpha = 1.0;
	}
	completion:^(BOOL finished)
	{
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration * 4.0 delay:0 options:0 animations:^
		{
			self.tutorialCircle2.alpha = 0;
		}
		completion:nil];
	}];

	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:UINavigationControllerHideShowBarDuration * 4.0 options:0 animations:^
	{
		self.tutorialCircle3.alpha = 1.0;
	}
	completion:^(BOOL finished1)
	{
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration * 4.0 delay:0 options:0 animations:^
		{
			self.tutorialCircle3.alpha = 0;
		}
		completion:^(BOOL finished2)
		{
			[self _performTapCircleAnimation];
		}];
	}];
}

#pragma mark - Public

- (void)showLeftArrowInView:(UIView *)view
{
	AEAssert(view != nil);
	
	if ( ! self.shouldShowTutorial || self.tutorialLeftArrow != nil)
	{
		return;
	}
	
	self.view = view;
	
	UIImage *leftArrow = [UIImage imageNamed:@"arrow-right"];
	self.tutorialLeftArrow = [[UIImageView alloc] initWithImage:[leftArrow resizableImageWithCapInsets:UIEdgeInsetsMake(0, floor(leftArrow.size.width / 2.0), 0, floor(leftArrow.size.width / 2.0))]];
	self.tutorialLeftArrow.alpha = 0;
	self.tutorialLeftArrow.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
	[view addSubview:self.tutorialLeftArrow];
	
	[self _performLeftArrowAnimation];
}

- (void)dismissLeftArrow
{
	if (self.tutorialLeftArrow == nil)
	{
		return;
	}
	
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
	{
		self.tutorialLeftArrow.alpha = 0;
	}
	completion:^(BOOL finished)
	{
		[self.tutorialLeftArrow removeFromSuperview];
		self.tutorialLeftArrow = nil;
		self.view = nil;
	}];	
}

- (void)showRightArrowInView:(UIView *)view
{
	AEAssert(view != nil);
	
	if ( ! self.shouldShowTutorial || self.tutorialRightArrow != nil)
	{
		return;
	}
	
	self.view = view;

	UIImage *rightArrow = [UIImage imageNamed:@"arrow-left"];
	self.tutorialRightArrow = [[UIImageView alloc] initWithImage:[rightArrow resizableImageWithCapInsets:UIEdgeInsetsMake(0, floor(rightArrow.size.width / 2.0), 0, floor(rightArrow.size.width / 2.0))]];
	self.tutorialRightArrow.alpha = 0;
	self.tutorialRightArrow.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[view addSubview:self.tutorialRightArrow];
	
	[self _performRightArrowAnimation];
}

- (void)dismissRightArrow
{
	if (self.tutorialRightArrow == nil)
	{
		return;
	}
	
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
	{
		self.tutorialRightArrow.alpha = 0;
	}
	completion:^(BOOL finished)
	{
		[self.tutorialRightArrow removeFromSuperview];
		self.tutorialRightArrow = nil;
		self.view = nil;
	}];
}

- (void)showTapCirclesInView:(UIView *)view
{
	AEAssert(view != nil);
	
	if ( ! self.shouldShowTutorial || self.tutorialCircleView != nil)
	{
		return;
	}
	
	self.view = view;
	
	self.tutorialCircle1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapcircle-1"]];
	self.tutorialCircle1.frame = CGRectMake(0, 0, self.tutorialCircle1.image.size.width, self.tutorialCircle1.image.size.height);
	self.tutorialCircle1.alpha = 0;
	self.tutorialCircle2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapcircle-2"]];
	self.tutorialCircle2.frame = CGRectMake(0, 0, self.tutorialCircle2.image.size.width, self.tutorialCircle2.image.size.height);
	self.tutorialCircle2.alpha = 0;
	self.tutorialCircle3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapcircle-3"]];
	self.tutorialCircle3.frame = CGRectMake(0, 0, self.tutorialCircle3.image.size.width, self.tutorialCircle3.image.size.height);
	self.tutorialCircle3.alpha = 0;
	
	CGRect rect = CGRectMake(floor(CGRectGetMidX(view.bounds) - CGRectGetMidX(self.tutorialCircle1.bounds)),
							 floor(CGRectGetMidY(view.bounds) - CGRectGetMidY(self.tutorialCircle1.bounds)),
							 CGRectGetWidth(self.tutorialCircle1.bounds),
							 CGRectGetWidth(self.tutorialCircle1.bounds));
	self.tutorialCircleView = [[UIView alloc] initWithFrame:rect];
	self.tutorialCircleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	self.tutorialCircleView.backgroundColor = [UIColor clearColor];
	[self.tutorialCircleView addSubview:self.tutorialCircle1];
	[self.tutorialCircleView addSubview:self.tutorialCircle2];
	[self.tutorialCircleView addSubview:self.tutorialCircle3];
	[view addSubview:self.tutorialCircleView];
	
	[self _performTapCircleAnimation];
}

- (void)dismissTapCircles
{
	if (self.tutorialCircleView == nil)
	{
		return;
	}

	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
	{
		self.tutorialCircleView.alpha = 0;
	}
	completion:^(BOOL finished)
	{
		[self.tutorialCircleView removeFromSuperview];
		self.tutorialCircleView = nil;
		self.view = nil;
	}];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDekoTutorialShownKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (HarmonyCanvasSettings *)defaultSettings1
{
	// FIXME: replace with enums
	HarmonyCanvasSettings *settings = [[HarmonyCanvasSettings alloc] init];
	settings.mixingType = 1;
	settings.positionType = 1;
	settings.transformType = 0;
	settings.sizeType = 1;
	settings.rotationType = 4;
	settings.shapeType = 2;
	settings.colorType = 4;
	settings.brightnessType = 1;
	settings.saturationType = 3;
	settings.hue = 0.884825;
	settings.baseSize = 341.1;
	settings.baseDistance = 17.0;
	settings.angle = 3.199325;
	
	return settings;
}

- (HarmonyCanvasSettings *)defaultSettings2
{
	// FIXME: replace with enums
	HarmonyCanvasSettings *settings = [[HarmonyCanvasSettings alloc] init];
	settings.mixingType = 1;
	settings.positionType = 1;
	settings.transformType = 2;
	settings.sizeType = 1;
	settings.rotationType = 1;
	settings.shapeType = 0;
	settings.colorType = 0;
	settings.brightnessType = 1;
	settings.saturationType = 3;
	settings.hue = 0.326132;
	settings.baseSize = 34.0;
	settings.baseDistance = -9.0;
	settings.angle = 2.659172;
	
	return settings;
}

#pragma mark - Properties

- (BOOL)shouldShowTutorial
{
	BOOL tutorialShownInFull = [[NSUserDefaults standardUserDefaults] boolForKey:kDekoTutorialShownKey];
	
	return ! tutorialShownInFull;
}

@end
