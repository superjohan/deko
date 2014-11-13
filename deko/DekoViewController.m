//
//  DekoViewController.m
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "DekoViewController.h"
#import "DekoLogoView.h"
#import "HarmonyStaticView.h"
#import "HarmonyColorGenerator.h"
#import "DekoMenuView.h"
#import "AECGHelpers.h"
#import "DekoIAPManager.h"
#import "HarmonySettingGenerator.h"
#import "DekoShareHelper.h"
#import "DekoSceneManager.h"
#import "DekoGalleryViewController.h"
#import "DekoScene.h"
#import "DekoCreditsViewController.h"
#import "DekoConstants.h"
#import "DekoIAPViewController.h"
#import "DekoTutorialHelper.h"
#import "HarmonyCanvasSettings.h"
#import "DekoLocalizationManager.h"
#import "DekoFunctions.h"

typedef NS_ENUM(NSInteger, DekoTutorialStep)
{
	DekoTutorialStepNext,
	DekoTutorialStepPrevious,
	DekoTutorialStepTap,
	DekoTutorialStepMax,
};

@interface DekoViewController () <DekoMenuViewDelegate, DekoShareHelperDelegate, MFMailComposeViewControllerDelegate, DekoGalleryViewControllerDelegate, DekoIAPViewControllerDelegate>
@property (nonatomic) DekoLogoView *logoView;
@property (nonatomic) DekoMenuView *menuView;
@property (nonatomic) HarmonyStaticView *harmonyView;
@property (nonatomic) UIView *harmonyContainer;
@property (nonatomic) UIView *undoHarmonyContainer;
@property (nonatomic) UIView *swipeableContainer;
@property (nonatomic) UIView *whiteCanvas;
@property (nonatomic) DekoTutorialHelper *tutorialHelper;
@property (nonatomic) UIImageView *shadow;
@property (nonatomic) UIImageView *undoShadow;
@property (nonatomic) UIButton *watermark;
@property (nonatomic) UILabel *whiteCanvasLabel;
@property (nonatomic) UILabel *whiteCanvasTutorialLabel;
@property (nonatomic) UILabel *previousTutorialLabel;
@property (nonatomic) UILabel *debugInfoLabel;
@property (nonatomic) HarmonyCanvasSettings *previousSettings;
@property (nonatomic) HarmonyCanvasSettings *currentSettings;
@property (nonatomic) UIImage *cachedImage;
@property (nonatomic) NSString *currentSceneID;
@property (nonatomic) NSString *previousSceneID;
@property (nonatomic) UIActivityIndicatorView *whiteCanvasSpinner;
@property (nonatomic) DekoLocalizationManager *localizationManager;
@property (nonatomic, assign) BOOL appLaunched;
@property (nonatomic, assign) BOOL firstGeneration;
@property (nonatomic, assign) BOOL showMenuLabels;
@property (nonatomic, assign) DekoTutorialStep tutorialStep;
@end

@implementation DekoViewController

const NSTimeInterval DekoLogoAnimationDuration = 2.0;

const CGFloat DekoiPadOffset = 238.0;
const CGFloat DekoiPhone6PlusOffset = ((2662.0 - 2208.0) / 3.0); // whee
const CGFloat DekoiPhone6WidthOffset = 51.0;
const CGFloat DekoiPhone6HeightOffset = 137.0;
const CGFloat DekoiPhoneWidthOffset = 52.0;
const CGFloat DekoiPhoneHeightOffset = 128.0;
const CGFloat DekoiPhone4WidthOffset = 50.0;
const CGFloat DekoiPhone4HeightOffset = 118.0;

#pragma mark - Private

- (CGFloat)_squareOffset
{
	DekoDeviceType deviceType = DekoGetCurrentDeviceType();
	
	switch (deviceType)
	{
		case DekoDeviceTypeiPad:
			return DekoiPadOffset;
		case DekoDeviceTypeiPhone6Plus:
			return DekoiPhone6PlusOffset;
		case DekoDeviceTypeiPhone6:
			return DekoiPhone6HeightOffset;
		case DekoDeviceTypeiPhone5:
			return DekoiPhoneHeightOffset;
		case DekoDeviceTypeiPhone:
			return DekoiPhone4HeightOffset;
		default:
			AELOG_ERROR(@"Unknown device type: %ld", (long)deviceType);
			return 0;
			break;
	}
}

- (CGRect)_rectForHarmonyContainer
{
	CGFloat width = self.view.bounds.size.width;
	CGFloat height = self.view.bounds.size.height;
	CGFloat baseLength = MAX(width, height) + ([self _squareOffset] * 2.0);
	CGFloat containerLength = sqrt(pow(baseLength, 2.0) + pow(baseLength, 2.0));
	CGRect frame = CGRectMake(ceil((self.view.bounds.size.width / 2.0) - (containerLength / 2.0)),
							  ceil((self.view.bounds.size.height / 2.0) - (containerLength / 2.0)),
							  ceil(containerLength),
							  ceil(containerLength));

	return frame;
}

