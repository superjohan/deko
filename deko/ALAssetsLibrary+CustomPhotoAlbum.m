//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation ALAssetsLibrary(CustomPhotoAlbum)

- (void)saveImageData:(NSData *)imageData toAlbum:(NSString *)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
	[self writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
	{
		if (error != nil)
		{
			completionBlock(error);
			return;
		}

		[self addAssetURL:assetURL toAlbum:albumName withCompletionBlock:completionBlock];
	}];
}

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
	__block BOOL albumWasFound = NO;

	[self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop)
	{
		if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame)
		{
			albumWasFound = YES;
			
			[self assetForURL:assetURL resultBlock:^(ALAsset *asset)
			{
				[group addAsset: asset];
				completionBlock(nil);
			}
			failureBlock:completionBlock];
			
			return;
		}
		
		if (group == nil && albumWasFound == NO)
		{
			__weak ALAssetsLibrary *weakSelf = self;
			
			[self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group)
			{
				[weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset)
				{
					[group addAsset:asset];
					completionBlock(nil);
				}
				failureBlock:completionBlock];
			}
			failureBlock:completionBlock];
			
			return;
		}
	}
	failureBlock:completionBlock];
}

@end
