//
//  DekoMenuView.m
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoMenuView.h"
#import "DekoConstants.h"
#import "DekoMenuButton.h"
#import "DekoCircleMenuView.h"
#import "DekoLocalizationManager.h"
#import "DekoFunctions.h"
#import "AECGHelpers.h"

NSString * const DekoButtonGalleryNotSaved = @"button-galle-";
NSString * const DekoButtonGallerySaved = @"button-gallf-";
NSString * const DekoButtonSave = @"button-save-";
NSString * const DekoButtonShareFront = @"button-sharer-";
NSString * const DekoButtonShareBack = @"button-sharel-";

NSString * const DekoSaveButtonSaveLabel = @"Save to Gallery";
NSString * const DekoSaveButtonRemoveLabel = @"Remove from Gallery";

const NSTimeInterval DekoAnimationDuration = 0.2;

@interface DekoMenuView () <DekoMenuButtonDelegate>
@property (nonatomic) UIView *baseContainer;
@property (nonatomic) UIView *shareContainer;
@property (nonatomic) DekoMenuButton *plusButton;
@property (nonatomic) DekoMenuButton *galleryButton;
@property (nonatomic) DekoMenuButton *shareButton;
@property (nonatomic) DekoMenuButton *twitterButton;
@property (nonatomic) DekoMenuButton *facebookButton;
@property (nonatomic) DekoMenuButton *emailButton;
@property (nonatomic) DekoMenuButton *photosButton;
@property (nonatomic) DekoMenuButton *imageCopyButton;
@property (nonatomic) NSString *deviceType;
@property (nonatomic, assign) BOOL shareMenuVisible;
@property (nonatomic) UILabel *tutorialGalleryLabel;
@property (nonatomic) UILabel *tutorialSaveLabel;
@property (nonatomic) UILabel *tutorialShareLabel;
@property (nonatomic) DekoCircleMenuView *baseMenuCircles;
@property (nonatomic) DekoCircleMenuView *shareMenuCircles;
@end

@implementation DekoMenuView

#pragma mark - Private

- (void)_plusButtonTouched:(id)sender
{	
	[self.delegate menuViewPlusButtonTouched:self];
}

- (void)_galleryButtonTouched:(id)sender
{
	[self.delegate menuViewGalleryButtonTouched:self];
}

- (void)_shareButtonTouched:(id)sender
{
	[self.delegate menuViewShareButtonTouched:self];
}

- (void)_twitterButtonTouched:(id)sender
{
	[self.delegate menuView:self shareWithType:DekoShareTwitter];
}

- (void)_facebookButtonTouched:(id)sender
{
	[self.delegate menuView:self shareWithType:DekoShareFacebook];
}

- (void)_emailButtonTouched:(id)sender
{
	[self.delegate menuView:self shareWithType:DekoShareEmail];
}

- (void)_photosButtonTouched:(id)sender
{
	[self.delegate menuView:self shareWithType:DekoSharePhotos];
}

- (void)_copyButtonTouched:(id)sender
{
	[self.delegate menuView:self shareWithType:DekoShareCopy];
}

- (void)_IAPButtonTouched:(id)sender
{
	[self.delegate menuViewIAPButtonTouched:self];
}