- (void)_toggleDebugInfo:(UITapGestureRecognizer *)gestureRecognizer
{
	self.debugInfoLabel.hidden = !self.debugInfoLabel.hidden;
	if (!self.debugInfoLabel.hidden)
	{
		[self _updateDebugLabel];
	}
}

- (void)_updateDebugLabel
{
	[self.view bringSubviewToFront:self.debugInfoLabel];
	
	self.debugInfoLabel.text = [NSString stringWithFormat:
								@"\n\
								Mixing type: %ld\n \
								Position type: %ld\n \
								Transform type: %ld\n \
								Size type: %ld\n \
								Rotation type: %ld\n \
								Shape type: %ld\n \
								Color type: %ld\n \
								Brightness type: %ld\n \
								Saturation type %ld\n \
								Hue: %f\n \
								Base size: %f\n \
								Base distance: %f\n \
								Angle: %f\n",
								(long)self.currentSettings.mixingType,
								(long)self.currentSettings.positionType,
								(long)self.currentSettings.transformType,
								(long)self.currentSettings.sizeType,
								(long)self.currentSettings.rotationType,
								(long)self.currentSettings.shapeType,
								(long)self.currentSettings.colorType,
								(long)self.currentSettings.brightnessType,
								(long)self.currentSettings.saturationType,
								self.currentSettings.hue,
								self.currentSettings.baseSize,
								self.currentSettings.baseDistance,
								self.currentSettings.angle];
}

- (void)_revealCanvas
{
	HarmonyCanvasSettings *settings = nil;
	if (self.tutorialHelper.shouldShowTutorial)
	{
		settings = [self.tutorialHelper defaultSettings1];
	}
	else
	{
		settings = [self.settingGenerator generateNewSettings];
	}
	
	[self _generateNewCanvasWithFadeInDuration:DekoLogoAnimationDuration / 2.0 fadeOutDuration:0 settings:settings fadeOutLogo:YES];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapRecognized:)];
	[self.view addGestureRecognizer:tapRecognizer];
	
	UITapGestureRecognizer *debugRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleDebugInfo:)];
	debugRecognizer.numberOfTouchesRequired = 2;
	[self.view addGestureRecognizer:debugRecognizer];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panRecognized:)];
	[self.swipeableContainer addGestureRecognizer:panRecognizer];
}

- (void)_showMenu
{
	[self.menuView updateMenuWithSaveStatus:(self.currentSceneID != nil) tutorial:self.showMenuLabels animated:NO];
	
	self.menuView.hidden = NO;
	
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
	{
		self.menuView.alpha = 1.0;
		
		if (DekoGetCurrentDeviceType() != DekoDeviceTypeiPad)
		{
			self.watermark.alpha = 0;
		}
	}];
}

- (void)_hideMenu
{
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
	{
		self.menuView.alpha = 0;
		self.watermark.alpha = 1.0;
	}
	completion:^(BOOL finished)
	{
		self.menuView.hidden = YES;
	}];
}

- (void)_tapRecognized:(UITapGestureRecognizer *)tapRecognizer
{
	if (self.menuView.hidden)
	{
		[self _showMenu];
	}
	else
	{
		[self _hideMenu];
	}
	
	[self.tutorialHelper dismissLeftArrow];
	[self.tutorialHelper dismissRightArrow];
	[self.tutorialHelper dismissTapCircles];
	self.tutorialStep = DekoTutorialStepMax;
}

- (CGRect)_shadowRect
{
	return CGRectMake(self.whiteCanvas.frame.origin.x - self.shadow.frame.size.width,
					  self.whiteCanvas.frame.origin.y,
					  self.shadow.bounds.size.width,
					  self.whiteCanvas.bounds.size.height);
}

- (CGRect)_undoShadowRect
{
	return CGRectMake(self.swipeableContainer.frame.origin.x - self.undoShadow.bounds.size.width,
					  self.swipeableContainer.frame.origin.y,
					  self.undoShadow.bounds.size.width,
					  self.swipeableContainer.bounds.size.height);
}

- (CGRect)_previousTutorialLabelRect
{
	return AECGRectPlace(self.previousTutorialLabel.frame,
						 CGRectGetMinX(self.view.bounds) + 10.0,
						 CGRectGetMinY(self.whiteCanvasLabel.frame));
}

- (void)_configureViewHierarchyForNewCanvas
{
	self.previousTutorialLabel.hidden = YES;
	[self.undoHarmonyContainer removeFromSuperview];
	[self.view insertSubview:self.harmonyContainer atIndex:0];
	self.undoHarmonyContainer = self.harmonyContainer;
	[self _configureHarmonyContainer];
}

