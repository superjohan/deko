//
//  DekoGalleryViewController.m
//  deko
//
//  Created by Johan Halin on 5.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DekoGalleryViewController.h"
#import "DekoGalleryItemView.h"
#import "DekoSceneManager.h"
#import "DekoScene.h"
#import "DekoConstants.h"
#import "DekoFlowLayout.h"
#import "DekoLocalizationManager.h"
#import "DekoFunctions.h"

@interface DekoGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) DekoFlowLayout *layout;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSArray *scenes;
@property (nonatomic) UILabel *emptyLabel;
@property (nonatomic) UIButton *backButton;
@end

static const CGFloat DekoCollectionViewSpacing = 1.0;

@implementation DekoGalleryViewController

#pragma mark - Private

- (void)_dismissWithItemAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath isKindOfClass:[NSIndexPath class]])
	{
		DekoGalleryItemView *itemView = [self _itemViewForIndexPath:indexPath];
		itemView.loading = NO;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (DekoGalleryItemView *)_itemViewInCell:(UICollectionViewCell *)cell
{
	DekoGalleryItemView *itemView = nil;
	
	for (UIView *subview in cell.contentView.subviews)
	{
		if ([subview isKindOfClass:[DekoGalleryItemView class]])
		{
			itemView = (DekoGalleryItemView *)subview;
		}
	}
	
	return itemView;
}

- (DekoGalleryItemView *)_itemViewForIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];

	return [self _itemViewInCell:cell];
}

- (CGFloat)_paddingForCollectionView
{
	CGFloat spacing = 1.0;
	CGFloat width = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
	CGFloat amountOfItemsPerLine = floor(width / 100.0);
	CGFloat padding = (((NSInteger)width % (NSInteger)DekoThumbnailSize) / 2.0) - (((amountOfItemsPerLine - 1) * spacing) / 2.0);
	
	return padding;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		UIImageView *watermark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark-black-iphone"]];
		watermark.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - watermark.image.size.width,
									 CGRectGetHeight(self.view.bounds) - watermark.image.size.height,
									 watermark.image.size.width,
									 watermark.image.size.height);
		watermark.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.view addSubview:watermark];
	}
	
	self.layout = [[DekoFlowLayout alloc] init];
	self.layout.itemSize = CGSizeMake(DekoThumbnailSize, DekoThumbnailSize);
	self.layout.minimumInteritemSpacing = DekoCollectionViewSpacing;
	self.layout.minimumLineSpacing = DekoCollectionViewSpacing;
	
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
	self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.alwaysBounceVertical = YES;
	[self.view addSubview:self.collectionView];
	
	CGFloat emptyLabelWidth = 200.0;
	CGFloat emptyLabelHeight = 100.0;
	CGFloat emptyLabelPadding = 20.0;
	CGRect emptyLabelRect = CGRectMake(floor(CGRectGetMidX(self.view.bounds) - (emptyLabelWidth / 2.0)),
									   floor(CGRectGetMidY(self.view.bounds) - (emptyLabelHeight / 2.0) - emptyLabelPadding),
									   emptyLabelWidth,
									   emptyLabelHeight);
	self.emptyLabel = [[UILabel alloc] initWithFrame:emptyLabelRect];
	self.emptyLabel.backgroundColor = [UIColor clearColor];
	self.emptyLabel.font = [self.localizationManager localizedFontWithSize:32.0];
	self.emptyLabel.numberOfLines = 0;
	self.emptyLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.emptyLabel.textAlignment = NSTextAlignmentCenter;
	self.emptyLabel.text = NSLocalizedString(@"No saved patterns.", @"Gallery view, no saved patterns");
	self.emptyLabel.hidden = YES;
	self.emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	self.emptyLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
	[self.view addSubview:self.emptyLabel];
	
	UIImage *backButtonImage = [UIImage imageNamed:@"credits-backarrow"];
	self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.backButton setImage:backButtonImage forState:UIControlStateNormal];
	[self.backButton addTarget:self action:@selector(_dismissWithItemAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.backButton];
	
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.scenes = [self.sceneManager allScenes];
	
	[self.collectionView reloadData];
	
	self.view.layer.cornerRadius = 0;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	CGFloat padding = [self _paddingForCollectionView];
	self.layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
	self.backButton.frame = CGRectMake(1.0 + padding, 1.0 + padding, 44.0, 44.0);
}

- (BOOL)shouldAutorotate
{
	return DekoShouldAutorotate();
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSInteger count = [self.scenes count];
	
	self.emptyLabel.hidden = (count > 0);
	
	return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"cell";
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

	DekoGalleryItemView *itemView = [self _itemViewInCell:cell];

	if (itemView == nil)
	{
		itemView = [[DekoGalleryItemView alloc] initWithFrame:cell.bounds];
	}

	DekoScene *scene = self.scenes[indexPath.item];
	[self.sceneManager loadThumbnailForSceneID:scene.id completion:^(UIImage *thumbnail)
	{
		itemView.thumbnail = thumbnail;
	}];
	[cell.contentView addSubview:itemView];
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	DekoGalleryItemView *itemView = [self _itemViewForIndexPath:indexPath];
	itemView.loading = YES;
	
	DekoScene *scene = self.scenes[indexPath.item];
	
	[self.delegate galleryViewController:self selectedScene:scene];

	[self performSelector:@selector(_dismissWithItemAtIndexPath:) withObject:indexPath afterDelay:0];
}

@end