- (void)_removeAllSubviewsFromView:(UIView *)view
{
	for (id subview in view.subviews)
	{
		[subview removeFromSuperview];
	}
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame containerWidth:(CGFloat)containerWidth
{
    if ((self = [super initWithFrame:frame]))
	{
		self.backgroundColor = [UIColor clearColor];

		CGFloat length = MAX(frame.size.width, frame.size.height);
		CGRect rect = CGRectMake(CGRectGetMidX(frame) - (containerWidth / 2.0),
								 CGRectGetMidY(frame) - (length / 2.0),
								 containerWidth,
								 length);
		_baseContainer = [[UIView alloc] initWithFrame:rect];
		_baseContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		_baseContainer.backgroundColor = [UIColor clearColor];
		[self addSubview:_baseContainer];
		
		_shareContainer = [[UIView alloc] initWithFrame:AECGRectPlaceY(rect, rect.origin.y)];
		_shareContainer.autoresizingMask = _baseContainer.autoresizingMask;
		_shareContainer.backgroundColor = [UIColor clearColor];
    }
    
	return self;
}

- (void)_populateMenuWithProStatus:(BOOL)proPurchased tutorial:(BOOL)tutorial
{
	CGFloat circleSize = 0;
	CGFloat overlap = 0;
	CGFloat fontSize = 0;
	CGFloat circleAlpha = 0.8;
	CGFloat tutorialLabelHeight = 0;
	
	if (DekoGetCurrentDeviceType() == DekoDeviceTypeiPad)
	{
		circleSize = 120.0;
		overlap = 8.0;
		fontSize = 22;
		tutorialLabelHeight = fontSize * 3.0;
		self.deviceType = @"ipad";
	}
	else
	{
		circleSize = 90.0;
		overlap = 6.0;
		fontSize = 16;
		tutorialLabelHeight = floor(fontSize * 2.5);
		self.deviceType = @"iphone";
	}

	DekoCircleMenuView *baseCircles = [[DekoCircleMenuView alloc] initWithFrame:self.baseContainer.bounds];
	baseCircles.backgroundColor = [UIColor clearColor];
	baseCircles.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	baseCircles.circleSize = circleSize;
	baseCircles.overlap = overlap;
	baseCircles.items = 3;
	baseCircles.alpha = circleAlpha;
	[self.baseContainer addSubview:baseCircles];
	self.baseMenuCircles = baseCircles;
	
	CGFloat landscapeOffset = (DekoGetCurrentDeviceType() == DekoDeviceTypeiPhone6Plus && !proPurchased) ? -20.0 : 0;

	DekoCircleMenuView *shareCircles = [[DekoCircleMenuView alloc] initWithFrame:AECGRectPlaceY(self.shareContainer.bounds, self.shareContainer.bounds.origin.y + landscapeOffset)];
	shareCircles.backgroundColor = baseCircles.backgroundColor;
	shareCircles.autoresizingMask = baseCircles.autoresizingMask;
	shareCircles.circleSize = circleSize;
	shareCircles.overlap = overlap;
	shareCircles.items = proPurchased ? 6 : 7;
	shareCircles.alpha = circleAlpha;
	[self.shareContainer addSubview:shareCircles];
	self.shareMenuCircles = shareCircles;
	
	UIFont *font = [self.localizationManager localizedFontWithSize:fontSize];
	
	DekoMenuButton *galleryButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	UIImage *galleryButtonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", DekoButtonGalleryNotSaved, self.deviceType]];
	[galleryButton setImage:galleryButtonImage forState:UIControlStateNormal];
	galleryButton.frame = CGRectMake((self.baseContainer.bounds.size.width / 2.0) - ((galleryButtonImage.size.width / 2.0) - (overlap / 2.0)),
									 (self.baseContainer.bounds.size.height / 2.0) - (galleryButtonImage.size.height / 2.0),
									 galleryButtonImage.size.width - overlap,
									 galleryButtonImage.size.height);
	galleryButton.autoresizingMask = baseCircles.autoresizingMask;
	galleryButton.imageView.contentMode = UIViewContentModeCenter;
	galleryButton.tag = 2;
	galleryButton.delegate = self;
	[galleryButton addTarget:self action:@selector(_galleryButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.baseContainer addSubview:galleryButton];
	self.galleryButton = galleryButton;
	
	CGFloat offset = 10.0;
	CGRect tutorialGalleryLabelRect = CGRectMake(galleryButton.frame.origin.x,
												 galleryButton.frame.origin.y + galleryButton.bounds.size.height + offset,
												 galleryButton.bounds.size.width,
												 tutorialLabelHeight);
	self.tutorialGalleryLabel = [[UILabel alloc] initWithFrame:tutorialGalleryLabelRect];
	self.tutorialGalleryLabel.font = font;
	self.tutorialGalleryLabel.backgroundColor = [UIColor clearColor];
	self.tutorialGalleryLabel.textAlignment = NSTextAlignmentCenter;
	self.tutorialGalleryLabel.text = NSLocalizedString(@"Gallery", @"Tutorial, gallery button");
	self.tutorialGalleryLabel.textColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
	self.tutorialGalleryLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
	self.tutorialGalleryLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	self.tutorialGalleryLabel.hidden = !tutorial;
	[self.baseContainer addSubview:self.tutorialGalleryLabel];
	
	DekoMenuButton *plusButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	UIImage *plusButtonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", DekoButtonSave, self.deviceType]];
	[plusButton setImage:plusButtonImage forState:UIControlStateNormal];
	plusButton.frame = CGRectMake(galleryButton.frame.origin.x - plusButtonImage.size.width + overlap,
								  galleryButton.frame.origin.y,
								  plusButtonImage.size.width - overlap,
								  plusButtonImage.size.height);
	plusButton.autoresizingMask = baseCircles.autoresizingMask;
	plusButton.imageView.contentMode = galleryButton.imageView.contentMode;
	plusButton.tag = 1;
	plusButton.delegate = self;
	[plusButton addTarget:self action:@selector(_plusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.baseContainer addSubview:plusButton];
	self.plusButton = plusButton;
	
	CGRect tutorialSaveLabelRect = CGRectMake(plusButton.frame.origin.x,
											  tutorialGalleryLabelRect.origin.y,
											  plusButton.bounds.size.width,
											  tutorialGalleryLabelRect.size.height);
	self.tutorialSaveLabel = [[UILabel alloc] initWithFrame:tutorialSaveLabelRect];
	self.tutorialSaveLabel.font = font;
	self.tutorialSaveLabel.backgroundColor = self.tutorialGalleryLabel.backgroundColor;
	self.tutorialSaveLabel.textAlignment = self.tutorialGalleryLabel.textAlignment;
	self.tutorialSaveLabel.textColor = self.tutorialGalleryLabel.textColor;
	self.tutorialSaveLabel.numberOfLines = 0;
	self.tutorialSaveLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.tutorialSaveLabel.shadowColor = self.tutorialGalleryLabel.shadowColor;
	self.tutorialSaveLabel.shadowOffset = self.tutorialGalleryLabel.shadowOffset;
	self.tutorialSaveLabel.hidden = self.tutorialGalleryLabel.hidden;
	[self.baseContainer addSubview:self.tutorialSaveLabel];
	[self _updateTutorialSaveLabelWithSaveStatus:NO];
	
	DekoMenuButton *shareButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	UIImage *shareButtonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", DekoButtonShareFront, self.deviceType]];
	[shareButton setImage:shareButtonImage forState:UIControlStateNormal];
	shareButton.frame = CGRectMake(galleryButton.frame.origin.x + galleryButton.frame.size.width,
								   galleryButton.frame.origin.y,
								   shareButtonImage.size.width - overlap,
								   shareButtonImage.size.height);
	shareButton.autoresizingMask = baseCircles.autoresizingMask;
	shareButton.imageView.contentMode = galleryButton.imageView.contentMode;
	shareButton.tag = 3;
	shareButton.delegate = self;
	[shareButton addTarget:self action:@selector(_shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.baseContainer addSubview:shareButton];
	self.shareButton = shareButton;
	
	CGRect tutorialShareLabelRect = CGRectMake(shareButton.frame.origin.x,
											   tutorialGalleryLabelRect.origin.y,
											   shareButton.bounds.size.width,
											   tutorialGalleryLabelRect.size.height);
	self.tutorialShareLabel = [[UILabel alloc] initWithFrame:tutorialShareLabelRect];
	self.tutorialShareLabel.font = font;
	self.tutorialShareLabel.backgroundColor = self.tutorialGalleryLabel.backgroundColor;
	self.tutorialShareLabel.textAlignment = self.tutorialGalleryLabel.textAlignment;
	self.tutorialShareLabel.text = NSLocalizedString(@"Share and Export", @"Tutorial, share and export");
	self.tutorialShareLabel.textColor = self.tutorialGalleryLabel.textColor;
	self.tutorialShareLabel.shadowColor = self.tutorialGalleryLabel.shadowColor;
	self.tutorialShareLabel.shadowOffset = self.tutorialGalleryLabel.shadowOffset;
	self.tutorialShareLabel.numberOfLines = self.tutorialSaveLabel.numberOfLines;
	self.tutorialShareLabel.lineBreakMode = self.tutorialSaveLabel.lineBreakMode;
	self.tutorialShareLabel.hidden = self.tutorialGalleryLabel.hidden;
	[self.baseContainer addSubview:self.tutorialShareLabel];
	
	DekoMenuButton *backButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	UIImage *backButtonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", DekoButtonShareBack, self.deviceType]];
	[backButton setImage:backButtonImage forState:UIControlStateNormal];
	backButton.frame = AECGRectPlaceY(plusButton.frame, plusButton.frame.origin.y + landscapeOffset);
	backButton.autoresizingMask = plusButton.autoresizingMask;
	backButton.imageView.contentMode = galleryButton.imageView.contentMode;
	backButton.tag = 1;
	backButton.delegate = self;
	[backButton addTarget:self action:@selector(_shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareContainer addSubview:backButton];
	
	DekoMenuButton *twitterButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	[twitterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[twitterButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	twitterButton.titleLabel.font = font;
	twitterButton.titleLabel.numberOfLines = 0;
	twitterButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	twitterButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	twitterButton.frame = AECGRectPlaceY(galleryButton.frame, galleryButton.frame.origin.y + landscapeOffset);
	twitterButton.autoresizingMask = shareCircles.autoresizingMask;
	twitterButton.tag = 2;
	twitterButton.delegate = self;
	[twitterButton addTarget:self action:@selector(_twitterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareContainer addSubview:twitterButton];
	self.twitterButton = twitterButton;
	
	DekoMenuButton *facebookButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	[facebookButton setTitleColor:[twitterButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
	[facebookButton setTitleColor:[twitterButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
	facebookButton.titleLabel.font = twitterButton.titleLabel.font;
	facebookButton.titleLabel.numberOfLines = twitterButton.titleLabel.numberOfLines;
	facebookButton.titleLabel.lineBreakMode = twitterButton.titleLabel.lineBreakMode;
	facebookButton.titleLabel.textAlignment = twitterButton.titleLabel.textAlignment;
	facebookButton.frame = AECGRectPlaceY(shareButton.frame, shareButton.frame.origin.y + landscapeOffset);
	facebookButton.autoresizingMask = shareButton.autoresizingMask;
	facebookButton.tag = 3;
	facebookButton.delegate = self;
	[facebookButton addTarget:self action:@selector(_facebookButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareContainer addSubview:facebookButton];
	self.facebookButton = facebookButton;
	
	DekoMenuButton *emailButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	[emailButton setTitleColor:[twitterButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
	[emailButton setTitleColor:[twitterButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
	emailButton.titleLabel.font = twitterButton.titleLabel.font;
	emailButton.titleLabel.numberOfLines = twitterButton.titleLabel.numberOfLines;
	emailButton.titleLabel.lineBreakMode = twitterButton.titleLabel.lineBreakMode;
	emailButton.titleLabel.textAlignment = twitterButton.titleLabel.textAlignment;
	emailButton.frame = CGRectMake(backButton.frame.origin.x,
								   backButton.frame.origin.y + backButton.frame.size.height - (overlap / 2.0),
								   backButton.frame.size.width,
								   backButton.frame.size.height - overlap);
	emailButton.autoresizingMask = backButton.autoresizingMask;
	emailButton.tag = 4;
	emailButton.delegate = self;
	[emailButton addTarget:self action:@selector(_emailButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareContainer addSubview:emailButton];
	self.emailButton = emailButton;
	
	DekoMenuButton *photosButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	[photosButton setTitleColor:[twitterButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
	[photosButton setTitleColor:[twitterButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
	photosButton.titleLabel.font = twitterButton.titleLabel.font;
	photosButton.titleLabel.numberOfLines = twitterButton.titleLabel.numberOfLines;
	photosButton.titleLabel.lineBreakMode = twitterButton.titleLabel.lineBreakMode;
	photosButton.titleLabel.textAlignment = twitterButton.titleLabel.textAlignment;
	photosButton.frame = CGRectMake(galleryButton.frame.origin.x,
									emailButton.frame.origin.y,
									galleryButton.frame.size.width,
									emailButton.frame.size.height);
	photosButton.autoresizingMask = backButton.autoresizingMask;
	photosButton.tag = 5;
	photosButton.delegate = self;
	[photosButton addTarget:self action:@selector(_photosButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareContainer addSubview:photosButton];
	self.photosButton = photosButton;
	
	DekoMenuButton *copyButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
	[copyButton setTitleColor:[twitterButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
	[copyButton setTitleColor:[twitterButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
	copyButton.titleLabel.font = twitterButton.titleLabel.font;
	copyButton.titleLabel.numberOfLines = twitterButton.titleLabel.numberOfLines;
	copyButton.titleLabel.lineBreakMode = twitterButton.titleLabel.lineBreakMode;
	copyButton.titleLabel.textAlignment = twitterButton.titleLabel.textAlignment;
	copyButton.frame = CGRectMake(shareButton.frame.origin.x,
								  emailButton.frame.origin.y,
								  shareButton.frame.size.width,
								  emailButton.frame.size.height);
	copyButton.autoresizingMask = backButton.autoresizingMask;
	copyButton.tag = 6;
	copyButton.delegate = self;
	[copyButton addTarget:self action:@selector(_copyButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareContainer addSubview:copyButton];
	self.imageCopyButton = copyButton;
	
	if (!proPurchased)
	{
		DekoMenuButton *unlockHighQualityButton = [DekoMenuButton buttonWithType:UIButtonTypeCustom];
		[unlockHighQualityButton setTitle:NSLocalizedString(@"High\nquality export", @"Unlock high quality export button title") forState:UIControlStateNormal];
		[unlockHighQualityButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		unlockHighQualityButton.titleLabel.font = twitterButton.titleLabel.font;
		unlockHighQualityButton.titleLabel.numberOfLines = twitterButton.titleLabel.numberOfLines;
		unlockHighQualityButton.titleLabel.lineBreakMode = twitterButton.titleLabel.lineBreakMode;
		unlockHighQualityButton.titleLabel.textAlignment = twitterButton.titleLabel.textAlignment;
		unlockHighQualityButton.frame = CGRectMake(photosButton.frame.origin.x,
												   photosButton.frame.origin.y + photosButton.frame.size.height,
												   photosButton.frame.size.width,
												   photosButton.frame.size.height);
		unlockHighQualityButton.autoresizingMask = photosButton.autoresizingMask;
		unlockHighQualityButton.tag = 7;
		unlockHighQualityButton.delegate = self;
		[unlockHighQualityButton addTarget:self action:@selector(_IAPButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		[self.shareContainer addSubview:unlockHighQualityButton];
	}
	
	[self updateShareButtonsWithBusyStateForShareType:DekoShareNone];
}

- (void)_updateTutorialSaveLabelWithSaveStatus:(BOOL)saved
{
	if (saved)
	{
		self.tutorialSaveLabel.text = NSLocalizedString(@"Remove from Gallery", @"Tutorial, remove from gallery");
	}
	else
	{
		self.tutorialSaveLabel.text = NSLocalizedString(@"Save to Gallery", @"Tutorial, save to gallery");
	}
}

- (NSString *)_busyStringForShareType:(DekoShareType)shareType
{
	if (shareType == DekoSharePhotos)
	{
		return NSLocalizedString(@"Saving", @"Save to photos button title, busy state");
	}
	else if (shareType == DekoShareCopy)
	{
		return NSLocalizedString(@"Copying", @"Copy button title, busy state");
	}
	else
	{
		return NSLocalizedString(@"Preparing", @"Generic share button title, busy state");
	}
}

#pragma mark - Public

- (void)setupWithDelegate:(id)delegate purchased:(BOOL)purchased tutorial:(BOOL)tutorial
{
	AEAssert(delegate != nil);
	
	self.delegate = delegate;

	[self _populateMenuWithProStatus:purchased tutorial:tutorial];
}

- (void)updateMenuWithSaveStatus:(BOOL)saved tutorial:(BOOL)tutorial animated:(BOOL)animated
{
	self.tutorialGalleryLabel.hidden = !tutorial;
	self.tutorialSaveLabel.hidden = !tutorial;
	self.tutorialShareLabel.hidden = !tutorial;
	
	void (^animationBlock)(void) = ^
	{
		if (saved)
		{
			self.plusButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_4);
		}
		else
		{
			self.plusButton.transform = CGAffineTransformIdentity;
		}
	};

	void (^animationCompletionBlock)(BOOL) = ^(BOOL finished)
	{
		if (saved)
		{
			[self.galleryButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", DekoButtonGallerySaved, self.deviceType]] forState:UIControlStateNormal];
		}
		else
		{
			[self.galleryButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", DekoButtonGalleryNotSaved, self.deviceType]] forState:UIControlStateNormal];
		}
		
		[self _updateTutorialSaveLabelWithSaveStatus:saved];
	};
	
	if (animated)
	{
		[UIView animateWithDuration:DekoAnimationDuration animations:animationBlock completion:animationCompletionBlock];
	}
	else
	{
		animationBlock();
		animationCompletionBlock(YES);
	}
}

- (void)refreshShareMenuWithPurchaseStatus:(BOOL)purchased tutorial:(BOOL)tutorial
{
	[self _removeAllSubviewsFromView:self.baseContainer];
	[self _removeAllSubviewsFromView:self.shareContainer];
	[self _populateMenuWithProStatus:purchased tutorial:tutorial];
}

- (void)flipMenu
{
	if (self.shareMenuVisible)
	{
		self.baseContainer.frame = self.shareContainer.frame;
		
		[UIView transitionFromView:self.shareContainer toView:self.baseContainer duration:UINavigationControllerHideShowBarDuration * 2.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished)
		{
			self.shareMenuVisible = NO;
		}];
	}
	else
	{
		self.shareContainer.frame = self.baseContainer.frame;
		
		[UIView transitionFromView:self.baseContainer toView:self.shareContainer duration:UINavigationControllerHideShowBarDuration * 2.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished)
		{
			self.shareMenuVisible = YES;
		}];
	}
}

- (void)updateShareButtonsWithBusyStateForShareType:(DekoShareType)shareType
{
	if (self.localizationManager.useSinaWeibo)
	{
		[self.twitterButton setTitle:@"新浪微博" forState:UIControlStateNormal];
	}
	else
	{
		[self.twitterButton setTitle:NSLocalizedString(@"Twitter", @"Share to Twitter button title") forState:UIControlStateNormal];
	}
	
	[self.facebookButton setTitle:NSLocalizedString(@"Facebook", @"Share to Facebook button title") forState:UIControlStateNormal];
	[self.emailButton setTitle:NSLocalizedString(@"Email", @"Share by email button title") forState:UIControlStateNormal];
	[self.photosButton setTitle:NSLocalizedString(@"Save to photos", @"Save to photos button title") forState:UIControlStateNormal];
	[self.imageCopyButton setTitle:NSLocalizedString(@"Copy", @"Copy button title") forState:UIControlStateNormal];
	
	if (shareType == DekoShareTwitter)
	{
		[self.twitterButton setTitle:[self _busyStringForShareType:shareType] forState:UIControlStateNormal];
	}
	else if (shareType == DekoShareFacebook)
	{
		[self.facebookButton setTitle:[self _busyStringForShareType:shareType] forState:UIControlStateNormal];
	}
	else if (shareType == DekoShareEmail)
	{
		[self.emailButton setTitle:[self _busyStringForShareType:shareType] forState:UIControlStateNormal];
	}
	else if (shareType == DekoSharePhotos)
	{
		[self.photosButton setTitle:[self _busyStringForShareType:shareType] forState:UIControlStateNormal];
	}
	else if (shareType == DekoShareCopy)
	{
		[self.imageCopyButton setTitle:[self _busyStringForShareType:shareType] forState:UIControlStateNormal];
	}
}

#pragma mark - DekoMenuButtonDelegate

- (void)menuButton:(DekoMenuButton *)menuButton highlighted:(BOOL)highlighted
{
	NSInteger selected = -1;
	if (highlighted)
	{
		selected = menuButton.tag;
	}
	
	if (self.shareMenuVisible)
	{
		self.shareMenuCircles.selected = selected;
	}
	else
	{
		self.baseMenuCircles.selected = selected;
	}
}

@end