- (void)_panEndedWithVelocity:(CGPoint)velocity undoDisabled:(BOOL)undoDisabled translation:(CGPoint)translation refreshStep:(NSInteger)refreshStep
{
	CGPoint animationDestination = self.view.bounds.origin;
	BOOL generateNewCanvas = NO;
	BOOL previous = NO;
	BOOL whiteCanvasVisible = self.whiteCanvas.frame.origin.x < self.view.bounds.size.width;
	BOOL undoInProgress = self.swipeableContainer.frame.origin.x > self.view.bounds.origin.x;
	CGFloat undoMinimum = 20;
	CGFloat minimumVelocity = 500;
	CGFloat refreshMinimum = self.whiteCanvasLabel.frame.origin.x;
    
	UIView *animatedView = self.swipeableContainer;
    
	if (translation.x < -refreshMinimum && velocity.x < minimumVelocity && whiteCanvasVisible)
	{
		animationDestination.x = self.view.bounds.origin.x;
		generateNewCanvas = YES;
		animatedView = self.whiteCanvas;
        
		if (velocity.x < -minimumVelocity)
		{
			refreshStep = DekoMaximumSettingSteps;
			
			[self _updateWhiteCanvasLabelsWithStep:refreshStep pieces:DekoMaximumSettingSteps swipe:YES];
		}
	}
	else if (translation.x > undoMinimum && !undoDisabled && velocity.x > -minimumVelocity && undoInProgress)
	{
		animationDestination.x = self.view.bounds.size.width;
		previous = YES;
	}
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
	{
		animatedView.frame = AECGRectPlace(animatedView.frame, animationDestination.x, animationDestination.y);
		
		if (animatedView != self.whiteCanvas)
		{
			self.whiteCanvas.frame = AECGRectPlaceX(self.whiteCanvas.frame, self.view.bounds.size.width);
		}
		
		self.shadow.frame = [self _shadowRect];
		self.shadow.alpha = 0;
		self.undoShadow.frame = [self _undoShadowRect];
		self.previousTutorialLabel.frame = [self _previousTutorialLabelRect];
	}
	completion:^(BOOL finished)
	{
		HarmonyCanvasSettings *settings = nil;
         
		if (previous)
		{
			self.currentSceneID = self.previousSceneID;
			self.currentSettings = self.previousSettings;
			self.harmonyContainer = self.undoHarmonyContainer;
			self.cachedImage = nil;
			
			for (UIView *view in self.swipeableContainer.subviews)
			{
				if (view != self.watermark)
				{
					[view removeFromSuperview];
				}
			}
			
			[self.swipeableContainer addSubview:self.harmonyContainer];
			
			self.watermark.alpha = 0;
			[self.swipeableContainer bringSubviewToFront:self.watermark];
			[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
			{
				self.watermark.alpha = 1;
			}];
			
			self.swipeableContainer.frame = AECGRectPlace(self.swipeableContainer.frame, self.view.bounds.origin.x, self.view.bounds.origin.y);
			self.previousSettings = nil;
		}
		
		if (generateNewCanvas)
		{
			self.previousSettings = self.currentSettings;
			
			if (self.tutorialHelper.shouldShowTutorial && !self.firstGeneration && refreshStep == DekoMaximumSettingSteps)
			{
				settings = [self.tutorialHelper defaultSettings2];
				self.firstGeneration = YES;
			}
			else
			{
				settings = [self.settingGenerator generateNewSettingsBasedOnSettings:self.currentSettings step:refreshStep];
			}
			
			self.previousSceneID = self.currentSceneID;

			if (refreshStep > 0)
			{
				self.currentSceneID = nil;
			}
						
			[self _configureViewHierarchyForNewCanvas];
		}
		
		if (settings != nil)
		{
			[self _generateNewCanvasWithFadeInDuration:UINavigationControllerHideShowBarDuration fadeOutDuration:UINavigationControllerHideShowBarDuration settings:settings fadeOutLogo:NO];
		}
		
		self.undoShadow.frame = [self _undoShadowRect];
		self.previousTutorialLabel.frame = [self _previousTutorialLabelRect];
		
		if (self.tutorialStep == DekoTutorialStepTap)
		{
			[self.tutorialHelper showTapCirclesInView:self.view];
			self.tutorialStep = DekoTutorialStepMax;
		}
		
		[self _updateDebugLabel];
	}];
}

- (void)_positionWhiteCanvasLabels
{
	self.whiteCanvasLabel.frame = AECGRectPlaceY(self.whiteCanvasLabel.frame,
												 CGRectGetMidY(self.whiteCanvas.bounds) - (CGRectGetWidth(self.whiteCanvasLabel.bounds) / 2.0));
	self.whiteCanvasTutorialLabel.frame = AECGRectPlace(self.whiteCanvasTutorialLabel.frame,
														self.whiteCanvasLabel.frame.origin.x + 1.0,
														self.whiteCanvasLabel.frame.origin.y - self.whiteCanvasTutorialLabel.bounds.size.height);
}

