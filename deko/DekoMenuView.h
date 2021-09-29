//
//  DekoMenuView.h
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DekoMenuView;
@class DekoLocalizationManager;

typedef NS_ENUM(NSInteger, DekoShareType)
{
	DekoShareNone = 0,
	DekoShareTwitter,
	DekoShareFacebook,
	DekoShareEmail,
	DekoSharePhotos,
	DekoShareCopy,
    DekoShareGeneric,
};

@protocol DekoMenuViewDelegate <NSObject>

@required
- (void)menuViewPlusButtonTouched:(DekoMenuView *)menuView;
- (void)menuViewGalleryButtonTouched:(DekoMenuView *)menuView;
- (void)menuViewShareButtonTouched:(DekoMenuView *)menuView;
- (void)menuViewIAPButtonTouched:(DekoMenuView *)menuView;
- (void)menuView:(DekoMenuView *)menuView shareWithType:(DekoShareType)shareType;

@end

@interface DekoMenuView : UIView

@property (nonatomic, weak) NSObject<DekoMenuViewDelegate> *delegate;
@property (nonatomic) DekoLocalizationManager *localizationManager;

- (instancetype)initWithFrame:(CGRect)frame containerWidth:(CGFloat)containerWidth NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (void)setupWithDelegate:(id)delegate purchased:(BOOL)purchased tutorial:(BOOL)tutorial;
- (void)updateMenuWithSaveStatus:(BOOL)saved tutorial:(BOOL)tutorial animated:(BOOL)animated;
- (void)refreshShareMenuWithPurchaseStatus:(BOOL)purchased tutorial:(BOOL)tutorial;
- (void)flipMenu;
- (void)updateShareButtonsWithBusyStateForShareType:(DekoShareType)shareType;

@end
