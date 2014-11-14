//
//  DekoLocalizationManager.m
//  deko
//
//  Created by Johan Halin on 8.2.2013.
//  Copyright (c) 2013 Aero Deko. All rights reserved.
//

#import "DekoLocalizationManager.h"

NSString * const DekoFont = @"GillSans-Light";
NSString * const DekoKoreaJapanFont = @"AppleSDGothicNeo-UltraLight";
NSString * const DekoChinaFont = @"FZLTXHK--GBK1-0";

typedef NS_ENUM(NSInteger, DekoLanguageType)
{
	DekoLanguageTypeNormal = 0,
	DekoLanguageTypeKorea,
	DekoLanguageTypeJapan,
	DekoLanguageTypeChina,
	DekoLanguageTypeItaly,
};

@interface DekoLocalizationManager ()
@property (nonatomic, assign) DekoLanguageType currentLanguage;
@end

@implementation DekoLocalizationManager

#pragma mark - Public

- (id)init
{
	if ((self = [super init]))
	{
		NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
		if ([language isEqualToString:@"zh-Hans"])
		{
			_currentLanguage = DekoLanguageTypeChina;
		}
		else if ([language isEqualToString:@"ja"])
		{
			_currentLanguage = DekoLanguageTypeJapan;
		}
		else if ([language isEqualToString:@"ko"])
		{
			_currentLanguage = DekoLanguageTypeKorea;
		}
		else
		{
			_currentLanguage = DekoLanguageTypeNormal;
		}
	}
	
	return self;
}

- (UIFont *)localizedFontWithSize:(CGFloat)size
{
	if (self.currentLanguage == DekoLanguageTypeNormal)
	{
		return [UIFont fontWithName:DekoFont size:size];
	}
	else if (self.currentLanguage == DekoLanguageTypeChina)
	{
		return [UIFont fontWithName:DekoChinaFont size:floor(size * .85)];
	}
	else if (self.currentLanguage == DekoLanguageTypeJapan)
	{
		return [UIFont fontWithName:DekoKoreaJapanFont size:floor(size * .90)];
	}
	else if (self.currentLanguage == DekoLanguageTypeKorea)
	{
		return [UIFont fontWithName:DekoKoreaJapanFont size:size];
	}
	else
	{
		AELOG_ERROR(@"Unknown font type!");
		
		return nil;
	}
}

#pragma mark - Properties

- (BOOL)useSinaWeibo
{
	return (self.currentLanguage == DekoLanguageTypeChina);
}

@end