- (void)_updateWhiteCanvasLabelsWithStep:(NSInteger)refreshStep pieces:(NSInteger)pieces swipe:(BOOL)swipe
{
	if (refreshStep == 0)
	{
		self.whiteCanvasLabel.text = NSLocalizedString(@"•", @"Scene refresh, no changes to settings");
		self.whiteCanvasTutorialLabel.text = NSLocalizedString(@"Make another version of this pattern.", @"Scene refresh tutorial text, no changes to settings");
	}
	else if (refreshStep < (NSInteger)pieces - 1)
	{
		self.whiteCanvasLabel.text = [NSString stringWithFormat:@"%ld", (long)refreshStep];
		self.whiteCanvasTutorialLabel.text = NSLocalizedString(@"The further you pull, the more the pattern will change.", @"Scene refresh tutorial text, some changes to settings");
	}
	else
	{
		self.whiteCanvasLabel.text = NSLocalizedString(@"New", @"Scene refresh, full refresh");
		
		if (swipe)
		{
			self.whiteCanvasTutorialLabel.text = NSLocalizedString(@"Pull halfway and release to adjust the current pattern.", @"Scene refresh tutorial text, full refresh, swipe");
		}
		else
		{
			self.whiteCanvasTutorialLabel.text = NSLocalizedString(@"A completely new pattern will be made from scratch.", @"Scene refresh tutorial text, full refresh, no swipe");
		}
	}
}

- (void)_panRecognized:(UIPanGestureRecognizer *)panRecognizer
{
	CGPoint translation = [panRecognizer translationInView:self.swipeableContainer];
	CGPoint finalTranslation = CGPointMake(translation.x, 0);
	BOOL undoDisabled = (self.previousSettings == nil);
	NSInteger refreshStep = DekoMaximumSettingSteps;
	
	if (panRecognizer.state == UIGestureRecognizerStateBegan)
	{
		[self _positionWhiteCanvasLabels];
		[self.whiteCanvasSpinner stopAnimating];
		self.whiteCanvasSpinner.hidden = YES;
		
		if (self.tutorialStep == DekoTutorialStepNext)
		{
			[self.tutorialHelper dismissLeftArrow];
			self.tutorialStep = DekoTutorialStepPrevious;
		}
		else if (self.tutorialStep == DekoTutorialStepPrevious)
		{
			[self.tutorialHelper dismissRightArrow];
			self.tutorialStep = DekoTutorialStepTap;
		}
	}
	
	if (translation.x < 0)
	{
		finalTranslation = CGPointZero;
		
		self.whiteCanvas.hidden = NO;
		self.whiteCanvas.alpha = 1;
		self.whiteCanvas.frame = AECGRectPlace(self.whiteCanvas.frame, self.view.bounds.size.width + translation.x, 0);
		self.shadow.frame = [self _shadowRect];
		self.shadow.alpha = 1.0 - (self.whiteCanvas.frame.origin.x / self.view.bounds.size.width);
		
		CGFloat pieces = (CGFloat)(DekoMaximumSettingSteps + 1);
		CGFloat pieceWidth = (self.view.bounds.size.width - (self.view.bounds.size.width / 2.5)) / pieces;
				
		for (NSInteger i = 0; i < ((NSInteger)pieces); i++)
		{
			if (fabs(translation.x) - (self.whiteCanvasTutorialLabel.bounds.size.width - 10.0) < pieceWidth * (i + 1))
			{
				refreshStep = i;
				
				break;
			}
		}
		
		[self _updateWhiteCanvasLabelsWithStep:refreshStep pieces:pieces swipe:NO];
	}
	else
	{
		refreshStep = -1;
		
		if (undoDisabled)
		{
			CGFloat width = CGRectGetHeight(self.swipeableContainer.bounds);
			CGFloat resistance = 1 - ((width - translation.x) / width);
			CGFloat x = floor(translation.x - ((width / 1.2) * resistance));
			
			finalTranslation.x = x;
		}
		
		self.whiteCanvas.hidden = YES;
		self.whiteCanvas.alpha = 0;
		self.whiteCanvas.frame = AECGRectPlace(self.whiteCanvas.frame, self.view.bounds.size.width, 0);
	}
	
	self.swipeableContainer.frame = AECGRectPlace(self.swipeableContainer.frame, finalTranslation.x, finalTranslation.y);
	self.undoShadow.hidden = NO;
	self.undoShadow.frame = [self _undoShadowRect];
	self.previousTutorialLabel.hidden = undoDisabled;
	self.previousTutorialLabel.frame = [self _previousTutorialLabelRect];
	
	if (panRecognizer.state == UIGestureRecognizerStateEnded || panRecognizer.state == UIGestureRecognizerStateCancelled)
	{
		self.whiteCanvasSpinner.frame = AECGRectPlace(self.whiteCanvasSpinner.frame,
													  self.whiteCanvasLabel.frame.origin.x + CGRectGetWidth(self.whiteCanvasLabel.bounds) + 10.0,
													  self.whiteCanvasLabel.frame.origin.y + CGRectGetMidY(self.whiteCanvasLabel.bounds) - (CGRectGetHeight(self.whiteCanvasSpinner.bounds) / 2.0));
		[self.whiteCanvasSpinner startAnimating];
		self.whiteCanvasSpinner.hidden = NO;

		CGPoint velocity = [panRecognizer velocityInView:self.swipeableContainer];
		
		[self _panEndedWithVelocity:velocity undoDisabled:undoDisabled translation:translation refreshStep:refreshStep];
	}
}

