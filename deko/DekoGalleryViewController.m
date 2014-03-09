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

@interface DekoGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) DekoFlowLayout *layout;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSArray *scenes;
@property (nonatomic) UILabel *emptyLabel;
@end

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

#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor colorWithWhite:kDekoBackgroundColor alpha:1.0];
	
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
	self.layout.itemSize = CGSizeMake(kDekoThumbnailSize, kDekoThumbnailSize);
	CGFloat padding = 9.0;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		padding = 18.0;
	}
	
	self.layout.minimumInteritemSpacing = 1.0;
	self.layout.minimumLineSpacing = 1.0;
	self.layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
	
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
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(1.0 + padding, 1.0 + padding, 44.0, 44.0);
	[backButton setImage:backButtonImage forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_dismissWithItemAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];

	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.scenes = [self.sceneManager allScenes];
	
	[self.collectionView reloadData];
	
	self.view.layer.cornerRadius = 0;
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
