//
//  DekoShareHelper.m
//  deko
//
//  Created by Johan Halin on 4.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoShareHelper.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "DekoLocalizationManager.h"

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DekoShareHelper () <MFMailComposeViewControllerDelegate>
@property (nonatomic) BOOL purchased;
@end

@implementation DekoShareHelper

#pragma mark - Private

- (void)_shareImageToTwitter:(UIImage *)image
{
	if (self.localizationManager.useSinaWeibo)
	{
		SLComposeViewController *sinaWeiboViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
		[sinaWeiboViewController setInitialText:@"#deko#"];
		[sinaWeiboViewController addImage:image];
		[self.delegate shareHelper:self wantsToShowViewController:sinaWeiboViewController];
	}
	else
	{
		SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[twitterViewController setInitialText:@"#deko"];
		[twitterViewController addImage:image];
		[self.delegate shareHelper:self wantsToShowViewController:twitterViewController];
	}
}

- (void)_shareImageToFacebook:(UIImage *)image
{
	SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
	[facebookViewController setInitialText:NSLocalizedString(@"Created with Deko. dekoapp.com", @"Facebook share default text")];
	[facebookViewController addImage:image];
	[self.delegate shareHelper:self wantsToShowViewController:facebookViewController];
}

- (void)_emailImage:(UIImage *)image
{
	AELOG_DEBUG(@"");
	
	if (![MFMailComposeViewController canSendMail])
	{
		NSError *error = [[NSError alloc] initWithDomain:@"DekoDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Email has not been configured on this device.", @"Email not configured error description") }];
		[self.delegate shareHelper:self savedImageWithError:error];
		
		return;
	}
		
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	mailViewController.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self.delegate;
	mailViewController.navigationBar.tintColor = [UIColor darkGrayColor];
	[mailViewController addAttachmentData:[self _imageDataFromImage:image] mimeType:@"image/png" fileName:@"dekoimage.png"];
	[mailViewController setMessageBody:NSLocalizedString(@"Made with Deko.\ndekoapp.com", @"Email share default text") isHTML:NO];
	[self.delegate shareHelper:self wantsToShowViewController:mailViewController];
}

- (void)_saveImageToPhotos:(UIImage *)image
{
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library saveImageData:[self _imageDataFromImage:image] toAlbum:NSLocalizedString(@"Deko", @"Photo album title, do not localize") withCompletionBlock:^(NSError *error) {
		[self.delegate shareHelper:self savedImageWithError:error];
	}];
}

- (void)_copyImageToClipboard:(UIImage *)image
{	
	[[UIPasteboard generalPasteboard] setData:[self _imageDataFromImage:image] forPasteboardType:(NSString *)kUTTypePNG];
}

- (NSData *)_imageDataFromImage:(UIImage *)image
{
	if (self.purchased)
	{
		return UIImagePNGRepresentation(image);
	}
	else
	{
		return UIImageJPEGRepresentation(image, 0.5);
	}
}

#pragma mark - Public

- (void)shareImage:(UIImage *)image shareType:(DekoShareType)shareType proPurchased:(BOOL)proPurchased
{
	AEAssert(image != nil);
	AEAssert(self.delegate != nil);
	
	self.purchased = proPurchased;
	
	if (shareType == DekoShareTwitter)
	{
		[self _shareImageToTwitter:image];
	}
	else if (shareType == DekoShareFacebook)
	{
		[self _shareImageToFacebook:image];
	}
	else if (shareType == DekoShareEmail)
	{
		[self _emailImage:image];
	}
	else if (shareType == DekoSharePhotos)
	{
		[self _saveImageToPhotos:image];
	}
	else if (shareType == DekoShareCopy)
	{
		[self _copyImageToClipboard:image];
	}
}

@end