- (void)_configureHarmonyContainer
{
	self.harmonyContainer = [[UIView alloc] initWithFrame:[self _rectForHarmonyContainer]];
	self.harmonyContainer.backgroundColor = [UIColor clearColor];
	self.harmonyContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self.swipeableContainer addSubview:self.harmonyContainer];
	
	self.harmonyView = [[HarmonyStaticView alloc] initWithFrame:self.harmonyContainer.bounds];
	self.harmonyView.backgroundColor = [UIColor blackColor];
	self.harmonyView.colorGenerator = self.colorGenerator;
	self.harmonyView.alpha = 0;
		
	[self.swipeableContainer bringSubviewToFront:self.watermark];

	UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalEffect.minimumRelativeValue = @20.0;
	horizontalEffect.maximumRelativeValue = @-20.0;
	[self.harmonyView addMotionEffect:horizontalEffect];
	UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalEffect.minimumRelativeValue = @30.0;
	verticalEffect.maximumRelativeValue = @-30.0;
	[self.harmonyView addMotionEffect:verticalEffect];
}

- (void)_generateNewCanvasWithFadeInDuration:(NSTimeInterval)fadeInDuration fadeOutDuration:(NSTimeInterval)fadeOutDuration settings:(HarmonyCanvasSettings *)settings fadeOutLogo:(BOOL)fadeOutLogo
{
	AEAssert(settings != nil);
	
	self.cachedImage = nil;
	
	[UIView animateWithDuration:fadeOutDuration animations:^
	{
		self.harmonyView.alpha = 0;
	}
	completion:^(BOOL finished)
	{
		self.currentSettings = settings;
		
		[self.harmonyContainer addSubview:self.harmonyView];
		
		[self.harmonyView updateCanvasWithSettings:self.currentSettings];
		
		[self _updateDebugLabel];
		
		self.swipeableContainer.frame = self.view.bounds;
		
		UIImage *watermarkImage = [self.watermark imageForState:UIControlStateNormal];
		self.watermark.frame = AECGRectPlace(self.watermark.frame, self.swipeableContainer.bounds.size.width - watermarkImage.size.width, self.swipeableContainer.bounds.size.height - watermarkImage.size.height);
		self.watermark.alpha = 0;
		self.watermark.hidden = NO;
		
		UIView *animatedView = self.harmonyView;
		CGFloat alpha = 1;
		
		if (!self.whiteCanvas.hidden)
		{
			animatedView = self.whiteCanvas;
			self.harmonyView.alpha = 1;
			alpha = 0;
		}
		
		[UIView animateWithDuration:fadeInDuration animations:^
		{
			animatedView.alpha = alpha;
			
			if (self.logoView == nil)
			{
				self.watermark.alpha = 1.0;
			}
		}
		completion:^(BOOL finished1)
		{
			if (self.logoView != nil && fadeOutLogo)
			{
				[UIView animateWithDuration:DekoLogoAnimationDuration / 5.0 delay:DekoLogoAnimationDuration / 2.0 options:0 animations:^
				{
					self.logoView.alpha = 0;
					self.watermark.alpha = 1.0;
				}
				completion:^(BOOL finished2)
				{
					[self.logoView removeFromSuperview];
					self.logoView = nil;
					
					[self.tutorialHelper showLeftArrowInView:self.view];
					self.tutorialStep = DekoTutorialStepNext;
				}];
			}
		}];
		
		if (self.tutorialStep == DekoTutorialStepPrevious)
		{
			[self.tutorialHelper showRightArrowInView:self.view];
		}
	}];
}

- (void)_showTutorialWithText:(NSString *)text
{
	AEAssert(text != nil && [text length] > 0);
	
	CGFloat size = 100;
	CGRect rect = CGRectMake((self.view.bounds.size.width / 2.0) - size,
							 20.0,
							 size * 2.0,
							 size);
	UIView *noticeView = [[UIView alloc] initWithFrame:rect];
	noticeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (size * 2.0) - 20.0, size - 20.0)];
	label.backgroundColor = [UIColor clearColor];
	label.text = text;
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentCenter;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	label.textColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
	label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
	label.shadowOffset = CGSizeMake(0, 1);
	label.font = [self.localizationManager localizedFontWithSize:17.0];
	[noticeView addSubview:label];
	
	[self.view addSubview:noticeView];
	
	[UIView animateWithDuration:1 delay:0.5 options:0 animations:^{
		noticeView.alpha = 0;
	} completion:^(BOOL finished) {
		[noticeView removeFromSuperview];
	}];
}

- (UIImage *)_imageOfCurrentCanvas:(BOOL)thumbnail
{
	if (self.cachedImage != nil && !thumbnail)
	{
		return self.cachedImage;
	}
	
	CGRect imageFrame = CGRectZero;
	CGPoint offset = CGPointZero;
	CGFloat width = self.view.bounds.size.width;
	CGFloat height = self.view.bounds.size.height;
	
	DekoDeviceType deviceType = DekoGetCurrentDeviceType();
	
	if (deviceType == DekoDeviceTypeiPad)
	{
		CGFloat squareOffset = [self _squareOffset];
		width += squareOffset;
		height += squareOffset;
		CGFloat length = MAX(width, height);
		imageFrame = CGRectMake(0, 0, length, length);
		width = length;
		height = length;
	}
	else
	{
		if (deviceType == DekoDeviceTypeiPhone6Plus)
		{
			width += DekoiPhone6PlusOffset;
			height += DekoiPhone6PlusOffset;
		}
		else if (deviceType == DekoDeviceTypeiPhone6)
		{
			width += DekoiPhone6WidthOffset;
			height += DekoiPhone6HeightOffset;
		}
		else if (deviceType == DekoDeviceTypeiPhone5)
		{
			width += DekoiPhoneWidthOffset;
			height += DekoiPhoneHeightOffset;
		}
		else
		{
			width += DekoiPhone4WidthOffset;
			height += DekoiPhone4HeightOffset;
		}
		
		imageFrame = CGRectMake(0, 0, width, height);
	}

	offset.x = (width - self.harmonyContainer.bounds.size.width) / 2.0;
	offset.y = (height - self.harmonyContainer.bounds.size.height) / 2.0;

	CGFloat scale = [[UIScreen mainScreen] scale];
	if (!self.purchaseManager.proPurchased && !thumbnail)
	{
		scale = scale / 2.0;
	}
	
	if (thumbnail)
	{
		CGFloat length = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
		imageFrame.size = CGSizeMake(length, length);
		scale = (DekoThumbnailSize / length) * scale;
	}
	
	UIGraphicsBeginImageContextWithOptions(imageFrame.size, YES, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (thumbnail)
	{
		[self.swipeableContainer.layer renderInContext:context];
	}
	else
	{
		CGContextTranslateCTM(context, offset.x, offset.y);
		[self.harmonyContainer.layer renderInContext:context];
	}
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (!thumbnail)
	{
		self.cachedImage = image;
	}
	
	return image;
}

- (void)_shareImageWithShareType:(NSNumber *)shareTypeNumber
{
	AEAssert(shareTypeNumber != nil);
	
	NSInteger shareType = [shareTypeNumber integerValue];
	
	[self.shareHelper shareImage:[self _imageOfCurrentCanvas:NO] shareType:shareType proPurchased:self.purchaseManager.proPurchased];
	[self.menuView updateShareButtonsWithBusyStateForShareType:DekoShareNone];
}

- (void)_dekoButtonTouched
{
	DekoCreditsViewController *creditsViewController = [[DekoCreditsViewController alloc] initWithNibName:nil bundle:nil];
	creditsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	creditsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	creditsViewController.localizationManager = self.localizationManager;
	[self presentViewController:creditsViewController animated:YES completion:^
	{
		AELOG_DEBUG(@"Credits presented.");
	}];
}

- (void)_configureViews
{
	self.view.backgroundColor = [UIColor blackColor];
	
	self.swipeableContainer = [[UIView alloc] initWithFrame:self.view.bounds];
	self.swipeableContainer.backgroundColor = [UIColor clearColor];
	self.swipeableContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.swipeableContainer.clipsToBounds = YES;
	[self.view addSubview:self.swipeableContainer];
	
	[self _configureHarmonyContainer];
	
	CGFloat maximumWidth = 350;
	CGFloat containerWidth = self.view.bounds.size.width > maximumWidth ? maximumWidth : self.view.bounds.size.width;
	self.menuView = [[DekoMenuView alloc] initWithFrame:self.view.bounds containerWidth:containerWidth];
	self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.menuView.alpha = 0;
	self.menuView.hidden = YES;
	self.menuView.localizationManager = self.localizationManager;
	[self.menuView setupWithDelegate:self purchased:self.purchaseManager.proPurchased tutorial:self.showMenuLabels];
	[self.view addSubview:self.menuView];
	
	UIInterpolatingMotionEffect *menuHorizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	menuHorizontalEffect.minimumRelativeValue = @-10.0;
	menuHorizontalEffect.maximumRelativeValue = @10.0;
	[self.menuView addMotionEffect:menuHorizontalEffect];
	UIInterpolatingMotionEffect *menuVerticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	menuVerticalEffect.minimumRelativeValue = @-10.0;
	menuVerticalEffect.maximumRelativeValue = @10.0;
	[self.menuView addMotionEffect:menuVerticalEffect];

	self.logoView = [[DekoLogoView alloc] initWithFrame:self.view.bounds];
	self.logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.logoView setup];
	[self.view addSubview:self.logoView];
	
	NSString *markName = @"mark-white-iphone";
	if (DekoGetCurrentDeviceType() == DekoDeviceTypeiPad)
	{
		markName = @"mark-white-ipad";
	}
	
	UIImage *watermarkImage = [UIImage imageNamed:markName];
	self.watermark = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.watermark setImage:watermarkImage forState:UIControlStateNormal];
	self.watermark.frame = CGRectMake(0, 0, watermarkImage.size.width, watermarkImage.size.height);
	self.watermark.hidden = YES;
	self.watermark.alpha = 0;
	self.watermark.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	[self.watermark addTarget:self action:@selector(_dekoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	[self.swipeableContainer addSubview:self.watermark];
	
	UIInterpolatingMotionEffect *watermarkHorizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	watermarkHorizontalEffect.minimumRelativeValue = @-3.0;
	watermarkHorizontalEffect.maximumRelativeValue = @3.0;
	[self.watermark addMotionEffect:watermarkHorizontalEffect];
	UIInterpolatingMotionEffect *watermarkVerticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	watermarkVerticalEffect.minimumRelativeValue = @-3.0;
	watermarkVerticalEffect.maximumRelativeValue = @3.0;
	[self.watermark addMotionEffect:watermarkVerticalEffect];

	self.whiteCanvas = [[UIView alloc] initWithFrame:self.view.bounds];
	self.whiteCanvas.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.whiteCanvas.frame = AECGRectPlaceX(self.whiteCanvas.frame, self.view.bounds.size.width);
	self.whiteCanvas.hidden = YES;
	self.whiteCanvas.backgroundColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
	[self.view addSubview:self.whiteCanvas];
	
	CGFloat size = 60;
	CGRect labelFrame = CGRectMake(15.0,
								   CGRectGetMidY(self.whiteCanvas.bounds) - (size / 2.0),
								   size,
								   size);
	self.whiteCanvasLabel = [[UILabel alloc] initWithFrame:labelFrame];
	self.whiteCanvasLabel.backgroundColor = [UIColor clearColor];
	self.whiteCanvasLabel.textColor = [UIColor darkGrayColor];
	self.whiteCanvasLabel.font = [self.localizationManager localizedFontWithSize:21.0];
	self.whiteCanvasLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleTopMargin;
	self.whiteCanvasLabel.text = NSLocalizedString(@"New", @"Scene refresh, full refresh");
	[self.whiteCanvasLabel sizeToFit];
	[self.whiteCanvas addSubview:self.whiteCanvasLabel];
	
	self.whiteCanvasTutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
	self.whiteCanvasTutorialLabel.backgroundColor = self.whiteCanvasLabel.backgroundColor;
	self.whiteCanvasTutorialLabel.textColor = self.whiteCanvasLabel.textColor;
	self.whiteCanvasTutorialLabel.font = [self.localizationManager localizedFontWithSize:13.0];
	self.whiteCanvasTutorialLabel.numberOfLines = 0;
	self.whiteCanvasTutorialLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.whiteCanvasTutorialLabel.hidden = !self.tutorialHelper.shouldShowTutorial;
	[self.whiteCanvas addSubview:self.whiteCanvasTutorialLabel];

	self.whiteCanvasSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.whiteCanvasSpinner.color = [UIColor blackColor];
	self.whiteCanvasSpinner.hidden = YES;
	[self.whiteCanvas addSubview:self.whiteCanvasSpinner];
	
	UIImage *shadowImage = [UIImage imageNamed:@"shadow"];
	self.shadow = [[UIImageView alloc] initWithImage:shadowImage];
	self.shadow.frame = CGRectMake(0, 0, self.shadow.image.size.width, 0);
	self.shadow.alpha = 0;
	[self.view addSubview:self.shadow];
	
	self.undoShadow = [[UIImageView alloc] initWithImage:shadowImage];
	self.undoShadow.frame = self.shadow.frame;
	self.undoShadow.hidden = YES;
	[self.view addSubview:self.undoShadow];
	
	self.previousTutorialLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.previousTutorialLabel.backgroundColor = [UIColor clearColor];
	self.previousTutorialLabel.textColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
	self.previousTutorialLabel.font = self.whiteCanvasLabel.font;
	self.previousTutorialLabel.autoresizingMask = self.whiteCanvasLabel.autoresizingMask;
	self.previousTutorialLabel.text = NSLocalizedString(@"Previous", @"Undo tutorial text");
	[self.previousTutorialLabel sizeToFit];
	self.previousTutorialLabel.hidden = YES;
	self.previousTutorialLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
	self.previousTutorialLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	self.previousTutorialLabel.frame = AECGRectWithHeight(self.previousTutorialLabel.frame, CGRectGetHeight(self.whiteCanvasLabel.bounds));
	if (self.tutorialHelper.shouldShowTutorial)
	{
		[self.view insertSubview:self.previousTutorialLabel belowSubview:self.swipeableContainer];
	}
	
#ifdef DEBUG
	self.debugInfoLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
	self.debugInfoLabel.backgroundColor = [UIColor clearColor];
	self.debugInfoLabel.textColor = [UIColor whiteColor];
	self.debugInfoLabel.shadowColor = [UIColor blackColor];
	self.debugInfoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	self.debugInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.debugInfoLabel.hidden = YES;
	self.debugInfoLabel.numberOfLines = 0;
	[self.view addSubview:self.debugInfoLabel];
#endif
}

- (void)_proVersionPurchased:(NSNotification *)notification
{
	self.cachedImage = nil; // The user may have exported the same image previously.
	
	[self.menuView refreshShareMenuWithPurchaseStatus:self.purchaseManager.proPurchased tutorial:self.showMenuLabels];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tutorialHelper = [[DekoTutorialHelper alloc] init];
	
	self.localizationManager = [[DekoLocalizationManager alloc] init];
	self.galleryViewController.localizationManager = self.localizationManager;
	self.iapViewController.localizationManager = self.localizationManager;
	self.shareHelper.localizationManager = self.localizationManager;
	
	self.shareHelper.delegate = self;
	self.galleryViewController.delegate = self;
	self.iapViewController.delegate = self;

	self.showMenuLabels = self.tutorialHelper.shouldShowTutorial;
	
	[self _configureViews];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_proVersionPurchased:) name:DekoIAPManagerProVersionPurchasedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (!self.appLaunched)
	{
		[UIView animateWithDuration:DekoLogoAnimationDuration animations:^
		{
			self.view.backgroundColor = [UIColor colorWithWhite:DekoLaunchBackgroundColor alpha:1.0];
		}];
		
		[self.logoView animateLogoWithDuration:DekoLogoAnimationDuration completion:^
		{
			[self _revealCanvas];
		}];
		
		self.appLaunched = YES;
	}
}

- (BOOL)shouldAutorotate
{
	return DekoShouldAutorotate();
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DekoIAPManagerProVersionPurchasedNotification object:nil];
}

#pragma mark - DekoMenuViewDelegate

- (void)menuViewPlusButtonTouched:(DekoMenuView *)menuView
{
	BOOL canvasSaved = self.currentSceneID == nil;

	if (canvasSaved)
	{
		UIImage *image = [self _imageOfCurrentCanvas:YES];
		self.currentSceneID = [self.sceneManager sceneIDBySavingSceneWithCanvasSettings:self.currentSettings thumbnail:image];
	}
	else
	{
		[self.sceneManager deleteSceneWithID:self.currentSceneID];
		self.currentSceneID = nil;
	}
	
	[self.menuView updateMenuWithSaveStatus:canvasSaved tutorial:self.showMenuLabels animated:YES];
}

- (void)menuViewGalleryButtonTouched:(DekoMenuView *)menuView
{
	self.galleryViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.galleryViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:self.galleryViewController animated:YES completion:^
	{
		AELOG_DEBUG(@"Gallery shown.");
	}];
}

- (void)menuViewShareButtonTouched:(DekoMenuView *)menuView
{
	[self.menuView flipMenu];
}

- (void)menuViewIAPButtonTouched:(DekoMenuView *)menuView
{
	self.iapViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	self.iapViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:self.iapViewController animated:YES completion:^
	{
		AELOG_DEBUG(@"IAP view controller presented.");
	}];
}

- (void)menuView:(DekoMenuView *)menuView shareWithType:(DekoShareType)shareType
{
	[self.menuView updateShareButtonsWithBusyStateForShareType:shareType];
	
	[self performSelector:@selector(_shareImageWithShareType:) withObject:[NSNumber numberWithInteger:shareType] afterDelay:0];
}

#pragma mark - DekoShareHelperDelegate

- (void)shareHelper:(DekoShareHelper *)shareHelper wantsToShowViewController:(UIViewController *)viewController
{
	AEAssert(viewController != nil);
	
	[self presentViewController:viewController animated:YES completion:^
	{
		AELOG_DEBUG(@"");
	}];
}

- (void)shareHelper:(DekoShareHelper *)shareHelper savedImageWithError:(NSError *)error
{
	AELOG_DEBUG(@"%@", error);
	
	if ([[error domain] isEqualToString:ALAssetsLibraryErrorDomain])
	{
		[self _showTutorialWithText:NSLocalizedString(@"Saving failed. Access to the library is probably denied.", @"Error message, no access to photo library")];
	}
	else if (error != nil)
	{
		[self _showTutorialWithText:[error localizedDescription]];
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:^
	{
		AELOG_DEBUG(@"");
	}];
}

#pragma mark - DekoGalleryViewControllerDelegate

- (void)galleryViewController:(DekoGalleryViewController *)galleryViewController selectedScene:(DekoScene *)scene
{
	self.previousSettings = self.currentSettings;
	self.previousSceneID = self.currentSceneID;
	self.currentSettings = scene.settings;
	self.currentSceneID = scene.id;
	
	[self _configureViewHierarchyForNewCanvas];
	[self _generateNewCanvasWithFadeInDuration:UINavigationControllerHideShowBarDuration fadeOutDuration:UINavigationControllerHideShowBarDuration settings:self.currentSettings fadeOutLogo:NO];
	[self _hideMenu];
}

#pragma mark - DekoIAPViewControllerDelegate

- (void)iapViewController:(DekoIAPViewController *)iapViewController completedPurchaseWithError:(NSError *)error
{
	AELOG_DEBUG(@"%@", error);

	[self _proVersionPurchased:nil];
}

@end
